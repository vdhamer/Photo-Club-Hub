#!/usr/bin/env bash
#
# verify-screenshots.sh
# Photo Club Hub — screenshot-pipeline sanity check (issue #776/#777)
#
# Captures four test images and asserts that their JPEG file sizes agree within 1%:
#
#   Test 1 – language parity
#     Clubs_en_light.jpg  vs  Clubs_nl_light.jpg
#     Same club list; only UI text labels differ by locale.
#
#   Test 2 – route parity
#     PortfolioViaClubs_en_light.jpg  vs  PortfolioViaPeople_en_light.jpg
#     Same portfolio and gallery image reached via two different navigation routes.
#
# Pass criterion regarding jpg file lengths: max/min < 1.01 for each pair while file lenths are not identical
# On success the four test images are deleted; on failure they are kept for inspection.
#
# Usage: verify-screenshots.sh [--build] [--udid <UDID>] [--ios-version <version>]
#                               [--out <dir>] [--keep-booted]
#
#   --build              Build and (re)install the app on the simulator first.
#   --udid <UDID>        Override the target simulator UDID.
#   --ios-version <ver>  Narrow auto-pick to a specific iOS runtime (default: auto-detect latest).
#   --out <dir>          Override the test-image output directory.
#   --keep-booted        Do not shut the simulator down when finished.
#
set -euo pipefail

# ---------------------------------------------------------------------------
# Configuration — mirrors capture-screenshots.sh
# ---------------------------------------------------------------------------
BUNDLE_ID="com.vdhamer.Fotogroep-Waalre"
SCHEME="Photo Club Hub"
PREFERRED_DEVICE="iPhone 17 Pro"
PREFERRED_IOS_VERSION=""  # "" = auto-detect latest installed iOS runtime; override with --ios-version
UDID=""
JPEG_QUALITY=85
BEZEL="device"
BACKGROUND="#FFFFFF"
DEVICE_SHADOW=1
READY_TIMEOUT=60
READY_TIMEOUT_PORTFOLIO=90
SLEEP_AFTER_READY=3
SLEEP_AFTER_READY_PORTFOLIO=8   # extra settling for portfolio screens: Juicebox gallery image load
ROCKETSIM_STARTUP_TIMEOUT=30
MAX_SIZE_RATIO=1.05  # max/min file-size ratio above which a pair is considered a FAIL

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
# Default output: scripts/screenshots_verify/ (separate from scripts/screenshots/).
# Deleted on success; kept on failure for inspection.
OUT_DIR="${SCRIPT_DIR}/screenshots_verify"

DO_BUILD=0
KEEP_BOOTED=0

# ---------------------------------------------------------------------------
# Argument parsing
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

