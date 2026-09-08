#!/usr/bin/env python3
#
# build-roadmap.py — regenerate the roadmap views from feature-candidates.csv
#
# Reads  feature-candidates.csv   the master list of roadmap candidates
#        ratings.csv              optional: id,value,shortlist rows exported from the web page
#        roadmap-template.html    page design and behaviour, with a __ROWS__ placeholder
#        reader-template.html     the shareable page, English, with a __GROUPS__ placeholder
#        reader-template-nl.html  the same page in Dutch
# Writes roadmap-contact-sheet.html   interactive: sort, filter, rate, value/effort matrix
#        roadmap-for-readers.html     the shareable one: no notes, no ticket numbers, grouped by goal
#        roadmap-for-readers-nl.html  the same page in Dutch, from the *_nl columns of the CSV
#
# Both reader pages are written on every run.
#
# The CSV is the only place data lives. The page embeds a copy at build time, so
# editing the CSV means running this again. Ratings entered in the page live in
# the reader's browser until exported from it and merged back into the CSV by hand.
#
# Takes no arguments. Run it from anywhere; paths are resolved next to this file.

import csv
import io
import json
import re
import sys
from pathlib import Path

if len(sys.argv) > 1:
    sys.exit("error: this script takes no arguments")

HERE = Path(__file__).resolve().parent
CSV_IN = HERE / "feature-candidates.csv"
TEMPLATE = HERE / "roadmap-template.html"
HTML_OUT = HERE / "roadmap-contact-sheet.html"
RATINGS_IN = HERE / "ratings.csv"
READER_TEMPLATE = HERE / "reader-template.html"
READER_OUT = HERE / "roadmap-for-readers.html"
READER_TEMPLATE_NL = HERE / "reader-template-nl.html"
READER_OUT_NL = HERE / "roadmap-for-readers-nl.html"

# The goals this project is trying to serve, in the order they appear on the shareable
# page, keyed by the short column name used in the CSV.
#
# A row carries one mark per goal it serves: "*" for the one goal it mainly serves, and
# "x" for any others. Exactly one star per row, because the star is also what the reader
# page groups by, and a row appearing under two headings would be numbered twice — the
# numbers are how a reply refers to a row. The extra "x" marks exist for analysis: a
# feature genuinely serving three goals is worth knowing, and the single-theme column
# this replaced could not say it. Leave a cell blank when in doubt; a grid where most
# rows carry three marks says nothing.
GOALS = {"coverage":   "Getting more members covered",
         "discovery":  "Finding what interests you",
         "portfolios": "Enjoying portfolios of others",
         "project":    "The bigger picture",
         "durability": "Keeping it working"}
GOAL_KEYS = list(GOALS)

# The same goals for the Dutch page. Keyed identically, so a row's goal is stored once
# in the CSV and the heading it appears under is chosen per language at render time.
GOALS_NL = {"coverage":   "Meer leden in beeld krijgen",
            "discovery":  "Vinden wat jou interesseert",
            "portfolios": "Genieten van andermans portfolio's",
            "project":    "Het grotere geheel",
            "durability": "Zorgen dat het blijft werken"}

