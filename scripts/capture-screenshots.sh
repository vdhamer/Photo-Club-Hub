#!/usr/bin/env bash
#
# capture-screenshots.sh
# Photo Club Hub — documentation screenshot pipeline (GitHub issue #774 and subissues)
#
# Captures framed screenshots of the four tab screens (Maps / Clubs / People / Settings)
# across the EN/NL x light/dark matrix.
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
#   - The four TAB screens only. Non-tab screens (Portfolio detail, Readme sheet, Prelude
#     capture) are ticket #777 and are NOT handled here.
#   - Waits are simple `sleep`s. Content-readiness polling and TipKit tip suppression are
#     ticket #776 and are deliberately NOT implemented here.
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
# Arguments:
# ---------------------------------------------------------------------------
# App launch arguments (passed to `xcrun simctl launch`; `-key value` pairs become one-shot
# UserDefaults overrides in the app — they are never persisted):
#
#   -AppleLanguages "(en)"|"(nl)"   iOS-defined: UI language for this launch
#   -initialTab <Maps|Clubs|People|Settings>
#                                   app-defined (MainTabView1827.swift): open directly on
#                                   this tab, canonical English names in any locale
#   -skipPrelude YES                app-defined (RootView.swift): start on the main tabs
#                                   without the Prelude splash screen
# Tip: the full list of keys the app responds to can be found with
#   grep -rn 'UserDefaults.standard' --include='*.swift' 'Photo Club Hub' | grep forKey
#
# Usage:
#
#   Scripts/capture-screenshots.sh [--build] [--udid <UDID>] [--out <dir>] [--keep-booted]
#   --build         Build the app for the target simulator and (re)install it first.
#   --udid <UDID>   Override the target simulator UDID (default: auto-pick iPhone 17 Pro).
#   --out <dir>     Override the output directory (default: <repo>/scripts/screenshots).
#   --keep-booted   Do not shut the simulator down when finished.
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
UDID=""            # resolved below (or from --udid)

# Matrix.
LANGUAGES=(en nl)
APPEARANCES=(light dark)

# The four tab screens, in tab bar order (MainTabView1827.swift / issue #773).
# Navigation does NOT tap the tab bar: RocketSim's element tree omits tab buttons when the
# app runs in a non-English locale (https://github.com/AvdLee/RocketSimApp/issues/1083),
# so the script relaunches the app
# once per screen with the `-initialTab <Screen>` launch argument instead (canonical English
# names, handled in MainTabView1827.swift). `-skipPrelude YES` suppresses the splash screen.
# This is locale-independent and also more deterministic than tap choreography.
TAB_SCREENS=(Maps Clubs People Settings)

# Framing options for `rocketsim screenshot`.
BEZEL="device"          # device frame style: none | simulator | device
BACKGROUND="#FFFFFF"    # background color behind the framed device
DEVICE_SHADOW=1         # 1 = render a shadow behind the device frame

# Simple placeholder waits (seconds). Replaced by content polling in #776.
SLEEP_AFTER_LAUNCH=8    # app launch (Prelude skipped) + network content settling

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
        --out)         OUT_DIR="${2:?--out needs a value}"; shift 2 ;;
        --keep-booted) KEEP_BOOTED=1; shift ;;
        -h|--help)     grep -E '^# ' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
        *)             echo "Unknown argument: $1" >&2; exit 2 ;;
    esac
done

RS="$(find_rocketsim || true)"
if [[ -z "${RS}" ]]; then
    echo "ERROR: RocketSim CLI not found." >&2
    echo "  Install RocketSim.app, or enable its CLI from the app's menu, then retry." >&2
    exit 1
fi
echo "RocketSim CLI: ${RS}"

# The CLI needs the RocketSim app running (IPC). Nudge it, then verify.
if ! "${RS}" status 2>/dev/null | grep -q '"ipc_reachable":true'; then
    echo "RocketSim app not reachable — launching it..."
    open -a RocketSim || true
    # Give the app a moment to come up and open its IPC channel.
    for _ in 1 2 3 4 5 6 7 8; do
        sleep 2
        "${RS}" status 2>/dev/null | grep -q '"ipc_reachable":true' && break
    done
fi
if ! "${RS}" status 2>/dev/null | grep -q '"ipc_reachable":true'; then
    echo "ERROR: RocketSim app is installed but not reachable over IPC." >&2
    echo "       Open RocketSim.app manually and ensure its CLI is enabled." >&2
    exit 1
fi

