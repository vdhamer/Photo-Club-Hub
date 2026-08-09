#!/bin/sh
# Recreates Photo Club Hub.xcworkspace/contents.xcworkspacedata.
#
# SYMPTOM: you open Photo Club Hub.xcworkspace and the Project Navigator is empty. Xcode is not
# broken and nothing is lost — the workspace has simply lost the one file that says which project it
# contains, so it opens a workspace containing nothing.
#
# WHY IT CAN HAPPEN: that file used to be tracked in git, and was untracked on 9 Aug 2026 so that the
# personal co-development workspace stays private and only one Package.resolved is tracked (#808).
# Checking out a commit from the 24 hours when it *was* tracked (125107e3 .. d164ab63) creates the
# file; leaving that range again makes git delete it, because git makes the working tree match the
# commit and .gitignore has no say over files git itself is removing. No branch tip or tag sits
# inside that range, so ordinary branch switching will not do this — only a deliberate checkout of a
# commit from that period.
#
# The file is personal and git-ignored, so recreating it changes nothing that anyone else sees.
# If you had added a local checkout of Photo Club Hub Data to the workspace for co-development, add
# it again in Xcode afterwards: this script restores the plain one-project workspace.
#
# Takes no arguments. Safe to run twice: it refuses to overwrite an existing file.

test $# -eq 0 || { echo "error: restore-workspace.sh takes no arguments"; exit 1; }

repo=$(cd "$(dirname "$0")/.." && pwd)
target="$repo/Photo Club Hub.xcworkspace/contents.xcworkspacedata"

if [ -f "$target" ]; then
    echo "Already present: $target"
    echo "So an empty Project Navigator has some other cause than this script fixes."
    exit 0
fi

mkdir -p "$(dirname "$target")" || exit 1
cat > "$target" <<'XML'
<?xml version="1.0" encoding="UTF-8"?>
<Workspace
   version = "1.0">
   <FileRef
      location = "group:Photo Club Hub.xcodeproj">
   </FileRef>
</Workspace>
XML

echo "Recreated: $target"
echo "Close the workspace in Xcode if it is open, then reopen it."