# Two renames were proposed on 7 Sept 2026 and not adopted, because each would have misdescribed
# most of its own rows. "Beyond a single club" -> "Seeing outside your own club" fits 2 of its 7:
# the rest are about the project rather than about another club, such as putting the website
# generator on the App Store, or voting on what comes next. "Keeping it working" -> "Keeping the
# data fresh" fits 1 of its 6: the others are about the software and the project surviving, not
# about data currency.
#
# The many-to-many marks do not rescue either, because the star still has to be a good primary
# fit. What the two labels really expose is that both groups are doing two jobs at once, so the
# honest fix is to split them into four goals rather than to rename two. That split still stands
# as the right answer and has not been done.
#
# On 8 Sept 2026 the `project` label was changed anyway, from "Beyond a single club" to "The
# bigger picture", because the questionnaire was about to go out. The old label was false for
# five of its seven rows, and on the reader page it sat above `upcoming-exhibitions`, which is the
# feature already chosen as the next thing to build: a heading a respondent reads as not-quite-
# fitting is a thumb on the scale against a row that must not be discouraged.
#
# "Other" was considered for this group and rejected. It is the honest name for a residual, and
# would remove the need to split at all, but these labels appear on the reader page and nowhere
# else -- the contact sheet does not group by goal -- so the only person who would ever read
# "Other" is a respondent being asked to rank the rows under it.
#
# The CSV column is still called `project` and deliberately does not track the display label. The
# keys identify columns in a data file; the labels are reader-facing wording that changes for
# reasons the data knows nothing about, as it just did. Renaming the key to match would turn every
# future label tweak into a data migration. `project` also remains the most accurate name for what
# this group holds, which is rows about the project rather than about browsing photographs:
# `scope` would describe three of its seven rows and say nothing about growth statistics, voting,
# or shipping the website generator. The moment for a naming pass is the four-way split above,
# when each group finally has a theme to name instead of a residual to label.

# feature_nl and description_nl carry the Dutch wording of the two reader-facing fields.
# They may be blank on any row that is not shortlisted; a shortlisted row without them
# stops the build, because the alternative is a Dutch page with English items on it.
COLUMNS = ["id", "feature", "description", "feature_nl", "description_nl", "repo",
           "underway", "effort", "value", "shortlist",
           *GOAL_KEYS, "tickets", "note"]


# Effort labels, smallest first. The order is the sort order everywhere; the
# weeks are what the page's matrix labels its columns with.
EFFORT = {"S": 1, "M": 3, "L": 6, "XL": 12}


def read_rows():
    """Read the CSV, accepting either delimiter.

    Numbers exports semicolon-separated files under a Dutch locale, so a file that
    has been round-tripped through a spreadsheet often comes back with ';' instead
    of ','. Both are read; the file is always written back with commas.
    """
    text = CSV_IN.read_text(encoding="utf-8-sig")

    # A spreadsheet export can start with blank rows, which arrive as ",,,,," or
    # ";;;;;" and would otherwise be read as the header. Drop anything before the
    # first line that carries actual text.
    lines = text.splitlines()
    while lines and not lines[0].strip(",; \t"):
        lines.pop(0)
    if not lines:
        sys.exit(f"error: {CSV_IN.name} is empty")
    text = "\n".join(lines)

    delimiter = ";" if lines[0].count(";") > lines[0].count(",") else ","
    rows = [r for r in csv.DictReader(io.StringIO(text), delimiter=delimiter)
            if any((v or "").strip() for v in r.values())]
    if not rows:
        sys.exit(f"error: {CSV_IN.name} holds no rows")

    missing = [c for c in COLUMNS if c not in rows[0]]
    if missing:
        sys.exit(f"error: {CSV_IN.name} is missing column(s): {', '.join(missing)}")

    seen = set()
    for n, r in enumerate(rows, start=2):          # row 1 is the header
        for c in COLUMNS:
            r[c] = (r.get(c) or "").strip()
        if not r["id"]:
            sys.exit(f"error: row {n} has no id")
        if r["id"] in seen:
            sys.exit(f"error: row {n} repeats the id '{r['id']}'")
        seen.add(r["id"])
        marks = {g: (r[g] or "").strip() for g in GOAL_KEYS}
        bad = {g: m for g, m in marks.items() if m not in ("", "x", "*")}
        if bad:
            sys.exit(f"error: row {n} ('{r['id']}') has {bad}, expected '*', 'x' or empty")
        stars = [g for g, m in marks.items() if m == "*"]
        if len(stars) != 1:
            sys.exit(f"error: row {n} ('{r['id']}') has {len(stars)} goals marked '*' "
                     f"({', '.join(stars) or 'none'}), expected exactly one")
        # The goal is stored as its key, not as a heading, so the same row can be
        # rendered under an English or a Dutch heading without storing either.
        r["goal_key"] = stars[0]
        # An empty effort is allowed, and means "no defined work to estimate yet".
        # A row can be a question about whether an area is worth pursuing rather
        # than a candidate to build, and inventing a size for one of those would
        # make it look like something it is not.
        if r["effort"] and r["effort"] not in EFFORT:
            sys.exit(f"error: row {n} ('{r['id']}') has effort '{r['effort']}', "
                     f"expected one of {', '.join(EFFORT)}, or empty")
    return rows


