#!/usr/bin/env bash
#
# countLines.sh — append today's Swift line-count metrics to LineCount.csv
#
# Produces one CSV row:
#   date,files,code,comments,blanks,tests,openIssues,closedIssues,
#   files_HTML,code_HTML,comments_HTML,blanks_HTML,
#   files_Data,code_Data,comments_Data,blanks_Data,expertises
#   Columns are grouped by repository: the iOS app first (through closedIssues),
#   then Photo-Club-Hub-HTML, then Photo-Club-Hub-Data. Each repo's block runs
#   files,code,comments,blanks in that order. `expertises` sits last because it
#   measures the data, not any repo's source.
#   files/code/comments/blanks : from `cloc` over all Swift in the repo
#                                (app sources + tests), matching the historical
#                                LineCount.xlsx "SwiftUI version" columns.
#   tests                      : number of Swift Testing @Test macros.
#   openIssues/closedIssues    : GitHub issue counts (excluding PRs) via `gh`;
#                                left empty if gh is unavailable or offline.
#   expertises                 : number of supported expertises, counted in
#                                JSON/root.level0.json; empty if jq is missing.
#   *_HTML / *_Data            : the same Swift file/code/comment/blank counts for
#                                two sibling repositories Photo-Club-Hub-HTML and
#                                Photo-Club-Hub-Data. These are counted from
#                                local checkouts sitting next to this repo (see
#                                "sibling repositories" below), so they reflect
#                                whatever branch/working tree is checked out
#                                there. Left empty if a checkout is missing.
#   The three repos are counted the same way (Swift only), so the columns are
#   directly comparable and can be stacked in the spreadsheet.
#
# The CSV (scripts/LineCount.csv) is the version-controlled source of
# truth. LineCount.xlsx is only a viewer that loads this CSV via Power Query.
#
# Usage:  ./scripts/countLines.sh
#
#   Rows are always stamped with today's date and always reflect the current
#   working trees. Reconstructing a past date means reading it out of git history
#   (`git rev-list --before` + `git archive` + cloc) rather than re-running this
#   script under a different date stamp — the counts would still come from
#   today's trees, which is how a bogus row gets written.
#
# Requires: cloc  (install with: brew install cloc)
#           gh    (optional, for issue counts: brew install gh)
#
# Sibling repositories:
#   The *_HTML and *_Data columns are counted from directories next to this
#   repo's checkout. Both local naming conventions are tried ("Photo Club Hub
#   HTML" and "Photo-Club-Hub-HTML"). Override with the environment variables
#   PCH_HTML_REPO / PCH_DATA_REPO if your checkouts live elsewhere. A missing
#   checkout is a warning, not an error: its three columns are left empty.
#
# Behavior:
#   - Today's row is always replaced by this fresh recount (idempotent), even if
#     the new count is lower (e.g. after deleting code).
#   - Any OTHER duplicate dates are collapsed to one row keeping the highest
#     `code` value. Such duplicates can only arise from a `merge=union` merge of
#     LineCount.csv (see .gitattributes); highest-code is deterministic
#     (order-independent) and self-heals the file on the next run.
#   - Data rows are kept sorted by date; the header stays on line 1.
#
set -euo pipefail

