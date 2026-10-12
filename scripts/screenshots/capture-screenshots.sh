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
# Output: per screen a framed JPG named <Screen>_<lang>_<appearance>.jpg (background flattened
# to white for light captures, black for dark ones) plus the original transparent-background
# PNG (larger, but usable on any backdrop; suppress with --no-png), in OUT_DIR.
# With --app-store the JPGs go into OUT_DIR/AppStore instead: they are the only files App Store Connect
# accepts (the PNGs have other sizes and a transparent background), so that folder can be uploaded as is.
#
# ---------------------------------------------------------------------------
# Scope (per #775):
# ---------------------------------------------------------------------------
#   - The 10 screens of the App Store listing, in listing order (SCREENS, #880): four tab screens (#775),
#     Portfolio and Readme sheet (#777), plus portfolios in landscape and portrait and two museum maps (#880).
#     PortfolioViaPeople and Prelude are still supported by the app but left out of SCREENS.
#   - Landscape (#880): on an iPad, LANDSCAPE_SCREENS are captured last, after a notification asking for the iPad to
#     be rotated in Device Hub; an iPhone turns itself. Nobody there: they're captured in portrait after 10 minutes.
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
#   - The script assumes the app is at its default setting. If the app would be configured
#     to hide all clubs, the script cannot find the example its is looking for.
#
# ---------------------------------------------------------------------------
# Arguments of script:
# ---------------------------------------------------------------------------
#
#   scripts/screenshots/capture-screenshots.sh [--build] [--udid <UDID>] [--ios-version <version>] [--out <dir>] [--keep-booted] [--no-png]
#                                  [--jpg-background-light <color>] [--jpg-background-dark <color>] [--app-store]
#   --build         Build the app for the target simulator and (re)install it first.
#   --udid <UDID>   Override the target simulator UDID (default: auto-pick iPhone 17 Pro).
#   --ios-version <version>
#                   Narrow the auto-pick to a specific iOS runtime (default: auto-detect
#                   the latest installed runtime). Ignored when --udid is set.
#   --out <dir>     Override the output directory (default: <repo>/scripts/screenshots/output).
#   --keep-booted   Do not shut the simulator down when finished.
#   --no-png        Only keep the flattened JPGs; discard the transparent-background PNGs
#                   (default: keep both).
#   --jpg-background-light <color>
#                   Background color flattened into the *_light.jpg images, as RRGGBB or
#                   #RRGGBB (default: FFFFFF, i.e. white).
#   --jpg-background-dark <color>
#                   Background color flattened into the *_dark.jpg images, as RRGGBB or
#                   #RRGGBB (default: 000000, i.e. black).
#   --app-store     Rescale the output JPGs to the App Store Connect accepted pixel dimensions
#                   for the target device. The framed image is scaled proportionally and padded
#                   with the matte color to fill the required canvas. Only JPGs are rescaled;
#                   the raw transparent PNGs retain their native framed size. The rescaled JPGs are
#                   written to an AppStore subfolder of the output directory.
#                   Supported devices (portrait), per Apple's screenshot specifications (Oct 2026):
#                     iPhone 18 Pro, iPhone 17 Pro, iPhone 16 Pro  →  1206 × 2622
#                       ("iPhone with Dynamic Island, medium display": the one REQUIRED iPhone size)
#                     iPhone 18 Pro Max, iPhone 17 Pro Max, iPhone 16 Pro Max  →  1320 × 2868  (optional)
#                     iPhone 16 Plus, iPhone 15 Plus        →  1290 × 2796  (optional)
#                     iPad Pro 13-inch (M5), iPad Pro 13-inch (M4), iPad Air 13-inch (M4)  →  2064 × 2752
#                       (13": REQUIRED when the app runs on iPad)
#                   Any other device: target a supported one by setting PREFERRED_DEVICE in this script, or with --udid.
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
#PREFERRED_DEVICE="iPad Air 13-inch (M4)"
# Not "iPhone 18 Pro" yet: RocketSim 16.7.0 ships iPhone 18 Pro device frames but does not apply them
# (neither in its own window nor via the CLI), and then silently returns the bare screen without a bezel.
# Switch back once https://github.com/AvdLee/RocketSimApp/issues/1214 is fixed.
PREFERRED_DEVICE="iPhone 17 Pro"
PREFERRED_IOS_VERSION=""  # "" = auto-detect latest installed iOS runtime; override with --ios-version
UDID=""            # resolved below (or from --udid)

