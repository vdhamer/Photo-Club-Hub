#!/usr/bin/env bash
#
# check-rocketsim-bug-1085.sh
# Photo Club Hub — canary test for AvdLee/RocketSimApp#1085
#
# Probes whether the RocketSim 16.3/16.4 SIGTRAP crash in
# FBSimulatorControl.inferSimulatorConfiguration(fromDevice:) is still present.
# That crash fires on every CLI screenshot request and also on manual in-app
# screenshots; capture-screenshots.sh and verify-screenshots.sh work around it
# by falling back to unframed `xcrun simctl io screenshot`.
#
# EXIT SEMANTICS — intentionally inverted, because this test tracks a KNOWN BUG:
#   0  PASS    bug still present  — screenshot crashed RocketSim; workaround still needed
#   1  FAIL    bug is FIXED       — screenshot succeeded; simplify both screenshot scripts
#   2  SKIP    inconclusive       — prerequisite missing, or screenshot failed for an
#                                   unrelated reason (IPC still alive after the failure)
#
# When this script starts exiting 1 (FAIL), that is GOOD NEWS: the upstream bug has
# been resolved and the RS_BROKEN fallback paths in capture-screenshots.sh and
# verify-screenshots.sh can be removed. See the ACTION block in the FAIL output.
#
# This script intentionally targets RocketSim.app (the current/potentially broken
# version) and NOT "RocketSim 16.2.app" (the pre-bug pinned workaround). If only
# the 16.2 workaround is installed it exits 2 (SKIP).
#
# Usage: scripts/check-rocketsim-bug-1085.sh [--udid <UDID>] [--ios-version <version>]
#
#   --udid <UDID>          Use a specific simulator (default: auto-pick iPhone 17 Pro).
#   --ios-version <ver>    Narrow auto-pick to a runtime (default: latest installed).
#
set -uo pipefail    # no -e: exit codes are captured and checked manually below

PREFERRED_DEVICE="iPhone 17 Pro"
PREFERRED_IOS_VERSION=""
UDID=""
ROCKETSIM_STARTUP_TIMEOUT=30

# ---------------------------------------------------------------------------
# Argument parsing
# ---------------------------------------------------------------------------
while [[ $# -gt 0 ]]; do
    case "$1" in
        --udid)        UDID="${2:?--udid needs a value}"; shift 2 ;;
        --ios-version) PREFERRED_IOS_VERSION="${2?--ios-version needs a value}"; shift 2 ;;
        -h|--help)     grep -E '^# ' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
        *)             echo "Unknown argument: $1" >&2; exit 2 ;;
    esac
done

