#!/usr/bin/env bash
# Double-clickable wrapper. Resolves its own location, so it works in any clone
# rather than only in the one it was written on.
cd "$(dirname "$0")" || exit 1
./build-roadmap.py
