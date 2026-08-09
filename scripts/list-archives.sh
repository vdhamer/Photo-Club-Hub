#!/bin/sh
# Lists every kept .xcarchive with the commit it was built from.
# The script is just a utility; it not automatically invoked anywhere.
#
# The Organizer shows version, build number and date, but not the commit. This fills that column in,
# reading the GitCommitHash and BuildDate that the "Run GateAndStamp script" build phase writes into
# each archived app. Archives made before that phase existed have no stamps and show "-".
#
# Runs on the release Mac, where the archives are kept. Takes no arguments.
# See Photo Club Hub/Documentation/ReleaseProcess.md and issue #808.

test $# -eq 0 || { echo "error: list-archives.sh takes no arguments"; exit 1; }

archives="$HOME/Library/Developer/Xcode/Archives"
rows=$(mktemp) || exit 1
trap 'rm -f "$rows"' EXIT

find "$archives" -maxdepth 2 -type d -name "*.xcarchive" 2>/dev/null | while read -r archive; do
    app=$(find "$archive/Products/Applications" -maxdepth 1 -type d -name "*.app" 2>/dev/null | head -1)
    test -n "$app" || continue
    plist="$app/Info.plist"                              # iOS layout
    test -f "$plist" || plist="$app/Contents/Info.plist" # macOS layout
    test -f "$plist" || continue

    read_key() { /usr/libexec/PlistBuddy -c "Print :$1" "$plist" 2>/dev/null || echo "-"; }
    build=$(read_key CFBundleVersion)
    version=$(read_key CFBundleShortVersionString)
    built=$(read_key BuildDate)
    commit=$(read_key GitCommitHash)

    case "$commit" in
        -) short="-" ;;
        *-dirty) short="$(echo "$commit" | cut -c1-8)-DIRTY" ;;   # never expected: the gate forbids it
        *) short=$(echo "$commit" | cut -c1-8) ;;
    esac

    printf '%s\t%s\t%s\t%s\t%s\n' "$(basename "$archive")" "$build" "$version" "$built" "$short" >> "$rows"
done

if [ ! -s "$rows" ]; then
    echo "No archives found in $archives"
    echo "This script lists archives kept for release, so it is probably running on the wrong Mac:"
    echo "archiving happens on the release Mac, not the development Mac."
    exit 0
fi

tab=$(printf '\t')
width=$(cut -f1 "$rows" | awk '{ if (length($0) > m) m = length($0) } END { print (m < 7 ? 7 : m) }')

printf "%-${width}s %-7s %-9s %-17s %s\n" ARCHIVE BUILD VERSION BUILT COMMIT
sort -t "$tab" -k1,1 -k2,2n "$rows" | while IFS="$tab" read -r name build version built commit; do
    printf "%-${width}s %-7s %-9s %-17s %s\n" "$name" "$build" "$version" "$built" "$commit"
done
