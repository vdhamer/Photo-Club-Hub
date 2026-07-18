#!/usr/bin/env bash
#
# capture-screenshots.sh
# Photo Club Hub — documentation screenshot pipeline (GitHub issue #774 and subissues)
#
# Captures framed screenshots of the four tab screens (Maps / Clubs / People / Settings)
# plus the pushed Portfolio screen via both routes (PortfolioViaClubs and PortfolioViaPeople,
# #777) across the EN/NL x light/dark matrix.
#
# Navigation is done via the app's `-initialTab` / `-skipPrelude` launch arguments
# (one launch per screen); the RocketSim CLI provides the device-framed captures,
# and `xcrun simctl` a clean status bar and appearance.
#
# Output: PNGs named <Screen>_<lang>_<appearance>.png in the output folder (see OUT_DIR).
#
# ---------------------------------------------------------------------------
# Scope (per #775):
# ---------------------------------------------------------------------------
#   - The four TAB screens (#775) plus the non-tab screens in EXTRA_SCREENS (#777):
#     Portfolio (via Clubs and via People tabs), Prelude, and Readme sheet.
#   - Content readiness (#776): instead of fixed sleeps, the app writes a marker file
#     (Documents/screenshot-ready) once the launched screen's preset content is on screen;
#     wait_until_ready() polls for it and fails the run on a per-screen timeout.
#   - Tips (#776): `-suppressTips YES` keeps TipKit tips out of the captures.
#
# ---------------------------------------------------------------------------
# Requirements:
# ---------------------------------------------------------------------------
#   - RocketSim.app installed AND running (the CLI talks to the running app over IPC).
#     The CLI binary ships inside the app bundle; this script locates it automatically.
#   - Xcode command-line tools (`xcrun simctl`).
#   - The app already built & installed on the target simulator, OR pass --build to have
#     this script build+install it for you.
#   - Written for macOS's stock bash 3.2 (no associative arrays / namerefs / mapfile).
#   - There is NO support for iOS 17 (some of the code resides in MainTabView1827).
#
# ---------------------------------------------------------------------------
# Arguments of script:
# ---------------------------------------------------------------------------
#
#   Scripts/capture-screenshots.sh [--build] [--udid <UDID>] [--ios-version <version>] [--out <dir>] [--keep-booted]
#   --build         Build the app for the target simulator and (re)install it first.
#   --udid <UDID>   Override the target simulator UDID (default: auto-pick iPhone 17 Pro).
#   --ios-version <version>
#                   Narrow the auto-pick to a specific iOS runtime (default: auto-detect
#                   the latest installed runtime). Ignored when --udid is set.
#   --out <dir>     Override the output directory (default: <repo>/scripts/screenshots).
#   --keep-booted   Do not shut the simulator down when finished.
#
# ---------------------------------------------------------------------------
# Screenshot-related arguments of the app itself:
# ---------------------------------------------------------------------------
# These are launch arguments (passed via `xcrun simctl launch`); each `-key value` pair
# becomes a one-shot UserDefaults override inside the app for that launch — nothing is
# persisted. This is the authoritative list; the app has no other screenshot-mode switches.
#
#   -AppleLanguages "(en)"|"(nl)"   iOS-defined: UI language for this launch
#
#   -initialTab <Maps|Clubs|People|Settings|PortfolioViaClubs|PortfolioViaPeople|Prelude|Readme>
#                                   Open directly on this tab (canonical English names in any
#                                   locale; case-insensitive). Read by MainTabView1827.swift
#                                   for tab selection. Side effects per value, implemented in
#                                   the per-screen <View>+Screenshot.swift files:
#                                   - Maps: scrolls to the preset club (MapsView+Screenshot)
#                                   - Clubs: scrolls to the preset club section
#                                     (MemberPortfolioView+Screenshot)
#                                   - People: scrolls to the preset photographer card
#                                     (PhotographersListView2627+Screenshot)
#                                   - PortfolioViaClubs / PortfolioViaPeople: additionally
#                                     push the preset member's portfolio from the Clubs resp.
#                                     People tab and jump its Juicebox gallery to the preset
#                                     image (#777); both captures are near-identical by design.
#                                     Preset constants live in ScreenshotReadiness.swift.
#                                   - Prelude: shows the splash screen (used WITHOUT
#                                     -skipPrelude YES so the prelude is actually visible);
#                                     signals readiness once the prelude image asset has loaded
#                                     (PreludeView2627+Screenshot.swift).
#                                   - Readme: opens the Clubs tab, auto-presents the Readme
#                                     sheet, and signals readiness after a settle delay, all
#                                     from MemberPortfolioView+Screenshot.swift (Clubs pattern).
#                                   Presence of ANY -initialTab value also arms the readiness
#                                   marker (Documents/screenshot-ready, see ScreenshotReadiness
#                                   .swift) that wait_until_ready() polls for (#776).
#
#   -skipPrelude YES                Start on the main tabs without the Prelude splash screen.
#                                   Read by RootView.swift.
#
#   -suppressTips YES               Hide all TipKit tips so they don't photobomb the captures
#                                   (#776). Read by ScreenshotReadiness.configureAtStartup(),
#                                   called from PhotoClubHubApp.init.
#
# Unrelated to screenshots: the app also reads a few persisted UserDefaults keys for debug
# toggles on the Settings > Advanced screen (manualDataLoading, extraCoreDataSaves,
# showTemplateClubs, errorOnCoreDataMerge — see Extensions/Settings.swift). They would accept
# launch-argument overrides through the same mechanism, but this script does not use them.
# To regenerate the full list of keys the app responds to:
#   grep -rn 'UserDefaults.standard' --include='*.swift' 'Photo Club Hub' | grep forKey
#
set -euo pipefail

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------
# App under test. Bundle id comes from the Xcode project's PRODUCT_BUNDLE_IDENTIFIER
# (target "Photo Club Hub"): com.vdhamer.Fotogroep-Waalre
BUNDLE_ID="com.vdhamer.Fotogroep-Waalre"
SCHEME="Photo Club Hub"

