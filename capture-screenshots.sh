#!/usr/bin/env bash
#
# capture-screenshots.sh
# Photo Club Hub — documentation screenshot pipeline (GitHub issue #775, part of #774)
#
# Captures framed screenshots of the four tab screens (Maps / Clubs / People / Settings)
# across the EN/NL x light/dark matrix, using the RocketSim CLI for tab navigation and
# device-framed captures, plus `xcrun simctl` for a clean status bar and appearance.
#
# Output: PNGs named <Screen>_<lang>_<appearance>.png in the output folder (see OUT_DIR).
#
# Scope (per #775):
#   - The four TAB screens only. Non-tab screens (Portfolio detail, Readme sheet, Prelude
#     capture) are ticket #777 and are NOT handled here.
#   - Waits are simple `sleep`s. Content-readiness polling and TipKit tip suppression are
#     ticket #776 and are deliberately NOT implemented here.
#
# Requirements:
#   - RocketSim.app installed AND running (the CLI talks to the running app over IPC).
#     The CLI binary ships inside the app bundle; this script locates it automatically.
#   - Xcode command-line tools (`xcrun simctl`).
#   - The app already built & installed on the target simulator, OR pass --build to have
#     this script build+install it for you.
#   - Written for macOS's stock bash 3.2 (no associative arrays / namerefs / mapfile).
#
# Usage:
#   Scripts/capture-screenshots.sh [--build] [--udid <UDID>] [--out <dir>] [--keep-booted]
#
#   --build         Build the app for the target simulator and (re)install it first.
#   --udid <UDID>   Override the target simulator UDID (default: auto-pick iPhone 17 Pro).
#   --out <dir>     Override the output directory (default: <repo>/Scripts/screenshots).
#   --keep-booted   Do not shut the simulator down when finished.
#
set -euo pipefail

# ---------------------------------------------------------------------------
# Configuration — clear, editable variables at the top.
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

# Tab labels per locale. Order matches MainTabView1827.swift and issue #773:
#   maps, clubs, people, settings.
# RocketSim taps by label text, so the NL run must use the Dutch labels from
# Localization/PhotoClubHub.SwiftUI.xcstrings. Screen name (file prefix) stays English.
# (Stock macOS bash is 3.2, which lacks associative arrays, so this is a small function
#  mapping screen+locale -> the on-screen tab label.)
TAB_SCREENS=(Maps Clubs People Settings)
tab_label() {  # tab_label <Screen> <lang>
    case "$1/$2" in
        Maps/en)     echo "Maps" ;;
        Maps/nl)     echo "Kaarten" ;;
        Clubs/en)    echo "Clubs" ;;
        Clubs/nl)    echo "Clubs" ;;
        People/en)   echo "People" ;;
        People/nl)   echo "Personen" ;;
        Settings/en) echo "Settings" ;;
        Settings/nl) echo "Instellingen" ;;
        *) echo "ERROR: no label for $1/$2" >&2; return 1 ;;
    esac
}

# Framing options for `rocketsim screenshot`.
BEZEL="device"          # device frame style: none | simulator | device
BACKGROUND="#FFFFFF"    # background color behind the framed device
DEVICE_SHADOW=1         # 1 = render a shadow behind the device frame

# Simple placeholder waits (seconds). Replaced by content polling in #776.
SLEEP_AFTER_LAUNCH=6    # app launch + Prelude appears
SLEEP_AFTER_PRELUDE=3   # Prelude dismiss animation + first tab settles
SLEEP_AFTER_TAB=3       # tab switch + content settle before capturing

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

# Dismiss the Prelude splash. The Prelude exits via a background tap (onFinished) or the
# "Next" button. A center tap would trigger its zoom animation instead, so we tap the
# "Next" button by its accessibility label, falling back to a near-corner background tap.
dismiss_prelude() {
    if ! "${RS}" interact tap --label "Next" --timeout 4 --udid "${UDID}" 2>/dev/null; then
        echo "  (Prelude 'Next' not found — tapping background corner to dismiss)"
        "${RS}" interact tap 30 90 --udid "${UDID}" 2>/dev/null || true
    fi
}

# Best-effort dismissal of first-run interruptions that can sit over the tabs:
#   - a leftover location permission alert (if the pre-grant above didn't take)
#   - the built-in Readme sheet, which can auto-present on first run
# Each tap is a no-op if the element isn't present. Thorough first-run/tip handling
# (incl. TipKit) is ticket #776; this is only enough to unblock the four tab captures.
dismiss_first_run_interruptions() {
    "${RS}" interact tap --label "Allow While Using App" --timeout 1 --udid "${UDID}" 2>/dev/null || true
    "${RS}" interact tap --label "Sta toe tijdens gebruik" --timeout 1 --udid "${UDID}" 2>/dev/null || true
    "${RS}" interact tap --label "Close" --type Button --timeout 1 --udid "${UDID}" 2>/dev/null || true
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

        # Relaunch fresh each cell so the Prelude reappears and the locale takes effect.
        xcrun simctl terminate "${UDID}" "${BUNDLE_ID}" 2>/dev/null || true
        xcrun simctl launch "${UDID}" "${BUNDLE_ID}" -AppleLanguages "(${lang})"
        sleep "${SLEEP_AFTER_LAUNCH}"

        dismiss_prelude
        sleep "${SLEEP_AFTER_PRELUDE}"
        dismiss_first_run_interruptions
        sleep 1

        for screen in "${TAB_SCREENS[@]}"; do
            local_label="$(tab_label "${screen}" "${lang}")"
            echo "-- tab: ${screen} (label='${local_label}')"
            "${RS}" interact tap --label "${local_label}" --timeout 6 --udid "${UDID}" \
                || echo "  WARNING: could not tap tab '${local_label}'"
            sleep "${SLEEP_AFTER_TAB}"
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