# Matrix.
LANGUAGES=(en nl)
APPEARANCES=(light)       # the App Store listing uses light mode (#880), except for DARK_SCREENS
#APPEARANCES=(light dark)
# Screens captured in dark mode whatever the round's appearance: a portfolio image on an upright phone gets wide
# bars above and below it, which are white in light mode and drew the eye away from the photo (#880).
DARK_SCREENS=(PortfolioLandscape PortfolioPortrait)
# Screens that need the device in landscape. On an iPhone the app turns itself sideways for these. On an iPad,
# iPadOS 26+ refuses that ("The current windowing mode does not allow for programmatic changes to interface
# orientation", also with Full Screen Apps), so an iPad run captures them last, for all languages in one go, after
# asking for the iPad to be rotated by hand in Device Hub (#880). Unattended, it captures them in portrait instead.
# Neither simctl nor the RocketSim CLI can rotate a simulator yet; once https://github.com/AvdLee/RocketSimApp/issues/1219
# adds a rotate command, the iPad can be turned from here and the manual step can go.
LANDSCAPE_SCREENS=(PortfolioLandscape)
LANDSCAPE_WAIT_TIMEOUT=600 # seconds to wait for the iPad to be rotated before capturing in portrait

# The screens, in the order of the App Store listing (#880). Each file name starts with its position here
# ("01_Maps_en_light.jpg"), so the files sort in listing order.
# Navigation does NOT tap the tab bar: RocketSim's element tree omits tab buttons when the
# app runs in a non-English locale (https://github.com/AvdLee/RocketSimApp/issues/1083),
# so the script relaunches the app once per screen
# with the `-initialTab <Screen>` launch argument instead (canonical English
# names, handled in MainTabView1827.swift). `-skipPrelude YES` suppresses the splash screen.
# This is locale-independent and also more deterministic than tap choreography.
#
# Maps, Clubs, People, Settings: the four tabs (#775).
# PortfolioViaClubs (#777) = Clubs tab + app-hardcoded push of a preset member's portfolio,
# with its gallery showing a preset image when the site is a Juicebox-Pro gallery (handled
# app-side in MemberPortfolioView and SinglePortfolioView; on a non-Juicebox site this is a
# no-op and the capture shows that site's opening screen). PortfolioLandscape and PortfolioPortrait (#880)
# work the same way with other presets; PortfolioLandscape also turns the device sideways.
# MapsMuseum / MapsMuseum3D (#880) = Maps tab on Fotografiska New York, locked resp. unlocked in 3D.
# Readme = Clubs tab with the Readme sheet auto-presented by ReadmeButton (ReadmeButton+Screenshot.swift).
# Supported but not in the listing: PortfolioViaPeople (the People-tab twin of PortfolioViaClubs) and
# Prelude (the splash screen, launched WITHOUT -skipPrelude so it is visible).
SCREENS=(Maps
         Clubs
         PortfolioViaClubs
         People
         Settings
         PortfolioLandscape
         PortfolioPortrait
         MapsMuseum
         MapsMuseum3D
         Readme)
#SCREENS+=(PortfolioViaPeople Prelude)

# Framing options for `rocketsim screenshot`.
BEZEL="device"            # device frame style: none | simulator | device
#BEZEL="simulator"
BACKGROUND="transparent"  # PNG background (transparent | preset | #RRGGBB); keep transparent
                          # so the saved PNGs can be used against any backdrop
DEVICE_SHADOW=1           # 1 = render a shadow behind the device frame
JPEG_QUALITY=85           # JPEG quality 0–100 (see flatten_png_to_jpg)

# JPEG has no alpha channel, so converting the transparent PNG flattens its background onto
# a solid color (flatten_png_to_jpg below). Match the matte to the captured appearance — a
# white matte around a dark capture clashes on dark web pages (and vice versa).
# Overridable per run via --jpg-background-light / --jpg-background-dark.
JPG_BACKGROUND_LIGHT="FFFFFF"
JPG_BACKGROUND_DARK="000000"