def write_html(rows):
    template = TEMPLATE.read_text(encoding="utf-8")
    if "__ROWS__" not in template:
        sys.exit(f"error: {TEMPLATE.name} has no __ROWS__ placeholder")
    data = json.dumps(rows, ensure_ascii=False, separators=(",", ":"))
    HTML_OUT.write_text(template.replace("__ROWS__", data), encoding="utf-8")



def esc(text):
    return (text.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;"))


def typo(text):
    """Curl the apostrophes for display, leaving the CSV in plain ASCII.

    Every apostrophe in the data is inside a word — club's, foto's, portfolio's — so
    the rule needs no cleverness: one standing between two letters is an apostrophe
    and cannot be a quotation mark. Doing this here rather than in the master means a
    row typed later with an ordinary keyboard apostrophe cannot quietly put a page
    back to mixed typography, which is the kind of thing nobody notices until it is
    printed and posted.
    """
    return re.sub(r"(?<=\w)'(?=\w)", "\u2019", text)


def write_reader(rows, template_path, out_path, goals, name_key, desc_key, started_label):
    """The version fit to hand to somebody outside the project.

    Drops the notes (written to self), the ticket numbers and the repo names, and
    groups by goal rather than sorting by effort — a reader wants subjects, not sizes.

    Shows the shortlist alone once any row is marked, and everything while none is.
    The fallback is the point: marking the twelve happens over several sittings, and
    a page that empties itself the moment the first row is ticked would be useless
    exactly while it is being assembled.

    Called once per language. Everything that differs between the two pages arrives
    as an argument, so the two outputs cannot drift apart in their structure or their
    numbering: only the wording differs.
    """
    template = template_path.read_text(encoding="utf-8")
    if "__GROUPS__" not in template:
        sys.exit(f"error: {template_path.name} has no __GROUPS__ placeholder")

    picked = [r for r in rows if r["shortlist"] == "1"]
    if picked:
        rows = picked

    # A missing translation is fatal rather than silently English. A page that mixes
    # the two is worse than no Dutch page: the reader cannot tell whether the English
    # item is an oversight or a deliberately untranslated name.
    untranslated = [r["id"] for r in rows if not (r[name_key] and r[desc_key])]
    if untranslated:
        sys.exit(f"error: {template_path.name} needs '{name_key}' and '{desc_key}' for "
                 f"every row on the page; missing on: {', '.join(untranslated)}")

    blocks = []
    number = 0  # continuous across groups: a reply says "7", not "Beyond a single club 2"
    for key, heading in goals.items():
        members = [r for r in rows if r["goal_key"] == key]
        if not members:
            continue
        # Sorted on the English name in every language, deliberately. The number is
        # what a reply refers to, so the two pages have to number identically or a
        # reply of "7" means one thing to a Dutch reader and another to an English
        # one. Sorting on the translated name would leave that to alphabetical luck
        # among rows of equal effort.
        members.sort(key=lambda r: (EFFORT.get(r["effort"], 99), r["feature"].lower()))
        items = []
        for r in members:
            number += 1
            started = (f'<span class="started">{esc(started_label)}</span>'
                       if r["underway"] == "partly" else "")
            # No effort badge. A reader asked how much they want something will
            # discount an L and favour an S, which is precisely the signal being
            # collected: their value has to arrive independent of our cost, so the
            # two can be combined afterwards rather than confounded at the source.
            items.append(
                '<div class="item">'
                f'<div class="no">{number}</div>'
                f'<div class="nm">{esc(typo(r[name_key]))}</div>'
                f'<div class="ds">{esc(typo(r[desc_key]))}</div>'
                f'<div class="meta">{started}</div>'
                "</div>")
        blocks.append(f'<section class="group"><h2>{esc(typo(heading))}</h2>'
                      f'<div class="items">{"".join(items)}</div></section>')

    out_path.write_text(template.replace("__GROUPS__", "\n".join(blocks)),
                        encoding="utf-8")


def merge_ratings(rows):
    """Fold ratings.csv into the master, matching on id.

    The web page exports only id and value, never a whole file, so applying them
    cannot revert an edit made to any other column since the page was built. Matching
    on id rather than on row position means the master can be sorted, reordered or
    extended in between without any of it mattering.

    An id that matches nothing is reported rather than ignored: it means a row was
    renamed or deleted after the page was built, and that rating is now lost.
    """
    if not RATINGS_IN.exists():
        return 0

    lines = [l for l in RATINGS_IN.read_text(encoding="utf-8-sig").splitlines()
             if l.strip(",; \t")]
    if not lines:
        return 0
    delimiter = ";" if lines[0].count(";") > lines[0].count(",") else ","
    pairs = list(csv.DictReader(io.StringIO("\n".join(lines)), delimiter=delimiter))
    if not pairs or "id" not in pairs[0] or "value" not in pairs[0]:
        sys.exit(f"error: {RATINGS_IN.name} needs an 'id' and a 'value' column")

    by_id = {r["id"]: r for r in rows}
    applied, orphans = 0, []
    for n, pair in enumerate(pairs, start=2):
        rid = (pair.get("id") or "").strip()
        val = (pair.get("value") or "").strip()
        if not rid:
            continue
        if rid not in by_id:
            orphans.append(rid)
            continue
        if val and (not val.isdigit() or not 1 <= int(val) <= 5):
            sys.exit(f"error: {RATINGS_IN.name} row {n} ('{rid}') has value '{val}', "
                     f"expected 1-5 or empty")
        by_id[rid]["value"] = val
        # The shortlist column is optional, so a ratings file exported by an older
        # build still applies cleanly and simply leaves the marks alone.
        if "shortlist" in pair:
            mark = (pair.get("shortlist") or "").strip().lower()
            if mark not in ("", "0", "1"):
                sys.exit(f"error: {RATINGS_IN.name} row {n} ('{rid}') has shortlist "
                         f"'{mark}', expected 1 or empty")
            by_id[rid]["shortlist"] = "1" if mark == "1" else ""
        applied += 1

    if orphans:
        print(f"warning: {len(orphans)} rating(s) matched no row and were dropped: "
              f"{', '.join(orphans)}", file=sys.stderr)
    return applied


def write_csv(rows):
    """Rewrite the master in a canonical form: comma-separated, every field quoted.

    Means a file edited in a spreadsheet is tidied on the next build instead of
    drifting, and keeps git diffs about content rather than about formatting.
    """
    with CSV_IN.open("w", encoding="utf-8", newline="") as f:
        w = csv.DictWriter(f, fieldnames=COLUMNS, quoting=csv.QUOTE_ALL,
                           lineterminator="\n")
        w.writeheader()
        w.writerows({c: r[c] for c in COLUMNS} for r in rows)


rows = read_rows()
applied = merge_ratings(rows)
write_csv(rows)
write_html(rows)
write_reader(rows, READER_TEMPLATE, READER_OUT, GOALS,
             "feature", "description", "Started")
write_reader(rows, READER_TEMPLATE_NL, READER_OUT_NL, GOALS_NL,
             "feature_nl", "description_nl", "Begonnen")

rated = sum(1 for r in rows if r["value"])
short = sum(1 for r in rows if r["shortlist"] == "1")
merged = f", {applied} merged from {RATINGS_IN.name}" if applied else ""
print(f"{len(rows)} candidates, {rated} rated{merged}")
# Say plainly which of the two the reader page is, so a short one is never a surprise.
print(f"reader page: {short} shortlisted row(s)" if short
      else "reader page: all rows (nothing shortlisted yet)")
# file:// URLs, percent-escaped: the repository path contains spaces, and an
# unescaped space stops most terminals treating the line as one clickable link
for out in (HTML_OUT, READER_OUT, READER_OUT_NL):
    print(f"  {out.as_uri()}")