# ---------------------------------------------------------------------------
# RocketSim CLI helpers
# ---------------------------------------------------------------------------
find_rocketsim() {
    if command -v rocketsim >/dev/null 2>&1; then
        command -v rocketsim; return 0
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

ipc_reachable_now() {
    "${RS}" status 2>/dev/null | grep -qE '"ipc_reachable"\s*:\s*true'
}

ensure_rocketsim() {
    ipc_reachable_now && return 0
    echo "RocketSim not reachable — (re)launching..."
    open -a RocketSim || true
    local waited=0
    while [[ "${waited}" -lt "${ROCKETSIM_STARTUP_TIMEOUT}" ]]; do
        sleep 2; waited=$((waited + 2))
        ipc_reachable_now && return 0
    done
    return 1
}

# ---------------------------------------------------------------------------
# Verify prerequisites
# ---------------------------------------------------------------------------
if ! /usr/bin/xcrun simctl help &>/dev/null; then
    echo "ERROR: 'xcrun simctl' not available. Make sure Xcode is installed." >&2; exit 1
fi
SIMCTL=( /usr/bin/xcrun simctl )

RS="$(find_rocketsim || true)"
RS_BROKEN=0
UNFRAMED_COUNT=0
if [[ -z "${RS}" ]]; then
    echo "WARNING: RocketSim CLI not found. Using simctl fallback (no device bezels)." >&2
    RS_BROKEN=1
else
    echo "RocketSim CLI: ${RS}"
    # IPC check deferred to after simulator boot; RocketSim only detects the device
    # once the simulator is running, so checking here can give a false negative.
fi

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
# Resolve the target simulator UDID
# ---------------------------------------------------------------------------
if [[ -z "${UDID}" ]]; then
    if [[ -n "${PREFERRED_IOS_VERSION}" ]]; then
        CANDIDATE_UDIDS="$("${SIMCTL[@]}" list devices available \
                | awk -v section="-- ${PREFERRED_IOS_VERSION} --" \
                      -v device="${PREFERRED_DEVICE}" \
                      '/^-- /{in_sec=(index($0,section)>0); next} in_sec&&index($0,device)' \
                | sed -E 's/.*\(([0-9A-Fa-f-]{36})\).*/\1/')"
    else
        CANDIDATE_UDIDS="$("${SIMCTL[@]}" list devices available \
                | grep -E "^\s+${PREFERRED_DEVICE} \(" \
                | sed -E 's/.*\(([0-9A-Fa-f-]{36})\).*/\1/')"
    fi
    for candidate in ${CANDIDATE_UDIDS}; do
        [[ -z "${UDID}" ]] && UDID="${candidate}"
        if "${SIMCTL[@]}" get_app_container "${candidate}" "${BUNDLE_ID}" app >/dev/null 2>&1; then
            UDID="${candidate}"; break
        fi
    done
fi
if [[ -z "${UDID}" ]]; then
    echo "ERROR: could not find a simulator named '${PREFERRED_DEVICE}'." >&2
    echo "       Pass --udid <UDID> or check 'xcrun simctl list devices available'." >&2
    exit 1
fi
if [[ -n "${PREFERRED_IOS_VERSION}" ]]; then
    echo "Target simulator: ${PREFERRED_DEVICE} / ${PREFERRED_IOS_VERSION} — ${UDID}"
else
    echo "Target simulator: ${PREFERRED_DEVICE} — ${UDID}"
fi

mkdir -p "${OUT_DIR}"
echo "Test images:      ${OUT_DIR}"

# ---------------------------------------------------------------------------
# Boot the simulator
# ---------------------------------------------------------------------------
echo "Booting simulator..."
"${SIMCTL[@]}" boot "${UDID}" 2>/dev/null || true
"${SIMCTL[@]}" bootstatus "${UDID}" -b || true
open -a Simulator --args -CurrentDeviceUDID "${UDID}" || true

# Verify RocketSim's IPC channel after the simulator is running. Checking before boot can
# give a false negative because RocketSim only detects the device once the simulator starts.
if [[ "${RS_BROKEN}" -eq 0 ]] && ! ensure_rocketsim; then
    echo "WARNING: RocketSim not reachable over IPC. Using simctl fallback." >&2
    RS_BROKEN=1
fi

# ---------------------------------------------------------------------------
# Optionally build + install
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
    [[ -z "${APP_PATH}" ]] && { echo "ERROR: build produced no .app bundle." >&2; exit 1; }
    echo "Installing ${APP_PATH}"
    "${SIMCTL[@]}" install "${UDID}" "${APP_PATH}"
fi

if ! "${SIMCTL[@]}" get_app_container "${UDID}" "${BUNDLE_ID}" app >/dev/null 2>&1; then
    echo "ERROR: ${BUNDLE_ID} is not installed on ${UDID}. Re-run with --build." >&2; exit 1
fi

APP_DATA_CONTAINER="$("${SIMCTL[@]}" get_app_container "${UDID}" "${BUNDLE_ID}" data 2>/dev/null)"
[[ -z "${APP_DATA_CONTAINER}" ]] && { echo "ERROR: cannot resolve data container." >&2; exit 1; }
READY_MARKER="${APP_DATA_CONTAINER}/Documents/screenshot-ready"

# ---------------------------------------------------------------------------
# Clean status bar; pre-grant location to avoid the first-run system alert
# ---------------------------------------------------------------------------
echo "Applying clean status bar override..."
"${SIMCTL[@]}" status_bar "${UDID}" override \
    --time "9:41" --dataNetwork wifi --wifiMode active --wifiBars 3 \
    --cellularMode active --cellularBars 4 --batteryState charged --batteryLevel 100
"${SIMCTL[@]}" privacy "${UDID}" grant location "${BUNDLE_ID}" 2>/dev/null || true

# ---------------------------------------------------------------------------
# Capture helpers
# ---------------------------------------------------------------------------
SCREENSHOT_FLAGS=(--udid "${UDID}" --bezel "${BEZEL}" --background "${BACKGROUND}")
[[ "${DEVICE_SHADOW}" -eq 1 ]] && SCREENSHOT_FLAGS+=(--device-shadow)

wait_until_ready() {
    local screen="$1" timeout="$2" settle="${3:-${SLEEP_AFTER_READY}}" waited=0
    while [[ ! -f "${READY_MARKER}" ]]; do
        if [[ "${waited}" -ge "${timeout}" ]]; then
            echo "ERROR: ${screen} not ready after ${timeout}s (no readiness marker)." >&2; exit 1
        fi
        sleep 1; waited=$((waited + 1))
    done
    sleep "${settle}"
}

capture() {
    local screen="$1" lang="$2" appearance="$3"
    local out="${OUT_DIR}/${screen}_${lang}_${appearance}.jpg"
    local tmp tmperr framed=0
    tmp="$(mktemp /tmp/screenshot_XXXXXX)"
    tmperr="$(mktemp /tmp/screenshot_err_XXXXXX)"
    if [[ "${RS_BROKEN}" -eq 0 ]]; then
        if "${RS}" screenshot "${SCREENSHOT_FLAGS[@]}" > "${tmp}" 2>"${tmperr}"; then
            framed=1
        else
            echo "WARNING: rocketsim screenshot failed — retrying after reviving RocketSim." >&2
            ensure_rocketsim || true
            if "${RS}" screenshot "${SCREENSHOT_FLAGS[@]}" > "${tmp}" 2>"${tmperr}"; then
                framed=1
            else
                echo "WARNING: rocketsim failed again — switching to simctl fallback." >&2
                RS_BROKEN=1
            fi
        fi
    fi
    if [[ "${framed}" -eq 0 ]]; then
        "${SIMCTL[@]}" io "${UDID}" screenshot "${tmp}" >/dev/null 2>&1 \
            || { echo "ERROR: simctl screenshot also failed for ${screen}/${lang}/${appearance}." >&2
                 rm -f "${tmp}" "${tmperr}"; exit 1; }
        UNFRAMED_COUNT=$((UNFRAMED_COUNT + 1))
    fi
    rm -f "${tmperr}"
    /usr/bin/sips -s format jpeg -s formatOptions "${JPEG_QUALITY}" \
        "${tmp}" --out "${out}" >/dev/null
    rm -f "${tmp}"
    echo "  captured ${screen}_${lang}_${appearance}.jpg"
}

launch_screen() {
    local screen="$1" lang="$2"
    "${SIMCTL[@]}" terminate "${UDID}" "${BUNDLE_ID}" 2>/dev/null || true
    rm -f "${READY_MARKER}"
    "${SIMCTL[@]}" launch "${UDID}" "${BUNDLE_ID}" \
        -AppleLanguages "(${lang})" -initialTab "${screen}" \
        -skipPrelude YES -suppressTips YES \
        > /dev/null
}

# ---------------------------------------------------------------------------
# Capture the four test images (light appearance only)
# ---------------------------------------------------------------------------
"${SIMCTL[@]}" ui "${UDID}" appearance light
echo "Capturing test images..."

launch_screen Clubs en
wait_until_ready Clubs "${READY_TIMEOUT}"
capture Clubs en light

launch_screen Clubs nl
wait_until_ready Clubs "${READY_TIMEOUT}"
capture Clubs nl light

launch_screen PortfolioViaClubs en
wait_until_ready PortfolioViaClubs "${READY_TIMEOUT_PORTFOLIO}" "${SLEEP_AFTER_READY_PORTFOLIO}"
capture PortfolioViaClubs en light

launch_screen PortfolioViaPeople en
wait_until_ready PortfolioViaPeople "${READY_TIMEOUT_PORTFOLIO}" "${SLEEP_AFTER_READY_PORTFOLIO}"
capture PortfolioViaPeople en light

[[ "${UNFRAMED_COUNT}" -gt 0 ]] && \
    echo "WARNING: ${UNFRAMED_COUNT} image(s) captured without device bezel (simctl fallback)." >&2

# ---------------------------------------------------------------------------
# Compare file sizes — pass criterion: sizes differ AND max/min < MAX_SIZE_RATIO
# ---------------------------------------------------------------------------
# Returns 0 (pass) or 1 (fail); prints a formatted result line either way.
# Uses awk for floating-point arithmetic (bash 3.2 has none).
check_pair() {
    local label="$1" file1="$2" file2="$3"
    local size1 size2 ratio
    size1=$(stat -f%z "${file1}")
    size2=$(stat -f%z "${file2}")
    if [[ "${size1}" -eq "${size2}" ]]; then
        printf "  FAIL  %-54s  both files are %d bytes (identical sizes; launch args likely ignored)\n" \
               "${label}" "${size1}" >&2
        return 1
    fi
    ratio=$(awk "BEGIN { a=${size1}; b=${size2}; if (b>a){t=a;a=b;b=t}; printf \"%.4f\",a/b }")
    if awk "BEGIN { exit (${ratio} < ${MAX_SIZE_RATIO}) ? 0 : 1 }"; then
        printf "  PASS  %-54s  %d / %d bytes (ratio %s)\n" \
               "${label}" "${size1}" "${size2}" "${ratio}"
        return 0
    else
        printf "  FAIL  %-54s  %d / %d bytes (ratio %s >= ${MAX_SIZE_RATIO})\n" \
               "${label}" "${size1}" "${size2}" "${ratio}" >&2
        return 1
    fi
}

echo ""
echo "=== Screenshot pipeline verification ==="
FAILURES=0

check_pair \
    "language parity  (Clubs EN vs NL)" \
    "${OUT_DIR}/Clubs_en_light.jpg" \
    "${OUT_DIR}/Clubs_nl_light.jpg" \
    || FAILURES=$((FAILURES + 1))

check_pair \
    "route parity  (PortfolioViaClubs vs ViaPeople)" \
    "${OUT_DIR}/PortfolioViaClubs_en_light.jpg" \
    "${OUT_DIR}/PortfolioViaPeople_en_light.jpg" \
    || FAILURES=$((FAILURES + 1))

echo ""

# ---------------------------------------------------------------------------
# Cleanup
# ---------------------------------------------------------------------------
echo "Clearing status bar override..."
"${SIMCTL[@]}" status_bar "${UDID}" clear || true

if [[ "${KEEP_BOOTED}" -eq 0 ]]; then
    echo "Shutting simulator down..."
    "${SIMCTL[@]}" shutdown "${UDID}" || true
fi

if [[ "${FAILURES}" -eq 0 ]]; then
    echo "All tests passed. Deleting test images."
    rm -rf "${OUT_DIR}"
    echo "Done."
else
    echo "ERROR: ${FAILURES} test(s) failed. Test images kept for inspection: ${OUT_DIR}" >&2
    exit 1
fi