# Readiness polling (#776). The app (ScreenshotReadiness.swift) writes
# Documents/screenshot-ready inside its data container once the launched screen's preset
# content is on screen; wait_until_ready() polls for that marker. Generous timeouts cost
# nothing on success — polling exits as soon as the marker appears.
READY_TIMEOUT=60                 # per-screen readiness timeout (seconds)
READY_TIMEOUT_PORTFOLIO=90       # PortfolioVia* also loads the web gallery + jumps to its image
SLEEP_AFTER_READY=3              # visual settling after readiness: map tiles, thumbnails, scroll
SLEEP_AFTER_READY_PORTFOLIO=8   # extra settling for Portfolio screens: Juicebox gallery image load
# MapsMuseum3D signals readiness after a MapKit snapshot, but SwiftUI's live Map has no "fully drawn" signal of its
# own, and on 11 Oct an iPad capture 8 s after readiness still showed both 3D maps empty (#880).
SLEEP_AFTER_READY_MAPS3D=20
# Pause between screens after each capture. iPad captures push host CPU to ~100%; without
# a gap the simulator watchdog kills background apps (0x8BADF00D) that can't complete their
# launch within 30 s when the Mac scheduler is fully saturated. A few seconds costs nothing
# on a successful run (readiness polling already dominates) but keeps the system breathing.
SLEEP_BETWEEN_SCREENS=5

# Output directory (kept out of git — see the .gitignore note for scripts/screenshots/output).
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
OUT_DIR="${SCRIPT_DIR}/output"

# Behavior flags (set by args).
DO_BUILD=0
KEEP_BOOTED=0
KEEP_PNG=1
RESCALE=0
UDID_FROM_FLAG=0

# ---------------------------------------------------------------------------
# Locate the RocketSim CLI (may not be on PATH; ships inside the app bundle).
# ---------------------------------------------------------------------------
find_rocketsim() {
    local candidates=(
        "/Applications/RocketSim.app/Contents/Helpers/rocketsim"
        "${HOME}/Applications/RocketSim.app/Contents/Helpers/rocketsim"
    )
    local c
    for c in "${candidates[@]}"; do
        [[ -x "$c" ]] && { echo "$c"; return 0; }
    done
    command -v rocketsim >/dev/null 2>&1 && { command -v rocketsim; return 0; }
    return 1
}

# ---------------------------------------------------------------------------
# Argument parsing.
# ---------------------------------------------------------------------------
while [[ $# -gt 0 ]]; do
    case "$1" in
        --build)       DO_BUILD=1; shift ;;
        --udid)        UDID="${2:?--udid needs a value}"; UDID_FROM_FLAG=1; shift 2 ;;
        --ios-version) PREFERRED_IOS_VERSION="${2?--ios-version needs a value}"; shift 2 ;;
        --out)         OUT_DIR="${2:?--out needs a value}"; shift 2 ;;
        --keep-booted) KEEP_BOOTED=1; shift ;;
        --no-png)      KEEP_PNG=0; shift ;;
        --jpg-background-light) JPG_BACKGROUND_LIGHT="${2:?--jpg-background-light needs a value}"; shift 2 ;;
        --jpg-background-dark)  JPG_BACKGROUND_DARK="${2:?--jpg-background-dark needs a value}"; shift 2 ;;
        --app-store)   RESCALE=1; shift ;;
        -h|--help)     grep -E '^# ' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
        *)             echo "Unknown argument: $1" >&2; exit 2 ;;
    esac
done

# Normalize and validate the JPG background colors up front. A leading '#' is stripped.
JPG_BACKGROUND_LIGHT="${JPG_BACKGROUND_LIGHT#\#}"
JPG_BACKGROUND_DARK="${JPG_BACKGROUND_DARK#\#}"
if ! [[ "${JPG_BACKGROUND_LIGHT}" =~ ^[0-9A-Fa-f]{6}$ ]]; then
    echo "ERROR: --jpg-background-light must be RRGGBB or #RRGGBB (got '${JPG_BACKGROUND_LIGHT}')." >&2
    exit 2
fi
if ! [[ "${JPG_BACKGROUND_DARK}" =~ ^[0-9A-Fa-f]{6}$ ]]; then
    echo "ERROR: --jpg-background-dark must be RRGGBB or #RRGGBB (got '${JPG_BACKGROUND_DARK}')." >&2
    exit 2
fi

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
RS_APP_DIR="$(echo "${RS}" | grep -oE '.*/[^/]+\.app' || true)"

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
    if [[ -n "${RS_APP_DIR}" ]]; then
        open "${RS_APP_DIR}" || true
    else
        open -a RocketSim || true
    fi
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
# going when RocketSim is unusable — not installed, not running, or unreachable over IPC —
# at the cost of losing the device bezels.
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
# NB: that crash was observed on 16.2, which the scripts no longer select now that
# AvdLee/RocketSimApp#1085 is fixed (16.4.2). Whether 16.4.x still aborts on the
# interact taps is untested, so the recovery window is kept until a run proves it dead
# code — see #813 for the retirement criterion.
RS_RECOVERY_TIMEOUT=90   # seconds to keep retrying a failed rocketsim screenshot
RS_RETRY_INTERVAL=3      # pause between retries within the recovery window