# ---------------------------------------------------------------------------
# Resolve the target simulator UDID.
# ---------------------------------------------------------------------------
if [[ -z "${UDID}" ]]; then
    # Grab the first available simulator whose name exactly matches PREFERRED_DEVICE.
    UDID="$(xcrun simctl list devices available \
            | grep -E "^\s+${PREFERRED_DEVICE} \(" \
            | head -n1 \
            | sed -E 's/.*\(([0-9A-Fa-f-]{36})\).*/\1/')"
fi
if [[ -z "${UDID}" ]]; then
    echo "ERROR: could not find an available simulator named '${PREFERRED_DEVICE}'." >&2
    echo "       Pick one from 'xcrun simctl list devices available' and pass --udid." >&2
    exit 1
fi
echo "Target simulator: ${PREFERRED_DEVICE:-'(explicit)'} — ${UDID}"

mkdir -p "${OUT_DIR}"
echo "Output folder: ${OUT_DIR}"

# ---------------------------------------------------------------------------
# Boot the simulator.
# ---------------------------------------------------------------------------
echo "Booting simulator..."
xcrun simctl boot "${UDID}" 2>/dev/null || true   # no-op if already booted
xcrun simctl bootstatus "${UDID}" -b || true
open -a Simulator --args -CurrentDeviceUDID "${UDID}" || true

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
    xcrun simctl install "${UDID}" "${APP_PATH}"
fi

# ---------------------------------------------------------------------------
# Clean status bar: 9:41, full battery, full signal (Apple marketing default).
# ---------------------------------------------------------------------------
echo "Applying clean status bar override..."
xcrun simctl status_bar "${UDID}" override \
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
xcrun simctl privacy "${UDID}" grant location "${BUNDLE_ID}" 2>/dev/null || true

# ---------------------------------------------------------------------------
# Helpers.
# ---------------------------------------------------------------------------

# Common screenshot flags (populated once, below).
SCREENSHOT_FLAGS=(--udid "${UDID}" --bezel "${BEZEL}" --background "${BACKGROUND}")
[[ "${DEVICE_SHADOW}" -eq 1 ]] && SCREENSHOT_FLAGS+=(--device-shadow)

# Best-effort dismissal of first-run interruptions that can sit over the tabs:
#   - a leftover location permission alert (if the pre-grant above didn't take)
#   - the built-in Readme sheet, which can auto-present on first run
# Each tap is a no-op if the element isn't present. Thorough first-run/tip handling
# (incl. TipKit) is ticket #776; this is only enough to unblock the four tab captures.
dismiss_first_run_interruptions() {
    # "element_not_found" is the normal case; suppress stdout too (the CLI prints errors as JSON there).
    "${RS}" interact tap --label "Allow While Using App" --timeout 1 --udid "${UDID}" >/dev/null 2>&1 || true
    "${RS}" interact tap --label "Sta toe tijdens gebruik" --timeout 1 --udid "${UDID}" >/dev/null 2>&1 || true
    "${RS}" interact tap --label "Close" --type Button --timeout 1 --udid "${UDID}" >/dev/null 2>&1 || true
}

# Capture one framed screenshot to <Screen>_<lang>_<appearance>.png.
capture() {
    local screen="$1" lang="$2" appearance="$3"
    local out="${OUT_DIR}/${screen}_${lang}_${appearance}.png"
    "${RS}" screenshot "${SCREENSHOT_FLAGS[@]}" > "${out}"
    echo "  saved ${out}"
}

# ---------------------------------------------------------------------------
# Capture matrix: language x appearance x tab.
# ---------------------------------------------------------------------------
for lang in "${LANGUAGES[@]}"; do
    for appearance in "${APPEARANCES[@]}"; do
        echo "=== ${lang} / ${appearance} ==="

        # Appearance is a device-level setting; apply before launch.
        xcrun simctl ui "${UDID}" appearance "${appearance}"

        # One fresh launch per screen: locale, initial tab, and no Prelude via launch
        # arguments (see the TAB_SCREENS comment above for why tabs are not tapped).
        for screen in "${TAB_SCREENS[@]}"; do
            echo "-- screen: ${screen}"
            xcrun simctl terminate "${UDID}" "${BUNDLE_ID}" 2>/dev/null || true
            xcrun simctl launch "${UDID}" "${BUNDLE_ID}" \
                -AppleLanguages "(${lang})" -initialTab "${screen}" -skipPrelude YES
            sleep "${SLEEP_AFTER_LAUNCH}"
            dismiss_first_run_interruptions
            capture "${screen}" "${lang}" "${appearance}"
        done
    done
done

# ---------------------------------------------------------------------------
# Cleanup.
# ---------------------------------------------------------------------------
echo "Clearing status bar override..."
xcrun simctl status_bar "${UDID}" clear || true

if [[ "${KEEP_BOOTED}" -eq 0 ]]; then
    echo "Shutting simulator down..."
    xcrun simctl shutdown "${UDID}" || true
fi

echo "Done. Screenshots in: ${OUT_DIR}"
