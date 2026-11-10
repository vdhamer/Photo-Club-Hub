#!/usr/bin/env bash
#
# countLines.sh — append today's Swift line-count metrics to LineCount.csv
#
# Produces one CSV row:
#   date,files,code,comments,blanks,tests,openIssues,closedIssues,
#   files_HTML,code_HTML,comments_HTML,blanks_HTML,
#   files_Data,code_Data,comments_Data,blanks_Data,expertises,release
#   Columns are grouped by repository: the iOS app first (through closedIssues),
#   then Photo-Club-Hub-HTML, then Photo-Club-Hub-Data. Each repo's block runs
#   files,code,comments,blanks in that order. `expertises` follows because it
#   measures the data, not any repo's source. `release` is last and is the only
#   text column.
#   files/code/comments/blanks : from `cloc` over all Swift in the repo
#                                (app sources + tests), matching the historical
#                                LineCount.xlsx "SwiftUI version" columns.
#   tests                      : number of Swift Testing @Test macros.
#   openIssues/closedIssues    : GitHub issue counts (excluding PRs) via `gh`;
#                                left empty if gh is unavailable or offline.
#   expertises                 : number of supported expertises, counted in
#                                JSON/root.level0.json; empty if jq is missing.
#   release                    : the iOS app's version tag released as of this
#                                row, e.g. "v3.0.4", or empty. Unlike the other
#                                columns this is not measured today: see
#                                "Release labels" below.
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
# The CSV (scripts/linecount/LineCount.csv) is the version-controlled source of
# truth. LineCount.xlsx is only a viewer that loads this CSV via Power Query.
#
# Usage:  scripts/linecount/countLines.sh
#
#   Normally not run by hand: the pre-commit hook beside this script runs it on
#   every commit in this repo and stages the CSV, so each commit carries the row
#   for its day (see pre-commit.sh, and issue #850).
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
#   - Rows with fewer columns than the header (written before a column was
#     added, and possibly brought back by merging an old branch) are padded
#     with empty cells.
#
# Release labels (Project#25):
#   The `release` column marks where each iOS release falls on the line-count
#   graphs. A release is a tag in this repo named v<digits>... (plus the
#   one-off typo v.2.2.9); the b<number> build tags are not releases.
#   A tag is made after its release commit, often on the other Mac, so the
#   commit's own row cannot be labeled when it is written. Instead every run
#   looks for release tags that appear nowhere in the column yet and writes
#   each one onto the latest row dated on or before the tag's date: that row's
#   counts are what shipped. A row on the tag's own date often does not exist
#   (no commit that day). Labels already in the column are never moved, so the
#   first run fills in the history and later runs only add.
#   A row holds one label. When two releases land on the same row, the newer
#   version wins and the older one is dropped: two releases a day apart mean
#   the first was superseded before anyone used it (v2.2.2 and v2.2.3, both
#   on 2022-10-23). A dropped tag stays dropped, because its row already
#   carries a newer one.
#   A tag's date is the date of the commit it tags, also for an annotated
#   tag, whose own date can be much later (v2.1.1 was tagged weeks after its
#   commit).
#
#   Example: v3.0.4 is tagged on 2026-10-25, and that day has a row. The next
#   run writes "v3.0.4" into the `release` cell of the 2026-10-25 row.
#
set -euo pipefail