# Preferred simulator model (the current iPhone "Pro"). Auto-discovered by name unless
# an explicit --udid is supplied. Change PREFERRED_DEVICE to retarget.
PREFERRED_DEVICE="iPhone 17 Pro"
PREFERRED_IOS_VERSION=""  # "" = auto-detect latest installed iOS runtime; override with --ios-version
UDID=""            # resolved below (or from --udid)

# Matrix.
LANGUAGES=(en nl)
APPEARANCES=(light dark)

# The four tab screens, in tab bar order (MainTabView1827.swift / issue #773).
# Navigation does NOT tap the tab bar: RocketSim's element tree omits tab buttons when the
# app runs in a non-English locale (https://github.com/AvdLee/RocketSimApp/issues/1083),
# so the script relaunches the app once per screen
# with the `-initialTab <Screen>` launch argument instead (canonical English
# names, handled in MainTabView1827.swift). `-skipPrelude YES` suppresses the splash screen.
# This is locale-independent and also more deterministic than tap choreography.
TAB_SCREENS=(Maps Clubs People Settings)

# Non-tab screens. PortfolioViaClubs/PortfolioViaPeople (#777) = Clubs resp. People tab +
# app-hardcoded push of the preset member's portfolio (Fotogroep de Gender / Francien van Mil),
# with its gallery jumped to a preset image when the site is a Juicebox-Pro gallery (handled
# app-side in MemberPortfolioView and SinglePortfolioView; on a non-Juicebox site the jump is a
# no-op and the capture shows that site's opening screen). Prelude = the initial splash screen,
# launched WITHOUT -skipPrelude so the view is visible. Readme = Clubs tab with the Readme
# sheet auto-presented by ReadmeButton (ReadmeButton+Screenshot.swift).
EXTRA_SCREENS=(PortfolioViaClubs PortfolioViaPeople Prelude Readme)