# ---------------------------------------------------------------------------
# App Store Connect accepted screenshot dimensions (portrait, 2026).
# ---------------------------------------------------------------------------
# Returns WIDTHxHEIGHT for a supported device, non-zero for unknown devices.
app_store_size_for_device() {
    case "$1" in
        "iPhone 18 Pro"|"iPhone 17 Pro"|"iPhone 16 Pro")              echo "1206x2622" ;;  # required
        "iPhone 18 Pro Max"|"iPhone 17 Pro Max"|"iPhone 16 Pro Max")  echo "1320x2868" ;;
        "iPhone 16 Plus"|"iPhone 15 Plus")                            echo "1290x2796" ;;
        "iPad Pro 13-inch (M5)"|"iPad Pro 13-inch (M4)"|"iPad Air 13-inch (M4)")  echo "2064x2752" ;;  # required
        *) return 1 ;;
    esac
}

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
else
    # Normalize user-supplied --ios-version to the "iOS X.Y" form used in simctl section
    # headers. Accepts "27", "27.0", "iOS 27", or "iOS 27.0"; matches against installed
    # runtimes so "27" expands to "iOS 27.0" when that is what is installed.
    _ver="${PREFERRED_IOS_VERSION#iOS }"
    _matched="$("${SIMCTL[@]}" list runtimes available \
        | grep -E "^iOS ${_ver}([. ]|\$)" \
        | head -1 | awk '{print $1, $2}')"
    if [[ -n "${_matched}" ]]; then
        PREFERRED_IOS_VERSION="${_matched}"
    elif [[ "${PREFERRED_IOS_VERSION}" != iOS\ * ]]; then
        PREFERRED_IOS_VERSION="iOS ${PREFERRED_IOS_VERSION}"
    fi
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
if [[ "${UDID_FROM_FLAG}" -eq 1 ]]; then
    # --udid names the device itself; resolve its model name for the label, the size lookup and the bezel.
    PREFERRED_DEVICE="$("${SIMCTL[@]}" list devices \
        | grep "${UDID}" \
        | sed -E 's/^[[:space:]]+(.+) \([0-9A-Fa-f-]{36}\).*/\1/' \
        | head -n1)"
    [[ -z "${PREFERRED_DEVICE}" ]] && PREFERRED_DEVICE="(unknown)"
fi
# RocketSim 16.7.0 applies no device frame to the iPad Pro 13-inch (M4 or M5), like the iPhone 18 Pro
# (https://github.com/AvdLee/RocketSimApp/issues/1214), so those get the generic Simulator outline instead.
# The iPad Air 13-inch (M4) does get its frame, and has the same 2064 × 2752 screen, so the iPad set is made on it.
[[ "${PREFERRED_DEVICE}" == "iPad Pro"* ]] && BEZEL="simulator"
if [[ -n "${PREFERRED_IOS_VERSION}" ]]; then
    echo "Target simulator: ${PREFERRED_DEVICE:-'(explicit)'} / ${PREFERRED_IOS_VERSION} — ${UDID}"
else
    echo "Target simulator: ${PREFERRED_DEVICE:-'(explicit)'} — ${UDID}"
fi

# ---------------------------------------------------------------------------
# Resolve App Store target dimensions (when --app-store is set).
# ---------------------------------------------------------------------------
TARGET_W=""
TARGET_H=""
if [[ "${RESCALE}" -eq 1 ]]; then
    LOOKUP_DEVICE="${PREFERRED_DEVICE}"
    APP_STORE_SIZE="$(app_store_size_for_device "${LOOKUP_DEVICE}")" || {
        echo "ERROR: --app-store: '${LOOKUP_DEVICE}' is not an accepted App Store screenshot slot." >&2
        echo "       Supported devices (portrait):" >&2
        echo "         iPhone 18 Pro, iPhone 17 Pro, iPhone 16 Pro  →  1206 × 2622" >&2
        echo "         iPhone 18 Pro Max, iPhone 17 Pro Max, iPhone 16 Pro Max  →  1320 × 2868" >&2
        echo "         iPhone 16 Plus, iPhone 15 Plus        →  1290 × 2796" >&2
        echo "         iPad Pro 13-inch (M5), iPad Pro 13-inch (M4), iPad Air 13-inch (M4)  →  2064 × 2752" >&2
        echo "       Set PREFERRED_DEVICE in this script to a supported device, or re-run with --udid <UDID of one>." >&2
        exit 2
    }
    TARGET_W="${APP_STORE_SIZE%%x*}"
    TARGET_H="${APP_STORE_SIZE##*x}"
    echo "App Store target size: ${TARGET_W} × ${TARGET_H} px (${LOOKUP_DEVICE})"
