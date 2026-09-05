#!/usr/bin/env bash
# Double-clickable wrapper: rebuild, then show the pages it produced.
# Resolves its own location, so it works in any clone.
#
# Two things deliberately live here rather than in build-roadmap.py:
#
#   Opening a browser. A build run from a terminal, a git hook or another script
#   must not hijack the display, so the tool stays silent and the wrapper decides.
#
#   Which files to open. Rather than naming them again — which would break the day
#   an output is renamed — this reads the paths build-roadmap.py reports, so the
#   script itself remains the only place output names are written down.
cd "$(dirname "$0")" || exit 1

output=$(./build-roadmap.py) || exit 1
printf '%s\n' "$output"

# Reversed, because `open` gives focus to whichever file it handles last: this
# leaves the first one listed — the working sheet — frontmost.
printf '%s\n' "$output" | grep '\.html$' | tail -r | while read -r url; do
    open "$url"
done
