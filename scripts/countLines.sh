#!/usr/bin/env bash
#
# countLines.sh — append today's Swift line-count metrics to LineCount.csv
#
# Produces one CSV row: date,files,code,comments,blanks,tests
#   files/code/comments/blanks : from `cloc` over all Swift in the repo
#                                (app sources + tests), matching the historical
#                                LineCount.xlsx "SwiftUI version" columns.
#   tests                      : number of Swift Testing @Test macros.
#
# The CSV (documentation/LineCount.csv) is the version-controlled source of
# truth. LineCount.xlsx is only a viewer that loads this CSV via Power Query.
#
# Usage:  ./scripts/countLines.sh
#
# Requires: cloc  (install with: brew install cloc)
#
# Behaviour:
#   - Today's row is always replaced by this fresh recount (idempotent), even if
#     the new count is lower (e.g. after deleting code).
#   - Any OTHER duplicate dates are collapsed to one row keeping the highest
#     `code` value. Such duplicates can only arise from a `merge=union` merge of
#     LineCount.csv (see .gitattributes); highest-code is deterministic
#     (order-independent) and self-heals the file on the next run.
#   - Data rows are kept sorted by date; the header stays on line 1.
#
set -euo pipefail

# --- locate repo root (this script lives in <repo>/scripts/) -----------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# --- configuration -----------------------------------------------------------
CSV="$REPO_ROOT/Photo Club Hub/Documentation/LineCount.csv"
TESTS_DIR="$REPO_ROOT/Tests"                       # where @Test macros live
EXCLUDE_DIRS=".build,DerivedData,Pods,.git"        # cloc --exclude-dir list

# --- preconditions -----------------------------------------------------------
if ! command -v cloc >/dev/null 2>&1; then
    echo "error: cloc not found. Install it with:  brew install cloc" >&2
    exit 1
fi
if [[ ! -f "$CSV" ]]; then
    echo "error: CSV not found at: $CSV" >&2
    exit 1
fi

# --- gather metrics ----------------------------------------------------------
# cloc --csv (Swift only) prints a data row:  files,language,blank,comment,code
# --skip-uniqueness disables cloc's identical-file de-duplication so the file
# count reflects every Swift file (and can't spuriously dip when two files
# briefly become byte-identical).
read -r files blanks comments code < <(
    cloc --include-lang=Swift --exclude-dir="$EXCLUDE_DIRS" \
         --skip-uniqueness --csv --quiet "$REPO_ROOT" \
    | awk -F, '$2=="Swift" { print $1, $3, $4, $5 }'
)

if [[ -z "${files:-}" ]]; then
    echo "error: cloc reported no Swift files — check the scope/exclusions." >&2
    exit 1
fi

# Count Swift Testing @Test macros (leading whitespace allowed).
if [[ -d "$TESTS_DIR" ]]; then
    tests="$(grep -rE '^[[:space:]]*@Test' "$TESTS_DIR" | wc -l | tr -d ' ')"
else
    tests=""
fi

DATE="$(date +%F)"                                  # YYYY-MM-DD
NEW_ROW="$DATE,$files,$code,$comments,$blanks,$tests"

# --- write row (dedupe by date, keep sorted) ---------------------------------
# Drop any pre-existing row for today so this fresh recount is authoritative,
# then append it. Collapse any remaining duplicate dates (only possible from a
# `merge=union` merge) keeping the highest `code` value — a deterministic,
# order-independent rule. Today's date is now unique, so it is unaffected by the
# highest-code rule and always reflects this recount.
HEADER="$(head -n 1 "$CSV")"
TMP="$(mktemp)"
{
    printf '%s\n' "$HEADER"
    {
        tail -n +2 "$CSV" | grep -v "^$DATE,"
        printf '%s\n' "$NEW_ROW"
    } | awk -F, 'NF {
            if (!($1 in best) || $3 + 0 >= code[$1]) { best[$1] = $0; code[$1] = $3 + 0 }
        }
        END { for (d in best) print best[d] }' \
      | sort -t, -k1,1
} > "$TMP"
mv "$TMP" "$CSV"

echo "Recorded $NEW_ROW"
echo "  -> $CSV"