# The script takes no arguments, and refuses them rather than ignoring them: a
# silently-accepted flag would suggest it can measure something other than the
# current working trees, which it cannot.
(( $# == 0 )) || { echo "error: this script takes no arguments" >&2; exit 1; }

# --- locate repo root (this script lives in <repo>/scripts/linecount/) -------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
PARENT_DIR="$(dirname "$REPO_ROOT")"               # holds the sibling checkouts

DATE="$(date +%F)"                                  # YYYY-MM-DD

# --- configuration -----------------------------------------------------------
CSV="$SCRIPT_DIR/LineCount.csv"
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

# Release tags as "YYYY-MM-DD tag" lines, in version order (see "Release
# labels" above). Non-fatal: without git the labels already in the CSV are kept
# and no new ones are added.
# The date of the tagged commit: dereferenced (*) for an annotated tag.
TAG_DATE='%(if)%(*objectname)%(then)%(*committerdate:short-local)%(else)%(committerdate:short-local)%(end)'
RELEASE_TAGS="$(git -C "$REPO_ROOT" for-each-ref --sort=v:refname \
    --format="$TAG_DATE %(refname:short)" 'refs/tags/v[.0-9]*' 2>/dev/null)" || {
    echo "warning: could not list release tags; no new release labels" >&2
    RELEASE_TAGS=""
}

NEW_ROW="$DATE,$files,$code,$comments,$blanks,$tests,$openIssues,$closedIssues"
NEW_ROW="$NEW_ROW,$filesHTML,$codeHTML,$commentsHTML,$blanksHTML"
NEW_ROW="$NEW_ROW,$filesData,$codeData,$commentsData,$blanksData,$expertises"

# --- write row (dedupe by date, label releases, keep sorted) ------------------
# Today's existing row is replaced by this fresh recount, so the recount is
# authoritative; only its release label carries over. Any remaining duplicate
# dates (only possible from a `merge=union` merge) collapse to the row with the
# highest `code` value, a deterministic, order-independent rule, again keeping
# the newest release label found on any of the duplicates. Today's date is unique
# after the replacement, so it is unaffected by the highest-code rule.
# The layout is fixed, so the header comes from this constant rather than being
# patched column-by-column as it used to be. That incremental style only worked
# while new columns went on the end; with `expertises` last it could no longer
# place anything correctly.
HEADER="date,files,code,comments,blanks,tests,openIssues,closedIssues"
HEADER="$HEADER,files_HTML,code_HTML,comments_HTML,blanks_HTML"
HEADER="$HEADER,files_Data,code_Data,comments_Data,blanks_Data,expertises"
# The layout before `release` was added. A CSV in it is widened on this run
# rather than refused: the new column goes on the end, so no value moves.
HEADER_BEFORE_RELEASE="$HEADER"
HEADER="$HEADER,release"
NCOLS=18
# Refuse a CSV in any other layout instead of restamping the header over it:
# the values would silently shift into the wrong columns.
CURRENT_HEADER="$(head -n 1 "$CSV")"
if [[ "$CURRENT_HEADER" != "$HEADER" && "$CURRENT_HEADER" != "$HEADER_BEFORE_RELEASE" ]]; then
    echo "error: unexpected header in $CSV" >&2
    echo "  found:    $CURRENT_HEADER" >&2
    echo "  expected: $HEADER" >&2
    exit 1
fi
TMP="$(mktemp)"
LABELED="$(mktemp)"                                # "tag -> date" lines for the report
{
    printf '%s\n' "$HEADER"
    tail -n +2 "$CSV" \
    | TAG_LIST="$RELEASE_TAGS" \
      awk -F, -v OFS=, -v n="$NCOLS" -v today="$DATE" -v newRow="$NEW_ROW" \
          -v labeled="$LABELED" '
        # True if version tag a is newer than b, comparing the dot-separated
        # numbers after the leading "v" (or the typo "v.") one by one.
        function newer(a, b,    x, y, i, k, l) {
            sub(/^v\.?/, "", a); sub(/^v\.?/, "", b)
            k = split(a, x, "."); l = split(b, y, "."); if (l > k) k = l
            for (i = 1; i <= k; i++) if (x[i] + 0 != y[i] + 0) return x[i] + 0 > y[i] + 0
            return 0
        }
        # Sets label[d] to the newest of its current tag and the space-separated
        # tags in `tags` (cells written before the one-label rule held several).
        function addLabels(d, tags,    t, k, i) {
            k = split(tags, t, " ")
            for (i = 1; i <= k; i++)
                if (label[d] == "" || newer(t[i], label[d])) label[d] = t[i]
        }
        # Pads a row to n fields and keeps it as the row for its date if its
        # `code` is the highest so far; its label is collected either way.
        function take(isNew) {
            while (NF < n) $(NF + 1) = ""
            addLabels($1, $n)
            if (isNew || !($1 in best) || $3 + 0 >= code[$1]) { best[$1] = $0; code[$1] = $3 + 0 }
        }
        NF == 0 { next }
        $1 == today { addLabels(today, (NF >= n ? $n : "")); next }   # replaced by newRow
        { take(0) }
        END {
            $0 = newRow; take(1)
            for (d in label) if (label[d] != "") known[label[d]] = 1
            # Label each release tag that is in no row yet, on the latest row
            # dated on or before the tag, unless that row has a newer one. A tag
            # older than the first row gets none.
            m = split(ENVIRON["TAG_LIST"], line, "\n")   # macOS awk refuses newlines in -v
            for (j = 1; j <= m; j++) {
                if (split(line[j], f, " ") != 2 || (f[2] in known)) continue
                target = ""
                for (d in best) if (d <= f[1] && d > target) target = d
                if (target == "") continue
                before = label[target]; addLabels(target, f[2]); known[f[2]] = 1
                if (label[target] != before) print f[2] " -> " target > labeled
            }
            for (d in best) { $0 = best[d]; $n = label[d]; print }
        }' \
    | sort -t, -k1,1
} > "$TMP"
mv "$TMP" "$CSV"

echo "Recorded $NEW_ROW"
echo "  -> $CSV"
if [[ -s "$LABELED" ]]; then
    echo "Release labels added:"
    sed 's/^/   /' "$LABELED"
fi
rm -f "$LABELED"

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
        pFilesData pCodeData pCommentsData pBlanksData pExpertises pRelease \
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