fi

JPG_DIR="${OUT_DIR}"
[[ "${RESCALE}" -eq 1 ]] && JPG_DIR="${OUT_DIR}/AppStore"
mkdir -p "${OUT_DIR}" "${JPG_DIR}"
echo "Output folder: ${OUT_DIR}"
[[ "${JPG_DIR}" != "${OUT_DIR}" ]] && echo "App Store JPGs: ${JPG_DIR}"

# ---------------------------------------------------------------------------
# Boot the simulator.
# ---------------------------------------------------------------------------
echo "Booting simulator..."
"${SIMCTL[@]}" boot "${UDID}" 2>/dev/null || true   # no-op if already booted
"${SIMCTL[@]}" bootstatus "${UDID}" -b || true
# Show the device in a window: Device Hub since Xcode 27, Simulator.app before. Capturing doesn't need the window,
# but rotating an iPad by hand does (see LANDSCAPE_SCREENS). Device Hub may still not list a simulator created with
# simctl until it has been added there once.
DEV_DIR="$(cd "$(dirname "$(xcrun --find simctl)")/../.." && pwd)"
if [[ -d "${DEV_DIR}/../Applications/DeviceHub.app" ]]; then
    open -a "${DEV_DIR}/../Applications/DeviceHub.app" --args -CurrentDeviceUDID "${UDID}" || true
elif [[ -d "${DEV_DIR}/Applications/Simulator.app" ]]; then
    open -a "${DEV_DIR}/Applications/Simulator.app" --args -CurrentDeviceUDID "${UDID}" || true
fi

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
APP_CONTAINER="$("${SIMCTL[@]}" get_app_container "${UDID}" "${BUNDLE_ID}" app 2>/dev/null)" || true
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
APP_DATA_CONTAINER="$("${SIMCTL[@]}" get_app_container "${UDID}" "${BUNDLE_ID}" data 2>/dev/null)" || true
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

# Flatten a (possibly transparent) PNG onto a solid background color and encode as JPEG.
# sips composites PNG transparency onto WHITE with no way to choose the matte color (its
# --padColor only applies to added border pixels), so the flattening is done with a small
# AppKit script instead — osascript/JXA ships with macOS, so no extra tools are needed.
# It fills a bitmap with the matte color, composites the PNG over it (sourceOver — the
# default drawInRect uses "copy", which would replace the fill), and encodes JPEG.
# Opaque PNGs (the simctl fallback) pass through visually unchanged.
# When targetW/targetH are given (--app-store), the framed PNG is aspect-fit into the target
# canvas, centered, and the remainder padded with the matte color (no distortion).
# Usage: flatten_png_to_jpg <in.png> <out.jpg> <RRGGBB> <quality 0-100> [targetW] [targetH]
flatten_png_to_jpg() {
    /usr/bin/osascript -l JavaScript - "$1" "$2" "$3" "$4" "${5:-}" "${6:-}" <<'JXA' >/dev/null
function run(argv) {
    ObjC.import("AppKit");
    const inPath = argv[0], outPath = argv[1], hex = argv[2], quality = argv[3];
    const src = $.NSBitmapImageRep.imageRepWithData($.NSData.dataWithContentsOfFile(inPath));
    if (src.isNil()) throw new Error("cannot read PNG: " + inPath);
    const sw = src.pixelsWide, sh = src.pixelsHigh;
    const tw = argv[4] ? parseInt(argv[4]) : sw;
    const th = argv[5] ? parseInt(argv[5]) : sh;
    const dst = $.NSBitmapImageRep.alloc.initWithBitmapDataPlanesPixelsWidePixelsHighBitsPerSampleSamplesPerPixelHasAlphaIsPlanarColorSpaceNameBytesPerRowBitsPerPixel(
        null, tw, th, 8, 4, true, false, $.NSDeviceRGBColorSpace, 0, 0);
    $.NSGraphicsContext.saveGraphicsState;
    $.NSGraphicsContext.setCurrentContext($.NSGraphicsContext.graphicsContextWithBitmapImageRep(dst));
    const r = parseInt(hex.slice(0, 2), 16) / 255;
    const g = parseInt(hex.slice(2, 4), 16) / 255;
    const b = parseInt(hex.slice(4, 6), 16) / 255;
    $.NSColor.colorWithDeviceRedGreenBlueAlpha(r, g, b, 1).setFill;
    $.NSRectFill($.NSMakeRect(0, 0, tw, th));
    const scale = Math.min(tw / sw, th / sh);
    const dw = Math.round(sw * scale), dh = Math.round(sh * scale);
    const ox = Math.round((tw - dw) / 2), oy = Math.round((th - dh) / 2);
    src.drawInRectFromRectOperationFractionRespectFlippedHints(
        $.NSMakeRect(ox, oy, dw, dh), $.NSMakeRect(0, 0, 0, 0),
        $.NSCompositingOperationSourceOver, 1.0, false, $());
    $.NSGraphicsContext.restoreGraphicsState;
    const jpeg = dst.representationUsingTypeProperties($.NSBitmapImageFileTypeJPEG,
        $({NSImageCompressionFactor: quality / 100}));
    if (jpeg.isNil() || !jpeg.writeToFileAtomically(outPath, true)) {
        throw new Error("cannot write JPEG: " + outPath);
    }
}
JXA
}

