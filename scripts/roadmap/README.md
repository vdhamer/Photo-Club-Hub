# Roadmap

Maintainer tooling. Nothing here is needed to build, run or contribute to the app —
it exists so the roadmap has one master copy instead of several drifting ones.

`feature-candidates.csv` is that master: one row per candidate feature, with an
estimate of the effort in Peter's time and a slot for how much it is worth to users.
Everything else in this folder is generated from it by `build-roadmap.py`, which takes
no arguments (`build-roadmap.command` runs it by double-click):

| File | What it is |
| --- | --- |
| `roadmap-contact-sheet.html` | Sort, filter, rate; shows value against effort as a matrix |
| `roadmap.md` | The same table as plain text, sorted by effort, for reading and printing |

Ratings work as a round trip. The page seeds itself from the `value` column, so it
opens showing whatever the CSV holds; clicking the dots changes that copy in your
browser only. **Export ratings** then hands back `id,value` pairs — save them as
`ratings.csv` beside the master and run the build, which merges them in.

The merge matches on `id`, never on row position, so the master can be sorted,
reordered or extended in between. An id that matches no row is reported rather than
applied, which is what a renamed row looks like. `ratings.csv` itself is not
committed: it is a hand-off file, and the master is where the numbers live.

The list is a set of possibilities, honestly assessed. It is not a plan, a
commitment, or a schedule — nobody is paid for any of this.

## Working notes are not in this repository

The private material behind this list — meeting notes, a strategy memo, a one-page
summary written for an external party, and a scraped list of Dutch photo club
federation members — lives in `~/Documents/Photo Club Hub/` on the maintainer's
machine, not here.

If you have cloned or forked this repository, this section is not for you: none of it
is needed to build, run or contribute to anything, and by the time you read this it
will be about conversations that have moved on. It is written down because a file that
git ignores but that sits inside a git working tree has no backup and is exactly what
`git clean -xdf` removes without asking. A pointer that survives in version control is
the only durable record of where those files went.

The one exception still kept here is `notes-l2-census/`, a few hundred megabytes of
cached club web pages. That one is ignored on purpose and can be regenerated, so
losing it costs an afternoon of polite crawling rather than anything irreplaceable.

