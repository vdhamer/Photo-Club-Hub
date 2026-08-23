#!/bin/sh
# Invoked by the "Run GateAndStamp script" build phase; not meant to be run by hand.
#
#   Gates  (archiving only) refuse a dirty or unpushed working tree.
#   Stamps (every build)    write GitCommitHash, BuildDate, LibraryVersion, LibraryRevision and
#                           LibraryCommitDate into BuildStamp.plist inside the built app.
#
# Stamped values never contain spaces: that is the format contract with the screens that display
# them (#807, vdhamer/Photo-Club-Hub-HTML#239), and it means no value ever needs XML escaping.
#
# Design: https://github.com/vdhamer/Photo-Club-Hub/issues/808, issues/814 and issues/822
# Procedure: Photo Club Hub/Documentation/ReleaseProcess.md

test $# -eq 0 || { echo "error: gate-and-stamp.sh takes no arguments"; exit 1; }
: "${PROJECT_DIR:?error: PROJECT_DIR unset, so this is not an Xcode build phase}"
: "${TARGET_BUILD_DIR:?error: TARGET_BUILD_DIR unset, so this is not an Xcode build phase}"
: "${UNLOCALIZED_RESOURCES_FOLDER_PATH:?error: UNLOCALIZED_RESOURCES_FOLDER_PATH unset, so this is not an Xcode build phase}"

dirty=$(git -C "$PROJECT_DIR" status --porcelain)

if [ "$ACTION" = "install" ]; then # gates: when archiving only
  test -z "$dirty" || { echo "error: archiving from a dirty working tree"; exit 1; }
  git -C "$PROJECT_DIR" branch -r --contains HEAD | grep -q . || { echo "error: HEAD is not pushed to origin"; exit 1; }
  # Every upload gets a b<number> tag (step 7), so an existing b<CURRENT_PROJECT_VERSION> means this
  # build number already reached Apple and the step 1 bump was skipped. Failing here, rather than
  # leaving it to App Store Connect's ITMS-4238, keeps the number in the tree and the number Apple
  # sees identical: that equality is what the b<number> tags claim. Tags arrive with the step 3 pull.
  ! git -C "$PROJECT_DIR" rev-parse -q --verify "refs/tags/b$CURRENT_PROJECT_VERSION" >/dev/null ||
    { echo "error: build number $CURRENT_PROJECT_VERSION was already uploaded as tag b$CURRENT_PROJECT_VERSION"; exit 1; }
  xcbuild=${XCODE_PRODUCT_BUILD_VERSION:-$(/usr/bin/defaults read "${DEVELOPER_DIR:-$(xcode-select -p)}/../version.plist" ProductBuildVersion 2>/dev/null)}
  case "$xcbuild" in # beta seeds end in a lowercase letter, release seeds in a digit
    *[a-z]) echo "warning: archiving with Xcode beta $xcbuild: TestFlight accepts this build, the App Store does not" ;;
  esac
fi

hash=$(git -C "$PROJECT_DIR" rev-parse HEAD) # stamps: on every build
test -z "$dirty" || hash="$hash-dirty"
# The stamps go into a file of this script's own, never into the built Info.plist. Xcode owns that
# one: it regenerates it from the target's INFOPLIST_FILE at a moment the build system picks, and
# since this phase declares no inputs or outputs there is nothing ordering the two. On a clean build the
# regeneration happens first and the stamps survive; on every incremental build afterwards it happens
# a few milliseconds later and silently discards them (#822). Nothing else in the build produces
# BuildStamp.plist, and code signing runs after this phase, so what is written here is what ships.
# The resources folder is the app bundle itself on iOS and Contents/Resources on macOS; the build
# setting covers both.
stampDir="${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
test -d "$stampDir" || { echo "error: no resources folder at $stampDir"; exit 1; }