# The script takes no arguments, and refuses them rather than ignoring them: a
# silently-accepted flag would suggest it can measure something other than the
# current working trees, which it cannot.
(( $# == 0 )) || { echo "error: this script takes no arguments" >&2; exit 1; }

# --- locate repo root (this script lives in <repo>/scripts/) -----------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PARENT_DIR="$(dirname "$REPO_ROOT")"               # holds the sibling checkouts

DATE="$(date +%F)"                                  # YYYY-MM-DD

# --- configuration -----------------------------------------------------------
CSV="$REPO_ROOT/scripts/LineCount.csv"
TESTS_DIR="$REPO_ROOT/Tests"                       # where @Test macros live
EXCLUDE_DIRS=".build,DerivedData,Pods,.git"        # cloc --exclude-dir list
GH="/opt/homebrew/bin/gh"                          # GitHub CLI (optional)
GH_OWNER="vdhamer"
GH_REPO="Photo-Club-Hub"
LEVEL0_JSON="$REPO_ROOT/JSON/root.level0.json"     # defines supported expertises

# First existing directory among the given sibling names, or nothing.
find_sibling() {   # <dir-name>...
    local name
    for name in "$@"; do
        if [[ -d "$PARENT_DIR/$name" ]]; then
            printf '%s\n' "$PARENT_DIR/$name"
            return 0
        fi
    done
    return 0                                       # not found: caller warns
}
HTML_REPO="${PCH_HTML_REPO:-$(find_sibling "Photo Club Hub HTML" "Photo-Club-Hub-HTML")}"
DATA_REPO="${PCH_DATA_REPO:-$(find_sibling "Photo-Club-Hub-Data" "Photo Club Hub Data")}"

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
# Prints nothing for a missing/Swift-less directory, so each caller decides
# whether that is fatal (this repo) or just an empty column (the siblings).
swift_metrics() {   # <repo-dir> -> "files blanks comments code"
    [[ -n "$1" && -d "$1" ]] || return 0
    cloc --include-lang=Swift --exclude-dir="$EXCLUDE_DIRS" \
         --skip-uniqueness --csv --quiet "$1" \
    | awk -F, '$2=="Swift" { print $1, $3, $4, $5 }'
}

files=""; blanks=""; comments=""; code=""
read -r files blanks comments code < <(swift_metrics "$REPO_ROOT") || true

if [[ -z "${files:-}" ]]; then
    echo "error: cloc reported no Swift files — check the scope/exclusions." >&2
    exit 1
fi

# Same four counts for the two sibling repos. Non-fatal: a repo that isn't
# checked out locally leaves its columns empty rather than failing the run.
filesHTML=""; blanksHTML=""; commentsHTML=""; codeHTML=""
read -r filesHTML blanksHTML commentsHTML codeHTML < <(swift_metrics "$HTML_REPO") || true
if [[ -z "$codeHTML" ]]; then
    echo "warning: no Swift found for Photo-Club-Hub-HTML${HTML_REPO:+ at $HTML_REPO}; leaving its columns empty" >&2
fi

filesData=""; blanksData=""; commentsData=""; codeData=""
read -r filesData blanksData commentsData codeData < <(swift_metrics "$DATA_REPO") || true
if [[ -z "$codeData" ]]; then
    echo "warning: no Swift found for Photo-Club-Hub-Data${DATA_REPO:+ at $DATA_REPO}; leaving its columns empty" >&2
fi

# Count Swift Testing @Test macros (leading whitespace allowed).
if [[ -d "$TESTS_DIR" ]]; then
    tests="$(grep -rE '^[[:space:]]*@Test' "$TESTS_DIR" | wc -l | tr -d ' ')"
else
    tests=""
fi

# GitHub issue counts (issues only, no PRs). One GraphQL call returns both.
# Non-fatal: on any failure (gh missing, offline, auth expired) both stay empty.
openIssues=""
closedIssues=""
if [[ -x "$GH" ]]; then
    read -r openIssues closedIssues < <(
        "$GH" api graphql \
            -f query="{ repository(owner:\"$GH_OWNER\", name:\"$GH_REPO\") {
                open: issues(states:OPEN) { totalCount }
                closed: issues(states:CLOSED) { totalCount } } }" \
            --jq '"\(.data.repository.open.totalCount) \(.data.repository.closed.totalCount)"' \
            2>/dev/null
    ) || true
    if [[ -z "$openIssues" || -z "$closedIssues" ]]; then
        echo "warning: could not fetch GitHub issue counts; leaving columns empty" >&2
        openIssues=""
        closedIssues=""
    fi
else
    echo "warning: gh not found at $GH; leaving issue columns empty" >&2
fi

# Number of supported expertises in root.level0.json.
# Non-fatal: left empty if jq or the JSON file is missing.
expertises=""
if command -v jq >/dev/null 2>&1 && [[ -f "$LEVEL0_JSON" ]]; then
    expertises="$(jq -r 'try (.expertises | length) // empty' "$LEVEL0_JSON" 2>/dev/null)" || true
fi
if [[ -z "$expertises" ]]; then
    echo "warning: could not count expertises in $LEVEL0_JSON; leaving column empty" >&2
fi

NEW_ROW="$DATE,$files,$code,$comments,$blanks,$tests,$openIssues,$closedIssues"
NEW_ROW="$NEW_ROW,$filesHTML,$codeHTML,$commentsHTML,$blanksHTML"
NEW_ROW="$NEW_ROW,$filesData,$codeData,$commentsData,$blanksData,$expertises"

