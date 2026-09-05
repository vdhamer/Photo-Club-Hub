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

Ratings made in the HTML page are stored in that browser, not in the CSV. Its
**Copy CSV** button hands the whole table back with the values filled in, to be
pasted over `feature-candidates.csv` and rebuilt.

The list is a set of possibilities, honestly assessed. It is not a plan, a
commitment, or a schedule — nobody is paid for any of this.