# Capture one framed screenshot to <NN>_<Screen>_<lang>_<appearance>.jpg (plus the .png
# unless --no-png). RocketSim always emits PNG bytes; flatten_png_to_jpg converts to JPEG
# with a white (light mode) or black (dark mode) background.
# If the capture fails (because RocketSim quit, lost its IPC channel, or crashed — see the
# RS_RECOVERY_TIMEOUT comment for the known 16.2 FBSimulatorControl crash), revive
# RocketSim via ensure_rocketsim and keep retrying for up to RS_RECOVERY_TIMEOUT seconds:
# a relaunched RocketSim answers IPC almost immediately but needs another 25–50s before
# it can see the simulator again. Only when the whole window elapses without success is
# RocketSim marked broken for the rest of the run and the unframed `simctl io screenshot`
# fallback used, so an unusable RocketSim degrades the output (no bezels) once instead
# of aborting the run.
capture() {
    local screen="$1" lang="$2" appearance="$3"
    local out="${JPG_DIR}/${CAPTURE_PREFIX}${screen}_${lang}_${appearance}.jpg"
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
    local bg
    case "${appearance}" in
        dark) bg="${JPG_BACKGROUND_DARK}" ;;
        *)    bg="${JPG_BACKGROUND_LIGHT}" ;;
    esac
    local tw="${TARGET_W}" th="${TARGET_H}"
    # A landscape capture (PortfolioLandscape) gets the landscape version of the App Store size, e.g. 2622 × 1206.
    if [[ -n "${tw}" ]]; then
        local pw ph
        pw="$(sips -g pixelWidth "${tmp}" | awk '/pixelWidth/{print $2}')"
        ph="$(sips -g pixelHeight "${tmp}" | awk '/pixelHeight/{print $2}')"
        [[ "${pw}" -gt "${ph}" ]] && { tw="${TARGET_H}"; th="${TARGET_W}"; }
    fi
    if ! flatten_png_to_jpg "${tmp}" "${out}" "${bg}" "${JPEG_QUALITY}" "${tw}" "${th}"; then
        echo "ERROR: PNG->JPEG conversion failed for ${screen}/${lang}/${appearance}." >&2
        rm -f "${tmp}"
        exit 1
    fi
    if [[ "${KEEP_PNG}" -eq 1 ]]; then
        mv -f "${tmp}" "${OUT_DIR}/${CAPTURE_PREFIX}${screen}_${lang}_${appearance}.png"
        chmod 644 "${OUT_DIR}/${CAPTURE_PREFIX}${screen}_${lang}_${appearance}.png"
        CAPTURE_FORMAT="jpg+png"
    else
        rm -f "${tmp}"
        CAPTURE_FORMAT="jpg"
    fi
}