# Which Package.resolved is live, depends on what Xcode opened:
#   - for a project build WORKSPACE_DIR *is* the .xcodeproj,
#   - for a workspace build it is the directory holding the .xcworkspace.
# Reading the wrong one matters mainly for the personal co-development workspace (#808), where the remote
# dependency is replaced by a local checkout and this file then has no pin for it at all.
case "$WORKSPACE_DIR" in
  *.xcworkspace) resolved="$WORKSPACE_DIR/xcshareddata/swiftpm/Package.resolved" ;;
  *.xcodeproj)   resolved="$WORKSPACE_DIR/project.xcworkspace/xcshareddata/swiftpm/Package.resolved" ;;
  ?*)            resolved=$(ls "$WORKSPACE_DIR"/*.xcworkspace/xcshareddata/swiftpm/Package.resolved 2>/dev/null | head -1) ;;
  *)             resolved="" ;;
esac
test -f "$resolved" || resolved="$PROJECT_FILE_PATH/project.xcworkspace/xcshareddata/swiftpm/Package.resolved"

# The pins are diagnostic, so nothing below may fail the build: the gates are the part allowed to
# stop an archive. Every outcome stamps a word rather than an empty string, so the display can say
# what happened instead of showing a blank.
version="unknown"; revision="unknown" # no Package.resolved at all
if [ ! -f "$resolved" ]; then
  echo "warning: no Package.resolved found, so the library version is stamped as unknown"
elif ! /usr/bin/plutil -convert json -o /dev/null "$resolved" 2>/dev/null; then # -lint rejects JSON
  version="unreadable"; revision="unreadable" # damaged file: say so rather than guess
  echo "warning: cannot parse $resolved, so the library version is stamped as unreadable"
else
  version="local-checkout"; revision="local-checkout" # no pin = the package is a local checkout
  i=0
  while identity=$(/usr/bin/plutil -extract "pins.$i.identity" raw -o - "$resolved" 2>/dev/null); do
    if [ "$identity" = "photo-club-hub-data" ]; then
      version=$(/usr/bin/plutil -extract "pins.$i.state.version" raw -o - "$resolved" 2>/dev/null) ||
        version="unversioned" # a branch or revision pin carries no version
      revision=$(/usr/bin/plutil -extract "pins.$i.state.revision" raw -o - "$resolved" 2>/dev/null) ||
        revision="unknown"
      break
    fi
    i=$((i + 1))
  done
fi

# The pin names a commit but not when it was made, and that is what separates "the library moved
# last week" from "it has been stable for a year". Only git knows, so ask the checkout SwiftPM made,
# which is a full clone. Asking for this exact revision self-validates: a missing or wrong checkout
# simply has no such commit. Unlike BuildDate above, %cI is strict ISO 8601 with a UTC offset, so it
# denotes an instant and the displaying app can render it in the reader's own timezone.
commitDate="unknown"
case "$revision" in
  *[!0-9a-f]*) ;; # a sentinel word rather than a hash: nothing to look up
  ?*) checkout="$BUILD_DIR/../../SourcePackages/checkouts/Photo-Club-Hub-Data"
      commitDate=$(git -C "$checkout" show -s --format=%cI "$revision" 2>/dev/null) || commitDate="unknown" ;;
esac

buildDate=$(date '+%Y-%m-%dT%H:%M') # one reading, so the plist and the build log cannot disagree

# Written whole rather than key by key, so a stamp left by an earlier build can never linger.
cat > "$stampDir/BuildStamp.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>GitCommitHash</key>
	<string>$hash</string>
	<key>BuildDate</key>
	<string>$buildDate</string>
	<key>LibraryVersion</key>
	<string>$version</string>
	<key>LibraryRevision</key>
	<string>$revision</string>
	<key>LibraryCommitDate</key>
	<string>$commitDate</string>
</dict>
</plist>
PLIST

# Echoed as well as stamped. The stamps are what tell one Debug install on a test device from
# another, and the Report Navigator is where to read them for the build just made: no digging the
# plist out of the app bundle, and it still answers after DerivedData has been cleaned away.
echo "wrote $stampDir/BuildStamp.plist"
echo "  GitCommitHash     $hash"
echo "  BuildDate         $buildDate"
echo "  LibraryVersion    $version"
echo "  LibraryRevision   $revision"
echo "  LibraryCommitDate $commitDate"