# Framing options for `rocketsim screenshot`.
BEZEL="device"          # device frame style: none | simulator | device
BACKGROUND="#FFFFFF"    # background color behind the framed device
DEVICE_SHADOW=1         # 1 = render a shadow behind the device frame
JPEG_QUALITY=85         # JPEG quality 0–100 (RocketSim outputs PNG; sips converts)

# Readiness polling (#776). The app (ScreenshotReadiness.swift) writes
# Documents/screenshot-ready inside its data container once the launched screen's preset
# content is on screen; wait_until_ready() polls for that marker. Generous timeouts cost
# nothing on success — polling exits as soon as the marker appears.
READY_TIMEOUT=60                 # per-screen readiness timeout (seconds)
READY_TIMEOUT_PORTFOLIO=90       # PortfolioVia* also loads the web gallery + jumps to its image
SLEEP_AFTER_READY=3              # visual settling after readiness: map tiles, thumbnails, scroll
SLEEP_AFTER_READY_PORTFOLIO=8   # extra settling for Portfolio screens: Juicebox gallery image load

# Output directory (kept out of git — see the .gitignore note for Scripts/screenshots).
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="${REPO_ROOT}/Scripts/screenshots"

# Behaviour flags (set by args).
DO_BUILD=0
KEEP_BOOTED=0

# ---------------------------------------------------------------------------
# Locate the RocketSim CLI (may not be on PATH; ships inside the app bundle).
# ---------------------------------------------------------------------------
find_rocketsim() {
    if command -v rocketsim >/dev/null 2>&1; then
        command -v rocketsim
        return 0
    fi
    local candidates=(
        "/Applications/RocketSim.app/Contents/Helpers/rocketsim"
        "${HOME}/Applications/RocketSim.app/Contents/Helpers/rocketsim"
    )
    local c
    for c in "${candidates[@]}"; do
        [[ -x "$c" ]] && { echo "$c"; return 0; }
    done
    return 1
}

# ---------------------------------------------------------------------------
# Argument parsing.
# ---------------------------------------------------------------------------
while [[ $# -gt 0 ]]; do
    case "$1" in
        --build)       DO_BUILD=1; shift ;;
        --udid)        UDID="${2:?--udid needs a value}"; shift 2 ;;
        --ios-version) PREFERRED_IOS_VERSION="${2?--ios-version needs a value}"; shift 2 ;;
        --out)         OUT_DIR="${2:?--out needs a value}"; shift 2 ;;
        --keep-booted) KEEP_BOOTED=1; shift ;;
        -h|--help)     grep -E '^# ' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
        *)             echo "Unknown argument: $1" >&2; exit 2 ;;
    esac
done

# Verify xcrun simctl is available (requires Xcode, not just the command-line tools).
if ! /usr/bin/xcrun simctl help &>/dev/null; then
    echo "ERROR: 'xcrun simctl' not available." >&2
    echo "       Make sure Xcode is installed and run:" >&2
    echo "         sudo xcode-select --switch /Applications/Xcode.app" >&2
    exit 1
fi
SIMCTL=( /usr/bin/xcrun simctl )

RS="$(find_rocketsim || true)"
if [[ -z "${RS}" ]]; then
    echo "ERROR: RocketSim CLI not found." >&2
    echo "  Install RocketSim.app, or enable its CLI from the app's menu, then retry." >&2
    exit 1
fi
echo "RocketSim CLI: ${RS}"

# ipc_reachable_now: returns 0 if RocketSim's IPC channel is open.
# Accepts both compact JSON ("ipc_reachable":true) and spaced ("ipc_reachable": true).
ipc_reachable_now() {
    "${RS}" status 2>/dev/null | grep -qE '"ipc_reachable"\s*:\s*true'
}

# ensure_rocketsim: make sure RocketSim.app is running and its IPC channel is open,
# (re)launching it and waiting up to ROCKETSIM_STARTUP_TIMEOUT seconds if needed.
# Called at startup AND again whenever a screenshot fails mid-run: a full run takes
# minutes, and RocketSim can quit or lose its IPC channel in the meantime (e.g. when
# simulators shut down or the app is closed between/during runs).
ROCKETSIM_STARTUP_TIMEOUT=30
ensure_rocketsim() {
    ipc_reachable_now && return 0
    echo "RocketSim app not reachable — (re)launching it..."
    open -a RocketSim || true
    local waited=0
    while [[ "${waited}" -lt "${ROCKETSIM_STARTUP_TIMEOUT}" ]]; do
        sleep 2
        waited=$((waited + 2))
        ipc_reachable_now && return 0
    done
    return 1
}