# ---------------------------------------------------------------------------
# Warm-up launches (not captured).
#
# The first launch after an install, or on a fresh simulator, still imports most clubs while
# Maps is already on screen. Maps scrolls to its preset club as soon as that club exists, but
# the clubs imported after it shift the list, so the first Maps capture ended up at the top of
# the list instead. Later launches find the clubs already stored and scroll correctly.
# One uncaptured Maps launch, given time to finish the import, makes the first real capture
# behave like the later ones.
# MapsMuseum3D gets one too: its readiness signal waits for a map snapshot, but a snapshot is flat and
# doesn't fetch the 3D buildings the live map needs, so the first 3D capture once showed an empty grid.
# An uncaptured 3D launch puts those tiles in MapKit's cache, as a later capture of the same view found them.
# ---------------------------------------------------------------------------
WARMUP_SETTLE=20   # seconds after readiness for the remaining clubs, or the 3D buildings, to load
WARMUP_TIMEOUT=150 # a cold 3D view took 72 s to become ready on the iPad, against 6 s once cached
echo "Warm-up launches, so that the first captures don't race the first data import or the 3D tiles..."
for warmup_screen in Maps MapsMuseum3D; do
    "${SIMCTL[@]}" terminate "${UDID}" "${BUNDLE_ID}" 2>/dev/null || true
    rm -f "${READY_MARKER}"
    "${SIMCTL[@]}" launch "${UDID}" "${BUNDLE_ID}" \
        -AppleLanguages "(en)" -initialTab "${warmup_screen}" -skipPrelude YES -suppressTips YES >/dev/null
    wait_until_ready "${warmup_screen} (warm-up)" "${WARMUP_TIMEOUT}" "${WARMUP_SETTLE}"
    dismiss_first_run_interruptions
done
"${SIMCTL[@]}" terminate "${UDID}" "${BUNDLE_ID}" 2>/dev/null || true