# ---------------------------------------------------------------------------
# Locate the latest RocketSim CLI.
# Intentionally searches RocketSim.app first, NOT "RocketSim 16.2.app".
# The pre-bug 16.2 is only a fallback: if it is the only one present, the
# bug cannot be probed and we exit 2 (SKIP).
# ---------------------------------------------------------------------------
find_rocketsim_latest() {
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

RS="$(find_rocketsim_latest 2>/dev/null || true)"
if [[ -z "${RS}" ]]; then
    if [[ -x "/Applications/RocketSim 16.2.app/Contents/Helpers/rocketsim" ]] ||
       [[ -x "${HOME}/Applications/RocketSim 16.2.app/Contents/Helpers/rocketsim" ]]; then
        echo "SKIP: only 'RocketSim 16.2.app' is installed — it predates the bug." >&2
        echo "      Install the current RocketSim.app alongside to probe issue #1085." >&2
    else
        echo "SKIP: no RocketSim CLI found." >&2
        echo "      Install RocketSim.app and enable its CLI from the app's Preferences." >&2
    fi
    exit 2
fi

# Guard against accidentally probing the pre-bug workaround via PATH.
if [[ "${RS}" == *"RocketSim 16.2"* ]]; then
    echo "SKIP: CLI at '${RS}' is from RocketSim 16.2 — predates the bug." >&2
    echo "      Install the current RocketSim.app to probe issue #1085." >&2
    exit 2
fi

echo "RocketSim CLI : ${RS}"

# Derive the app bundle path for relaunching (handles spaces in the name).
RS_APP_DIR="$(echo "${RS}" | grep -oE '.*/[^/]+\.app' || true)"

# Read the bundle version from Info.plist for diagnostic output.
if [[ -n "${RS_APP_DIR}" ]]; then
    RS_BUNDLE_VERSION="$(defaults read "${RS_APP_DIR}/Contents/Info" \
        CFBundleShortVersionString 2>/dev/null || true)"
    [[ -n "${RS_BUNDLE_VERSION}" ]] && echo "RocketSim ver : ${RS_BUNDLE_VERSION}"
fi
echo "Upstream bug  : https://github.com/AvdLee/RocketSimApp/issues/1085"

# ---------------------------------------------------------------------------
# xcrun simctl
# ---------------------------------------------------------------------------
if ! /usr/bin/xcrun simctl help &>/dev/null; then
    echo "SKIP: xcrun simctl not available. Make sure Xcode is installed." >&2; exit 2
fi
SIMCTL=( /usr/bin/xcrun simctl )

# ---------------------------------------------------------------------------
# Auto-detect the latest iOS runtime when PREFERRED_IOS_VERSION is empty.
# ---------------------------------------------------------------------------
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
    [[ -z "${PREFERRED_IOS_VERSION}" ]] && { echo "SKIP: no iOS runtimes found." >&2; exit 2; }
fi
echo "iOS runtime   : ${PREFERRED_IOS_VERSION}"

# ---------------------------------------------------------------------------
# Resolve the target simulator UDID.
# ---------------------------------------------------------------------------
if [[ -z "${UDID}" ]]; then
    CANDIDATE_UDIDS="$("${SIMCTL[@]}" list devices available \
            | awk -v section="-- ${PREFERRED_IOS_VERSION} --" \
                  -v device="${PREFERRED_DEVICE}" \
                  '/^-- /{in_sec=(index($0,section)>0); next} in_sec&&index($0,device)' \
            | sed -E 's/.*\(([0-9A-Fa-f-]{36})\).*/\1/')"
    UDID="$(echo "${CANDIDATE_UDIDS}" | head -n1)"
fi
if [[ -z "${UDID}" ]]; then
    echo "SKIP: no simulator found for '${PREFERRED_DEVICE}' / ${PREFERRED_IOS_VERSION}." >&2
    echo "      Pass --udid <UDID> to override (see 'xcrun simctl list devices available')." >&2
    exit 2
fi
echo "Simulator     : ${UDID}"
echo ""

# ---------------------------------------------------------------------------
# Boot the simulator (no-op if already booted).
# ---------------------------------------------------------------------------
echo "Booting simulator..."
"${SIMCTL[@]}" boot "${UDID}" 2>/dev/null || true
"${SIMCTL[@]}" bootstatus "${UDID}" -b 2>/dev/null || true
open -a Simulator --args -CurrentDeviceUDID "${UDID}" 2>/dev/null || true

# ---------------------------------------------------------------------------
# Ensure the latest RocketSim is running and its IPC channel is open.
# RocketSim only detects the simulator after it is booted, so IPC is checked
# after boot rather than earlier.
# ---------------------------------------------------------------------------
ipc_reachable_now() {
    "${RS}" status 2>/dev/null | grep -qE '"ipc_reachable"\s*:\s*true'
}

ensure_rocketsim_latest() {
    ipc_reachable_now && return 0
    echo "RocketSim not reachable — (re)launching..."
    if [[ -n "${RS_APP_DIR}" ]]; then
        open "${RS_APP_DIR}" 2>/dev/null || true
    else
        open -a RocketSim 2>/dev/null || true
    fi
    local waited=0
    while [[ "${waited}" -lt "${ROCKETSIM_STARTUP_TIMEOUT}" ]]; do
        sleep 2; waited=$((waited + 2))
        ipc_reachable_now && return 0
    done
    return 1
}

echo "Checking RocketSim IPC..."
if ! ensure_rocketsim_latest; then
    echo "SKIP: RocketSim IPC not reachable after ${ROCKETSIM_STARTUP_TIMEOUT}s." >&2
    echo "      Make sure RocketSim.app is not blocked by macOS privacy settings." >&2
    exit 2
fi
echo "RocketSim IPC : reachable"
echo ""

# ---------------------------------------------------------------------------
# Probe: attempt one screenshot and observe whether RocketSim survives.
#
# If bug #1085 is present: rocketsim crashes (SIGTRAP), the IPC channel dies,
# and the CLI exits non-zero. We verify the crash by checking IPC immediately
# after the failure — if IPC is dark, RocketSim crashed.
#
# If the bug is fixed: rocketsim screenshot exits 0.
# ---------------------------------------------------------------------------
TMP_PNG="$(mktemp /tmp/check_rocketsim_1085_XXXXXX)"
echo "Probing screenshot (exit 0 = bug fixed; non-zero + IPC dark = still present):"
echo "  ${RS} screenshot --udid ${UDID} --bezel device --background transparent"
SCREENSHOT_EXIT=0
"${RS}" screenshot --udid "${UDID}" --bezel device --background transparent \
    > "${TMP_PNG}" 2>&1 || SCREENSHOT_EXIT=$?
rm -f "${TMP_PNG}"
echo "Screenshot exit code: ${SCREENSHOT_EXIT}"

# ---------------------------------------------------------------------------
# Interpret the result.
# ---------------------------------------------------------------------------
if [[ "${SCREENSHOT_EXIT}" -eq 0 ]]; then
    echo ""
    echo "=== RESULT: FAIL (bug FIXED — action required) ==="
    echo ""
    echo "  rocketsim screenshot exited 0. The #1085 crash no longer reproduces."
    [[ -n "${RS_BUNDLE_VERSION:-}" ]] && \
        echo "  Fixed in RocketSim ${RS_BUNDLE_VERSION} (or earlier)."
    echo ""
    echo "  ACTION: simplify these scripts by removing the RS_BROKEN fallback paths:"
    echo "    scripts/capture-screenshots.sh"
    echo "      - RS_BROKEN flag and UNFRAMED_COUNT"
    echo "      - RS_RECOVERY_TIMEOUT retry loop inside capture()"
    echo "      - simctl fallback branch inside capture()"
    echo "    scripts/verify-screenshots.sh — same RS_BROKEN / simctl fallback"
    echo "  Also delete this canary script and update the memory entry"
    echo "  reference_rocketsim_163_crash.md to record that the bug is resolved."
    exit 1
fi

# Screenshot failed. Verify it was a crash (not a different error) by checking
# whether IPC went dark — a SIGTRAP kills the RocketSim process, dropping the channel.
sleep 1
if ! ipc_reachable_now; then
    echo ""
    echo "=== RESULT: PASS (bug still present — workaround still needed) ==="
    echo ""
    echo "  rocketsim screenshot crashed (exit ${SCREENSHOT_EXIT}) and IPC is now unreachable."
    [[ -n "${RS_BUNDLE_VERSION:-}" ]] && \
        echo "  RocketSim ${RS_BUNDLE_VERSION} still has the bug."
    echo "  The simctl fallback in capture-screenshots.sh and verify-screenshots.sh"
    echo "  is still needed. Re-run this script after a new RocketSim update ships."
    echo ""
    echo "  Crash logs: ~/Library/Logs/DiagnosticReports/RocketSim-*.ips"
    exit 0
fi

echo ""
echo "=== RESULT: SKIP (inconclusive) ==="
echo ""
echo "  rocketsim screenshot failed (exit ${SCREENSHOT_EXIT}) but IPC is still reachable."
echo "  This is probably not the #1085 crash — a different error caused the failure."
echo "  Run manually to inspect:"
echo "    ${RS} screenshot --udid ${UDID} --bezel device --background transparent"
exit 2