# --- write row (dedupe by date, keep sorted) ---------------------------------
# Drop any pre-existing row for today so this fresh recount is authoritative,
# then append it. Collapse any remaining duplicate dates (only possible from a
# `merge=union` merge) keeping the highest `code` value — a deterministic,
# order-independent rule. Today's date is now unique, so it is unaffected by the
# highest-code rule and always reflects this recount.
# The layout is fixed, so the header comes from this constant rather than being
# patched column-by-column as it used to be. That incremental style only worked
# while new columns went on the end; with `expertises` now last it could no
# longer place anything correctly.
HEADER="date,files,code,comments,blanks,tests,openIssues,closedIssues"
HEADER="$HEADER,files_HTML,code_HTML,comments_HTML,blanks_HTML"
HEADER="$HEADER,files_Data,code_Data,comments_Data,blanks_Data,expertises"
# Refuse a CSV written in an older layout instead of restamping the header over
# it: the values would silently shift into the wrong columns.
CURRENT_HEADER="$(head -n 1 "$CSV")"
if [[ "$CURRENT_HEADER" != "$HEADER" ]]; then
    echo "error: unexpected header in $CSV" >&2
    echo "  found:    $CURRENT_HEADER" >&2
    echo "  expected: $HEADER" >&2
    exit 1
fi
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

# --- report what changed vs. the previous record -----------------------------
# Compare each metric against the most recent row older than today and print what
# changed... e.g. "   Comments: +12" or "   Open issues: -1". Selecting on "older
# than today" rather than "not today" keeps the comparison backward-looking even
# if a future-dated row ever reaches the file via a `merge=union` merge.
# Columns that are unchanged are not shown.
# Columns that are empty in either row (e.g. issue counts when offline, or the
# sibling-repo columns on rows written before those columns existed) are skipped.
PREV_ROW="$(tail -n +2 "$CSV" | awk -F, -v d="$DATE" '$1 "" < d ""' | sort -t, -k1,1 | tail -n 1)"
if [[ -n "$PREV_ROW" ]]; then
    IFS=, read -r pDate pFiles pCode pComments pBlanks pTests pOpen pClosed \
        pFilesHTML pCodeHTML pCommentsHTML pBlanksHTML \
        pFilesData pCodeData pCommentsData pBlanksData pExpertises \
        <<< "$PREV_ROW"

    anyChange=0
    print_delta() {  # label  old  new
        local label="$1" old="$2" new="$3"
        # Skip unless both values are present and integer-valued.
        [[ "$old" =~ ^-?[0-9]+$ && "$new" =~ ^-?[0-9]+$ ]] || return 0
        local diff=$(( new - old ))
        (( diff == 0 )) && return 0
        anyChange=1
        if (( diff < 0 )); then
            printf '   %s: %d\n' "$label" "$diff"      # negative sign included
        else
            printf '   %s: +%d\n' "$label" "$diff"
        fi
    }

    echo "Changes since $pDate:"
    print_delta "iOS  files"     "$pFiles"         "$files"
    print_delta "iOS  code"      "$pCode"          "$code"
    print_delta "iOS  comments"  "$pComments"      "$comments"
    print_delta "iOS  blanks"    "$pBlanks"        "$blanks"
    print_delta "Tests"          "$pTests"         "$tests"
    print_delta "Open issues"    "$pOpen"          "$openIssues"
    print_delta "Closed issues"  "$pClosed"        "$closedIssues"
    print_delta "HTML files"     "$pFilesHTML"     "$filesHTML"
    print_delta "HTML code"      "$pCodeHTML"      "$codeHTML"
    print_delta "HTML comments"  "$pCommentsHTML"  "$commentsHTML"
    print_delta "HTML blanks"    "$pBlanksHTML"    "$blanksHTML"
    print_delta "Data files"     "$pFilesData"     "$filesData"
    print_delta "Data code"      "$pCodeData"      "$codeData"
    print_delta "Data comments"  "$pCommentsData"  "$commentsData"
    print_delta "Data blanks"    "$pBlanksData"    "$blanksData"
    print_delta "Expertises"     "$pExpertises"    "$expertises"
    # Identical metrics (or all columns skipped) leave the list empty; say so
    # explicitly rather than printing a bare "Changes since …:" header.
    if (( anyChange == 0 )); then
        echo "   (no changes since previous day)"
    fi
fi