# Once set to 1, rocketsim is no longer asked for screenshots and the unframed
# `simctl io screenshot` fallback is used instead (see capture()). This keeps the run
# going when RocketSim is broken — e.g. RocketSim 16.3 (build 323) crashes with a SIGTRAP
# in FBSimulatorControl.inferSimulatorConfiguration on every CLI screenshot request.
RS_BROKEN=0
UNFRAMED_COUNT=0

# Recovery window for a failed `rocketsim screenshot` (see capture()). RocketSim 16.2
# (build 320) intermittently aborts on an uncaught NSException raised on a background
# queue inside FBSimulatorControl (FBSimulatorAccessibilityCommands →
# +[FBSimulatorLaunchCtlCommands commandsWithTarget:] assertion), triggered by the
# `rocketsim interact tap` calls in dismiss_first_run_interruptions(). After
# ensure_rocketsim relaunches the app, its IPC channel answers within ~1 second, but simulator
# discovery takes another 25–50s ("No simulator found with UDID ...", then future
# timeouts) — so a single immediate retry always fails. Retry within a bounded window
# instead; only when RocketSim stays dead for the whole window is RS_BROKEN set.
RS_RECOVERY_TIMEOUT=90   # seconds to keep retrying a failed rocketsim screenshot
RS_RETRY_INTERVAL=3      # pause between retries within the recovery window

# ---------------------------------------------------------------------------
# Auto-detect the latest available iOS runtime when PREFERRED_IOS_VERSION is empty.
# ---------------------------------------------------------------------------
# Uses awk to pick the highest major.minor from `simctl list runtimes available`, so the
# script stays current when iOS 27.1 or 28.0 is installed without any configuration change.
latest_ios_runtime() {
    "${SIMCTL[@]}" list runtimes available \
        | grep -E '^iOS [0-9]+\.[0-9]+' \
        | awk '{
              split($2, v, ".");
              maj = v[1]+0; min = v[2]+0;
              if (maj > bm || (maj == bm && min > bn)) { bm=maj; bn=min; best=$1" "$2 }
          } END { print best }'
}
if [[ -z "${PREFERRED_IOS_VERSION}" ]]; then
    PREFERRED_IOS_VERSION="$(latest_ios_runtime)"
    [[ -z "${PREFERRED_IOS_VERSION}" ]] && { echo "ERROR: no iOS runtimes found." >&2; exit 1; }
    echo "Auto-detected runtime: ${PREFERRED_IOS_VERSION}"
fi

