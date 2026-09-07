# Roadmap

Maintainer tooling. Nothing in this directory is needed to build, run or contribute to the app.
It exists so the project roadmap has one master copy instead of several drifting ones.

`feature-candidates.csv` is that master: one row per candidate feature, with an
estimate of the effort in terms of author's time and a slot for how much it is worth to users.
Everything else in this folder is generated from the CSV by `build-roadmap.py`, which takes
no arguments (`build-roadmap.command` runs it by double-click):

| File | What it is |
| --- | --- |
| `roadmap-contact-sheet.html` | Sort, filter, rate; shows value against effort as a matrix |
| `roadmap-for-readers.html` | The one to share: no notes, no ticket numbers, grouped by goal |

The build also rewrites the master itself into a canonical form — comma-separated, every field
quoted — so formatting choices made by a spreadsheet do not survive a build.

Ratings work as a round trip. The page seeds itself from the `value` column, so it
opens showing whatever the CSV holds; clicking the dots changes that copy in your
browser only. **Export ratings** then hands back `id,value,shortlist` rows — save them as
`ratings.csv` here and run the build, which merges them in.

The merge matches on `id`, so the master can be sorted, reordered or extended without breaking the merging option.
An id that matches no row is reported rather than
applied, which is what a renamed row looks like. `ratings.csv` itself is not
committed: it is an intermediate file, and the master is where the actual data is saved.

The list is a set of possibilities, honestly assessed.
It is not a plan or a commitment — nobody is paid for doing the work involved.

## Working notes are not committed

Any notes behind this list — meeting minutes, a strategy memo, and a trial scrape of the clubs
belonging to the Dutch Fotobond federation — are kept in `~/Documents/Photo Club Hub/` on the
maintainer's personal machine. Anything of that kind that does end up in this directory is
named `notes-*`, which git ignores.

## Writing a row a reader will answer

The `description` of a shortlisted row is read by a club member who installed the app as a favour and
was never part of any technical, marketing or strategy conversation. Three things went wrong repeatedly
when rows were written from the builder's side instead:

- **Ambiguous possessives.** "Your own website" reads as the reader's personal site, not their club's.
- **Vague nouns.** "A short list of likely changes" — changes to what? New members? Portfolios?
  Name the thing that happens: someone joins, someone leaves.
- **Internal concepts.** Contrasting a form with "a file format", or saying the app "writes the file for
  you", assumes a reader who knows a file exists. They do not, and the mention is faintly alarming.

Two further rules earned the hard way. Do not promise something that belongs to a different row: a
description offering a home-screen reminder invites a vote for a feature that row would not deliver. And
do not name a group the reader may not belong to, such as the Fotobond, when half of Dutch clubs are not
members and will read the row as being about somebody else.

The useful test is whether the reader's answer carries information. It does not when the question needs
them to judge something they cannot perceive, like performance at a scale they have never seen, or to
extrapolate from their own habits. Such a row belongs on the list but not in the questionnaire.