# ---------------------------------------------------------------------------
# Capture matrix: language x appearance x tab.
# ---------------------------------------------------------------------------
CAPTURE_COUNT=0
TOTAL=$(( ${#LANGUAGES[@]} * ${#APPEARANCES[@]} * ${#SCREENS[@]} ))
TOTAL_WIDTH="${#TOTAL}"
DEVICE_LABEL="${PREFERRED_DEVICE} / ${PREFERRED_IOS_VERSION}"
# Launches one screen in one language and appearance, waits until it's ready, and captures it.
capture_screen() {
    local lang="$1" appearance="$2" screen="$3" position="$4"
    local lang_uc screen_appearance dark_screen app_cap
    lang_uc="$(printf '%s' "${lang}" | tr '[:lower:]' '[:upper:]')"
    CAPTURE_PREFIX="$(printf '%02d_' "${position}")" # listing position, used by capture() in file names
    screen_appearance="${appearance}"
    for dark_screen in "${DARK_SCREENS[@]}"; do
        [[ "${screen}" == "${dark_screen}" ]] && screen_appearance="dark"
    done
    app_cap="$(printf '%s' "${screen_appearance:0:1}" | tr '[:lower:]' '[:upper:]')${screen_appearance:1}"
    # Appearance is a device-level setting; apply before launch.
    "${SIMCTL[@]}" ui "${UDID}" appearance "${screen_appearance}"
    "${SIMCTL[@]}" terminate "${UDID}" "${BUNDLE_ID}" 2>/dev/null || true
    rm -f "${READY_MARKER}"   # the app also clears it at startup (belt and braces)
    # Prelude is the splash screen itself: launch it without -skipPrelude so it is visible.
    local skip_prelude_arg=(); [[ "${screen}" != Prelude ]] && skip_prelude_arg=(-skipPrelude YES)
    "${SIMCTL[@]}" launch "${UDID}" "${BUNDLE_ID}" \
        -AppleLanguages "(${lang})" -initialTab "${screen}" \
        ${skip_prelude_arg[@]+"${skip_prelude_arg[@]}"} -suppressTips YES >/dev/null
    if [[ "${screen}" == MapsMuseum3D ]]; then # 3D tiles load slowly
        wait_until_ready "${screen}" "${READY_TIMEOUT_PORTFOLIO}" "${SLEEP_AFTER_READY_MAPS3D}"
    elif [[ "${screen}" == Portfolio* ]]; then
        wait_until_ready "${screen}" "${READY_TIMEOUT_PORTFOLIO}" "${SLEEP_AFTER_READY_PORTFOLIO}"
    else
        wait_until_ready "${screen}" "${READY_TIMEOUT}"
    fi
    dismiss_first_run_interruptions
    capture "${screen}" "${lang}" "${screen_appearance}"
    CAPTURE_COUNT=$((CAPTURE_COUNT + 1))
    printf "%${TOTAL_WIDTH}d of %d: %s_%s_%s captured on %s as %s\n" \
        "${CAPTURE_COUNT}" "${TOTAL}" "${screen}" "${lang_uc}" "${app_cap}" "${DEVICE_LABEL}" "${CAPTURE_FORMAT}"
    sleep "${SLEEP_BETWEEN_SCREENS}"
}

# Shows a macOS notification as well as a line in the log, for the one moment a run needs a person.
notify() {
    echo ">>> $1"
    printf '\a'
    osascript -e "display notification \"$1\" with title \"capture-screenshots.sh\"" >/dev/null 2>&1 || true
}

# Waits until RocketSim delivers a picture wider than it is tall, i.e. until the device has been rotated.
# Returns non-zero after LANDSCAPE_WAIT_TIMEOUT seconds.
wait_for_landscape() {
    local probe w h waited=0
    probe="$(mktemp -t landscape-probe)" # RocketSim writes PNG bytes; sips reads them whatever the extension
    while [[ "${waited}" -lt "${LANDSCAPE_WAIT_TIMEOUT}" ]]; do
        if "${RS}" screenshot --udid "${UDID}" --bezel none > "${probe}" 2>/dev/null; then
            w="$(sips -g pixelWidth "${probe}" 2>/dev/null | awk '/pixelWidth/{print $2}')"
            h="$(sips -g pixelHeight "${probe}" 2>/dev/null | awk '/pixelHeight/{print $2}')"
            if [[ -n "${w}" && -n "${h}" && "${w}" -gt "${h}" ]]; then rm -f "${probe}"; return 0; fi
        fi
        sleep 3
        waited=$((waited + 3))
    done
    rm -f "${probe}"
    return 1
}

# On an iPad, landscape screens wait until the end (see LANDSCAPE_SCREENS), as "lang|appearance|screen|position".
IS_IPAD=0; [[ "${PREFERRED_DEVICE}" == iPad* ]] && IS_IPAD=1
DEFERRED=()
for lang in "${LANGUAGES[@]}"; do
    for appearance in "${APPEARANCES[@]}"; do
        # One fresh launch per screen: locale, initial tab, and (for non-Prelude screens) no
        # Prelude via launch arguments (see the SCREENS comment for why tabs are not tapped).
        position=0
        for screen in "${SCREENS[@]}"; do
            position=$((position + 1))
            deferred=0
            if [[ "${IS_IPAD}" -eq 1 ]]; then
                for landscape_screen in "${LANDSCAPE_SCREENS[@]}"; do
                    [[ "${screen}" == "${landscape_screen}" ]] && deferred=1
                done
            fi
            if [[ "${deferred}" -eq 1 ]]; then
                DEFERRED+=("${lang}|${appearance}|${screen}|${position}")
            else
                capture_screen "${lang}" "${appearance}" "${screen}" "${position}"
            fi
        done
    done
done

LANDSCAPE_FALLBACK=0
if [[ "${#DEFERRED[@]}" -gt 0 ]]; then
    notify "Rotate the iPad to landscape in Device Hub (${#DEFERRED[@]} landscape screenshots left)."
    if wait_for_landscape; then
        echo "iPad is in landscape."
    else
        echo "WARNING: iPad not rotated within ${LANDSCAPE_WAIT_TIMEOUT}s; capturing the landscape screens in portrait." >&2
        LANDSCAPE_FALLBACK=1
    fi
    for item in "${DEFERRED[@]}"; do
        IFS='|' read -r lang appearance screen position <<< "${item}"
        capture_screen "${lang}" "${appearance}" "${screen}" "${position}"
    done
    [[ "${LANDSCAPE_FALLBACK}" -eq 0 ]] && notify "Landscape screenshots done: you can rotate the iPad back to portrait."
fi

# ---------------------------------------------------------------------------
# Cleanup.
# ---------------------------------------------------------------------------
echo "Clearing status bar override..."
"${SIMCTL[@]}" status_bar "${UDID}" clear || true

if [[ "${KEEP_BOOTED}" -eq 0 ]]; then
    echo "Shutting simulator down..."
    "${SIMCTL[@]}" shutdown "${UDID}" || true
fi

if [[ "${LANDSCAPE_FALLBACK}" -eq 1 ]]; then
    echo "WARNING: the landscape screens (${LANDSCAPE_SCREENS[*]}) were captured in portrait: nobody rotated the iPad." >&2
fi
if [[ "${UNFRAMED_COUNT}" -gt 0 ]]; then
    echo "WARNING: ${UNFRAMED_COUNT} screenshot(s) were captured WITHOUT a device bezel" >&2
    echo "         (simctl fallback because RocketSim was not usable)." >&2
fi
echo "Done. Screenshots in: ${OUT_DIR}"