# ---------------------------------------------------------------------------
# Resolve the target simulator UDID.
# ---------------------------------------------------------------------------
if [[ -z "${UDID}" ]]; then
    # There can be several available simulators with this exact name (one per installed
    # iOS runtime). Prefer one that already has the app installed (typically Xcode's run
    # destination) — launching on a sibling without the app fails with
    # FBSOpenApplicationServiceErrorDomain code=4. Fall back to the first match.
    if [[ -n "${PREFERRED_IOS_VERSION}" ]]; then
        # Filter by both device name and iOS runtime version.
        # `simctl list devices` groups entries under section headers like "-- iOS 27.0 --";
        # awk tracks which section we're in, then matches device lines within it.
        CANDIDATE_UDIDS="$("${SIMCTL[@]}" list devices available \
                | awk -v section="-- ${PREFERRED_IOS_VERSION} --" \
                      -v device="${PREFERRED_DEVICE}" \
                      '/^-- /{in_sec=(index($0,section)>0); next} in_sec&&index($0,device)' \
                | sed -E 's/.*\(([0-9A-Fa-f-]{36})\).*/\1/')"
    else
        # Filter by device name only (any iOS runtime).
        CANDIDATE_UDIDS="$("${SIMCTL[@]}" list devices available \
                | grep -E "^\s+${PREFERRED_DEVICE} \(" \
                | sed -E 's/.*\(([0-9A-Fa-f-]{36})\).*/\1/')"
    fi
    for candidate in ${CANDIDATE_UDIDS}; do
        [[ -z "${UDID}" ]] && UDID="${candidate}"    # fallback: first match
        if "${SIMCTL[@]}" get_app_container "${candidate}" "${BUNDLE_ID}" app >/dev/null 2>&1; then
            UDID="${candidate}"                      # preferred: app already installed here
            break
        fi
    done
fi
if [[ -z "${UDID}" ]]; then
    if [[ -n "${PREFERRED_IOS_VERSION}" ]]; then
        echo "ERROR: could not find an available simulator named '${PREFERRED_DEVICE}' running ${PREFERRED_IOS_VERSION}." >&2
    else
        echo "ERROR: could not find an available simulator named '${PREFERRED_DEVICE}'." >&2
    fi
    echo "       Pick one from 'xcrun simctl list devices available' and pass --udid." >&2
    exit 1
fi
if [[ -n "${PREFERRED_IOS_VERSION}" ]]; then
    echo "Target simulator: ${PREFERRED_DEVICE:-'(explicit)'} / ${PREFERRED_IOS_VERSION} — ${UDID}"
else
    echo "Target simulator: ${PREFERRED_DEVICE:-'(explicit)'} — ${UDID}"
fi

mkdir -p "${OUT_DIR}"
echo "Output folder: ${OUT_DIR}"

# ---------------------------------------------------------------------------
# Boot the simulator.
# ---------------------------------------------------------------------------
echo "Booting simulator..."
"${SIMCTL[@]}" boot "${UDID}" 2>/dev/null || true   # no-op if already booted
"${SIMCTL[@]}" bootstatus "${UDID}" -b || true
open -a Simulator --args -CurrentDeviceUDID "${UDID}" || true

# Verify RocketSim's IPC channel after the simulator is running. Checking before boot can
# give a false negative because RocketSim only detects the device once the simulator starts.
if ! ensure_rocketsim; then
    echo "WARNING: RocketSim app is installed but not reachable over IPC." >&2
    echo "         Continuing with the 'simctl io screenshot' fallback (no device bezels)." >&2
    RS_BROKEN=1
fi

# ---------------------------------------------------------------------------
# Optionally build + install the app.
# ---------------------------------------------------------------------------
if [[ "${DO_BUILD}" -eq 1 ]]; then
    echo "Building '${SCHEME}' for the simulator..."
    DERIVED="$(mktemp -d)"
    xcodebuild \
        -project "${REPO_ROOT}/Photo Club Hub.xcodeproj" \
        -scheme "${SCHEME}" \
        -configuration Debug \
        -destination "id=${UDID}" \
        -derivedDataPath "${DERIVED}" \
        build | tail -n 20
    APP_PATH="$(/usr/bin/find "${DERIVED}/Build/Products" -maxdepth 2 -name '*.app' -type d | head -n1)"
    if [[ -z "${APP_PATH}" ]]; then
        echo "ERROR: build produced no .app bundle." >&2
        exit 1
    fi
    echo "Installing ${APP_PATH}"
    "${SIMCTL[@]}" install "${UDID}" "${APP_PATH}"
fi

# Fail early (rather than at the first launch) if the app is not installed on the target.
APP_CONTAINER="$("${SIMCTL[@]}" get_app_container "${UDID}" "${BUNDLE_ID}" app 2>/dev/null)"
if [[ -z "${APP_CONTAINER}" ]]; then
    echo "ERROR: ${BUNDLE_ID} is not installed on simulator ${UDID}." >&2
    echo "       Re-run with --build, install the app on this simulator from Xcode," >&2
    echo "       or pass --udid <UDID> of a simulator that already has the app." >&2
    exit 1
fi

# Warn when the installed binary is older than any Swift source in the repo.
# Screens whose signaling code was added after the last build will time out silently otherwise.
#
# NB: the comparison must use the EXECUTABLE inside the bundle, not APP_CONTAINER itself.
# get_app_container returns the .app bundle DIRECTORY, and installing bumps the directory's
# mtime to the install time (re-signing replaces entries inside it), so `-newer` against the
# directory never matched sources edited after the build — the executable keeps its build mtime.
find_app_binary() {
    local exec_name
    exec_name="$(/usr/bin/defaults read "${APP_CONTAINER}/Info" CFBundleExecutable 2>/dev/null || true)"
    if [[ -n "${exec_name}" && -f "${APP_CONTAINER}/${exec_name}" ]]; then
        echo "${APP_CONTAINER}/${exec_name}"
        return 0
    fi
    # Fallback: the conventional executable named after the bundle (<Name>.app/<Name>).
    # (Do NOT fall back to `find -perm +111`: bundled resources also carry exec bits.)
    local bundle_name
    bundle_name="$(basename "${APP_CONTAINER}" .app)"
    if [[ -f "${APP_CONTAINER}/${bundle_name}" ]]; then
        echo "${APP_CONTAINER}/${bundle_name}"
        return 0
    fi
    return 1
}
if [[ "${DO_BUILD}" -eq 0 ]]; then
    APP_BINARY="$(find_app_binary || true)"   # empty on failure; set -e must not abort here
    if [[ -z "${APP_BINARY}" ]]; then
        echo "WARNING: cannot locate the executable inside ${APP_CONTAINER}; skipping the stale-binary check." >&2
    else
        STALE_SOURCE="$(/usr/bin/find "${REPO_ROOT}/Photo Club Hub" \
            -name "*.swift" -newer "${APP_BINARY}" -print -quit 2>/dev/null)"
        if [[ -n "${STALE_SOURCE}" ]]; then
            echo "WARNING: Swift source(s) newer than the installed app binary (e.g. ${STALE_SOURCE##*/})." >&2
            echo "         Screens whose readiness code was added since the last build will time out." >&2
            echo "         Re-run with --build to rebuild and reinstall." >&2
        fi
    fi
fi

# Resolve the readiness marker path once (the data container is stable per install).
APP_DATA_CONTAINER="$("${SIMCTL[@]}" get_app_container "${UDID}" "${BUNDLE_ID}" data 2>/dev/null)"
if [[ -z "${APP_DATA_CONTAINER}" ]]; then
    echo "ERROR: cannot resolve the data container of ${BUNDLE_ID} on ${UDID}." >&2
    exit 1
fi
READY_MARKER="${APP_DATA_CONTAINER}/Documents/screenshot-ready"

# ---------------------------------------------------------------------------
# Clean status bar: 9:41, full battery, full signal (Apple marketing default).
# ---------------------------------------------------------------------------
echo "Applying clean status bar override..."
"${SIMCTL[@]}" status_bar "${UDID}" override \
    --time "9:41" \
    --dataNetwork "wifi" \
    --wifiMode "active" \
    --wifiBars 3 \
    --cellularMode "active" \
    --cellularBars 4 \
    --batteryState "charged" \
    --batteryLevel 100

# ---------------------------------------------------------------------------
# Pre-grant location permission.
#
# On first launch the Maps tab triggers a "Allow to use your location?" system alert
# that sits on top of the app and blocks capture. Granting it up front avoids the alert
# entirely. (This is first-run OS state, not a TipKit tip; TipKit suppression is #776.)
# ---------------------------------------------------------------------------
echo "Granting location permission to avoid the first-run system alert..."
"${SIMCTL[@]}" privacy "${UDID}" grant location "${BUNDLE_ID}" 2>/dev/null || true

# ---------------------------------------------------------------------------
# Helpers.
# ---------------------------------------------------------------------------

# Common screenshot flags (populated once, below).
SCREENSHOT_FLAGS=(--udid "${UDID}" --bezel "${BEZEL}" --background "${BACKGROUND}")
[[ "${DEVICE_SHADOW}" -eq 1 ]] && SCREENSHOT_FLAGS+=(--device-shadow)

# Poll for the app's readiness marker (#776): written by ScreenshotReadiness.signalReady()
# once the launched screen's preset content is on screen. A hung or partial load therefore
# fails the run (non-zero exit) instead of capturing a spinner. After readiness, a short
# settling sleep lets purely visual work (map tiles, thumbnails) finish rendering.
wait_until_ready() {
    local screen="$1" timeout="$2" settle="${3:-${SLEEP_AFTER_READY}}"
    local waited=0
    while [[ ! -f "${READY_MARKER}" ]]; do
        if [[ "${waited}" -ge "${timeout}" ]]; then
            echo "ERROR: screen ${screen} not ready after ${timeout}s (no ${READY_MARKER})." >&2
            exit 1
        fi
        sleep 1
        waited=$((waited + 1))
    done
    sleep "${settle}"
}

# Best-effort dismissal of first-run interruptions that can sit over the tabs:
#   - a leftover location permission alert (if the pre-grant above didn't work)
#   - the built-in Readme sheet, which can auto-present on first run
# Each tap is a no-op if the element isn't present. Thorough first-run/tip handling
# (incl. TipKit) is ticket #776; this is only enough to unblock the four tab captures.
# NB: these taps are also what intermittently CRASHES RocketSim 16.2 (uncaught
# FBSimulatorControl exception on a background queue; see RS_RECOVERY_TIMEOUT above) —
# the crash then surfaces as a failed screenshot in capture(), which recovers from it.
dismiss_first_run_interruptions() {
    # "element_not_found" is the normal case; suppress stdout too (the CLI prints errors as JSON there).
    "${RS}" interact tap --label "Allow While Using App" --timeout 1 --udid "${UDID}" >/dev/null 2>&1 || true
    "${RS}" interact tap --label "Sta toe tijdens gebruik" --timeout 1 --udid "${UDID}" >/dev/null 2>&1 || true
    "${RS}" interact tap --label "Close" --type Button --timeout 1 --udid "${UDID}" >/dev/null 2>&1 || true
}

# Capture one framed screenshot to <Screen>_<lang>_<appearance>.jpg.
# RocketSim always emits PNG bytes; sips converts to JPEG in-place.
# If the capture fails (because RocketSim quit, lost its IPC channel, or crashed — see the
# RS_RECOVERY_TIMEOUT comment for the known 16.2 FBSimulatorControl crash), revive
# RocketSim via ensure_rocketsim and keep retrying for up to RS_RECOVERY_TIMEOUT seconds:
# a relaunched RocketSim answers IPC almost immediately but needs another 25–50s before
# it can see the simulator again. Only when the whole window elapses without success is
# RocketSim marked broken for the rest of the run and the unframed `simctl io screenshot`
# fallback used, so a truly broken RocketSim (e.g. the 16.3 crash-on-every-request bug)
# degrades the output (no bezels) once instead of aborting the run.
capture() {
    local screen="$1" lang="$2" appearance="$3"
    local out="${OUT_DIR}/${screen}_${lang}_${appearance}.jpg"
    local tmp tmperr framed=0 recovery_start
    tmp="$(mktemp /tmp/screenshot_XXXXXX)"
    tmperr="$(mktemp /tmp/screenshot_err_XXXXXX)"
    if [[ "${RS_BROKEN}" -eq 0 ]]; then
        if "${RS}" screenshot "${SCREENSHOT_FLAGS[@]}" > "${tmp}" 2>"${tmperr}"; then
            framed=1
        else
            echo "WARNING: 'rocketsim screenshot' failed for ${screen}/${lang}/${appearance} — reviving RocketSim and retrying for up to ${RS_RECOVERY_TIMEOUT}s:" >&2
            cat "${tmperr}" >&2
            recovery_start="$(date +%s)"
            while :; do
                ensure_rocketsim || true
                if "${RS}" screenshot "${SCREENSHOT_FLAGS[@]}" > "${tmp}" 2>"${tmperr}"; then
                    framed=1
                    echo "  RocketSim recovered after $(( $(date +%s) - recovery_start ))s." >&2
                    break
                fi
                if [[ $(( $(date +%s) - recovery_start )) -ge "${RS_RECOVERY_TIMEOUT}" ]]; then
                    echo "WARNING: 'rocketsim screenshot' still failing after ${RS_RECOVERY_TIMEOUT}s — using the simctl fallback for the rest of this run:" >&2
                    cat "${tmperr}" >&2
                    RS_BROKEN=1
                    break
                fi
                sleep "${RS_RETRY_INTERVAL}"
            done
        fi
    fi
    if [[ "${framed}" -eq 0 ]]; then
        if ! "${SIMCTL[@]}" io "${UDID}" screenshot "${tmp}" >/dev/null 2>&1; then
            echo "ERROR: fallback 'simctl io screenshot' also failed for ${screen}/${lang}/${appearance}." >&2
            rm -f "${tmp}" "${tmperr}"
            exit 1
        fi
        UNFRAMED_COUNT=$((UNFRAMED_COUNT + 1))
    fi
    rm -f "${tmperr}"
    /usr/bin/sips -s format jpeg -s formatOptions "${JPEG_QUALITY}" \
        "${tmp}" --out "${out}" >/dev/null
    rm -f "${tmp}"
    echo "  saved ${out}"
}

# ---------------------------------------------------------------------------
# Capture matrix: language x appearance x tab.
# ---------------------------------------------------------------------------
for lang in "${LANGUAGES[@]}"; do
    for appearance in "${APPEARANCES[@]}"; do
        echo "=== ${lang} / ${appearance} ==="

        # Appearance is a device-level setting; apply before launch.
        "${SIMCTL[@]}" ui "${UDID}" appearance "${appearance}"

        # One fresh launch per screen: locale, initial tab, and (for non-Prelude screens) no
        # Prelude via launch arguments (see the TAB_SCREENS comment for why tabs are not tapped).
        for screen in "${TAB_SCREENS[@]}" "${EXTRA_SCREENS[@]}"; do
            echo "-- screen: ${screen}"
            "${SIMCTL[@]}" terminate "${UDID}" "${BUNDLE_ID}" 2>/dev/null || true
            rm -f "${READY_MARKER}"   # the app also clears it at startup (belt and braces)
            # Prelude is the splash screen itself: launch it without -skipPrelude so it is visible.
            SKIP_PRELUDE_ARG=(); [[ "${screen}" != Prelude ]] && SKIP_PRELUDE_ARG=(-skipPrelude YES)
            "${SIMCTL[@]}" launch "${UDID}" "${BUNDLE_ID}" \
                -AppleLanguages "(${lang})" -initialTab "${screen}" \
                ${SKIP_PRELUDE_ARG[@]+"${SKIP_PRELUDE_ARG[@]}"} -suppressTips YES
            if [[ "${screen}" == PortfolioVia* ]]; then
                wait_until_ready "${screen}" "${READY_TIMEOUT_PORTFOLIO}" "${SLEEP_AFTER_READY_PORTFOLIO}"
            else
                wait_until_ready "${screen}" "${READY_TIMEOUT}"
            fi
            dismiss_first_run_interruptions
            capture "${screen}" "${lang}" "${appearance}"
        done
    done
done

# ---------------------------------------------------------------------------
# Cleanup.
# ---------------------------------------------------------------------------
echo "Clearing status bar override..."
"${SIMCTL[@]}" status_bar "${UDID}" clear || true

if [[ "${KEEP_BOOTED}" -eq 0 ]]; then
    echo "Shutting simulator down..."
    "${SIMCTL[@]}" shutdown "${UDID}" || true
fi

if [[ "${UNFRAMED_COUNT}" -gt 0 ]]; then
    echo "WARNING: ${UNFRAMED_COUNT} screenshot(s) were captured WITHOUT a device bezel" >&2
    echo "         (simctl fallback because RocketSim was not usable)." >&2
fi
echo "Done. Screenshots in: ${OUT_DIR}"
