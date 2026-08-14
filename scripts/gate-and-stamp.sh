#!/bin/sh
# Invoked by the "Run GateAndStamp script" build phase; not meant to be run by hand.
#
#   Gates  (archiving only) refuse a dirty or unpushed working tree.
#   Stamps (every build)    write GitCommitHash and BuildDate into the built Info.plist.
#
# Design: https://github.com/vdhamer/Photo-Club-Hub/issues/808
# Procedure: Photo Club Hub/Documentation/ReleaseProcess.md

test $# -eq 0 || { echo "error: gate-and-stamp.sh takes no arguments"; exit 1; }
: "${PROJECT_DIR:?error: PROJECT_DIR unset, so this is not an Xcode build phase}"
: "${TARGET_BUILD_DIR:?error: TARGET_BUILD_DIR unset, so this is not an Xcode build phase}"
: "${INFOPLIST_PATH:?error: INFOPLIST_PATH unset, so this is not an Xcode build phase}"

dirty=$(git -C "$PROJECT_DIR" status --porcelain)

if [ "$ACTION" = "install" ]; then # gates: when archiving only
  test -z "$dirty" || { echo "error: archiving from a dirty working tree"; exit 1; }
  git -C "$PROJECT_DIR" branch -r --contains HEAD | grep -q . || { echo "error: HEAD is not pushed to origin"; exit 1; }
  xcbuild=${XCODE_PRODUCT_BUILD_VERSION:-$(/usr/bin/defaults read "${DEVELOPER_DIR:-$(xcode-select -p)}/../version.plist" ProductBuildVersion 2>/dev/null)}
  case "$xcbuild" in # beta seeds end in a lowercase letter, release seeds in a digit
    *[a-z]) echo "warning: archiving with Xcode beta $xcbuild: TestFlight accepts this build, the App Store does not" ;;
  esac
fi

hash=$(git -C "$PROJECT_DIR" rev-parse HEAD) # stamps: on every build
test -z "$dirty" || hash="$hash-dirty"
plist="${TARGET_BUILD_DIR}/${INFOPLIST_PATH}"
test -f "$plist" || { echo "error: no Info.plist at $plist"; exit 1; }

stamp() { /usr/libexec/PlistBuddy -c "Set :$1 $2" "$plist" 2>/dev/null || /usr/libexec/PlistBuddy -c "Add :$1 string $2" "$plist"; }
stamp GitCommitHash "$hash"
stamp BuildDate "$(date '+%Y-%m-%dT%H:%M')"
