#!/usr/bin/env python3
#
# build-roadmap.py — regenerate the roadmap views from feature-candidates.csv
#
# Reads  feature-candidates.csv   the master list of roadmap candidates
#        roadmap-template.html    page design and behaviour, with a __ROWS__ placeholder
# Writes roadmap-contact-sheet.html   interactive: sort, filter, rate, value/effort matrix
#        roadmap.md                   plain table, sorted by effort, for reading and printing
#        roadmap-for-readers.html     the shareable one: no notes, no ticket numbers, grouped by theme
#
# The CSV is the only place data lives. The page embeds a copy at build time, so
# editing the CSV means running this again. Ratings entered in the page live in
# the reader's browser until exported from it and merged back into the CSV by hand.
#
# Takes no arguments. Run it from anywhere; paths are resolved next to this file.

import csv
import io
import json
import sys
from pathlib import Path

if len(sys.argv) > 1:
    sys.exit("error: this script takes no arguments")

HERE = Path(__file__).resolve().parent
CSV_IN = HERE / "feature-candidates.csv"
TEMPLATE = HERE / "roadmap-template.html"
HTML_OUT = HERE / "roadmap-contact-sheet.html"
MD_OUT = HERE / "roadmap.md"
READER_TEMPLATE = HERE / "reader-template.html"
READER_OUT = HERE / "roadmap-for-readers.html"

COLUMNS = ["id", "feature", "description", "repo",
           "underway", "effort", "value", "theme", "tickets", "note"]

# Reader-facing groups, in the order they appear on the shareable page. A theme
# outside this list is a typo rather than a new group, so the build stops on it.
THEMES = ["Getting more clubs on board",
          "Finding what interests you",
          "Looking at the photographs",
          "Beyond a single club",
          "Keeping it working"]

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
    header = text.split("\n", 1)[0]
    delimiter = ";" if header.count(";") > header.count(",") else ","
    rows = list(csv.DictReader(io.StringIO(text), delimiter=delimiter))
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
        if r["theme"] not in THEMES:
            sys.exit(f"error: row {n} ('{r['id']}') has theme '{r['theme']}', "
                     f"expected one of: {'; '.join(THEMES)}")
        if r["effort"] not in EFFORT:
            sys.exit(f"error: row {n} ('{r['id']}') has effort '{r['effort']}', "
                     f"expected one of {', '.join(EFFORT)}")
    return rows


def write_html(rows):
    template = TEMPLATE.read_text(encoding="utf-8")
    if "__ROWS__" not in template:
        sys.exit(f"error: {TEMPLATE.name} has no __ROWS__ placeholder")
    data = json.dumps(rows, ensure_ascii=False, separators=(",", ":"))
    HTML_OUT.write_text(template.replace("__ROWS__", data), encoding="utf-8")


def write_markdown(rows):
    ordered = sorted(rows, key=lambda r: (EFFORT[r["effort"]], r["feature"].lower()))
    out = [
        "# Roadmap Contact Sheet",
        "",
        f"{len(ordered)} candidates, sorted by effort and then by name.",
        "Effort estimates Peter's time: "
        + ", ".join(f"**{k}** {v} week{'s' if v > 1 else ''}" for k, v in EFFORT.items())
        + ".",
        "",
        "| Feature | What a user would be told | Repo | Underway | Effort | Value | Tickets |",
        "|---|---|---|---|:--:|:--:|---|",
    ]
    for r in ordered:
        out.append(
            f"| **{r['feature']}** | {r['description']} | {r['repo']} | "
            f"{r['underway']} | {r['effort']} | {r['value']} | {r['tickets'] or '—'} |"
        )

    noted = [r for r in ordered if r["note"]]
    if noted:
        out += ["", "## Notes", ""]
        out += [f"- **{r['feature']}** — {r['note']}" for r in noted]

    tally = {k: sum(1 for r in ordered if r["effort"] == k) for k in EFFORT}
    out += ["", "## Shape", "", "| Size | Weeks | Count |", "|---|--:|--:|"]
    out += [f"| {k} | {EFFORT[k]} | {tally[k]} |" for k in EFFORT if tally[k]]
    MD_OUT.write_text("\n".join(out) + "\n", encoding="utf-8")


def esc(text):
    return (text.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;"))


def write_reader(rows):
    """The version fit to hand to somebody outside the project.

    Drops the notes (written to self), the ticket numbers and the repo names, and
    groups by theme rather than sorting by effort — a reader wants subjects, not sizes.
    """
    template = READER_TEMPLATE.read_text(encoding="utf-8")
    if "__GROUPS__" not in template:
        sys.exit(f"error: {READER_TEMPLATE.name} has no __GROUPS__ placeholder")

    blocks = []
    for theme in THEMES:
        members = [r for r in rows if r["theme"] == theme]
        if not members:
            continue
        members.sort(key=lambda r: (EFFORT[r["effort"]], r["feature"].lower()))
        items = []
        for r in members:
            started = ('<span class="started">Started</span>'
                       if r["underway"] == "partly" else "")
            items.append(
                '<div class="item">'
                f'<div class="nm">{esc(r["feature"])}</div>'
                f'<div class="ds">{esc(r["description"])}</div>'
                f'<div class="meta">'
                f'<span class="eff" style="background:var(--{r["effort"].lower()})">'
                f'{r["effort"]}</span>{started}</div>'
                "</div>")
        blocks.append(f'<section class="group"><h2>{esc(theme)}</h2>'
                      f'<div class="items">{"".join(items)}</div></section>')

    READER_OUT.write_text(template.replace("__GROUPS__", "\n".join(blocks)),
                          encoding="utf-8")


def write_csv(rows):
    """Rewrite the master in a canonical form: comma-separated, every field quoted.

    Means a file edited in a spreadsheet is tidied on the next build instead of
    drifting, and keeps git diffs about content rather than about formatting.
    """
    with CSV_IN.open("w", encoding="utf-8", newline="") as f:
        w = csv.DictWriter(f, fieldnames=COLUMNS, quoting=csv.QUOTE_ALL)
        w.writeheader()
        w.writerows({c: r[c] for c in COLUMNS} for r in rows)


rows = read_rows()
write_csv(rows)
write_html(rows)
write_markdown(rows)
write_reader(rows)

rated = sum(1 for r in rows if r["value"])
print(f"{len(rows)} candidates, {rated} rated")
print(f"  {HTML_OUT.name}")
print(f"  {MD_OUT.name}")
print(f"  {READER_OUT.name}")
