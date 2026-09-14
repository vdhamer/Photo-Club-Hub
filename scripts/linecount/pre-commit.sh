#!/bin/sh
#
# pre-commit.sh — write today's line-count row into LineCount.csv and add it to the
# commit being made, so every commit carries an up-to-date row for its day.
#
# Tracked here, installed per clone as a symlink. Install it on the primary Mac
# only: the release Mac only pulls, and must not get it. From the repository root:
#
#   ln -s ../../scripts/linecount/pre-commit.sh .git/hooks/pre-commit
#
# The link keeps the name pre-commit, without .sh: git runs hooks by exact name.
# Delete that symlink to stop it; `git commit --no-verify` skips it for one commit.
# Why a pre-commit hook rather than launchd, a pre-push hook or GitHub Actions:
# https://github.com/vdhamer/Photo-Club-Hub/issues/850
#
# It never blocks a commit. A line count is a statistic, and failing to produce
# one must not stop real work, so every failure is reported and the hook still
# exits 0, staging nothing.

# A hook inherits the environment of whatever runs `git commit`. GUI apps such as
# Xcode get no Homebrew in PATH, which would leave cloc, jq and gh missing.
PATH="/opt/homebrew/bin:$PATH"
export PATH

repo_root=$(git rev-parse --show-toplevel) || exit 0
csv="scripts/linecount/LineCount.csv"

# Only the script's warnings and errors are shown (stderr): its per-run summary on
# stdout would repeat on every commit.
if "$repo_root/scripts/linecount/countLines.sh" >/dev/null; then
    git add -- "$repo_root/$csv" ||
        echo "pre-commit: could not stage $csv; committing without a line-count row" >&2
else
    echo "pre-commit: countLines.sh failed (see above); committing without a line-count row" >&2
fi
exit 0
