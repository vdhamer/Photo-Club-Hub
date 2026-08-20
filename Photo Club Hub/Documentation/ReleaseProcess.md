#  Release process

How a version of Photo Club Hub reaches TestFlight and the App Store. The maintainer does the
releasing, across two Macs. The same shape will apply to Photo Club Hub __HTML__ once that is
distributed the same way, and it connects to how the Photo Club Hub __Data__ package is versioned.

**Contributing code?** Three house rules for contributors:

- Add what you changed to `ReleaseNotes.md`. That part of a release is yours.
- Leave `MARKETING_VERSION` and `CURRENT_PROJECT_VERSION` alone. The maintainer sets them between
  releases, and a pull request that touches them collides with the next preparation commit.
- Leave `b…` and `v…` tags and GitHub Releases to the maintainer. They record what was uploaded to
  Apple and what shipped — events a pull request cannot see.

Everything else about contributing is in the `Contributing` section of the
[README](https://github.com/vdhamer/Photo-Club-Hub/blob/main/.github/README.md).

The other parts of this document is mainly a releasing checklist for the maintainer.
For the maintainer, the steps come first, then a note on each, then annexes with the reasoning:
the machine split, the numbering rules, the Core Data model, the Data package, the build-phase
script, and the tags.

## The release loop

Releasing is a loop. "Dev" is the **development Mac**, "Release" the **release Mac**; Annex A explains why
there are two.

| Step | What | Where |
| --- | --- | --- |
| 1 | Bump build number and marketing version; add matching data model version; commit; push | Dev |
| 2 | Develop, keeping `ReleaseNotes.md` and origin (GitHub) up to date | Dev |
| 3 | Run both test suites, push to origin, then pull changes on the release Mac | Dev → Release |
| 4 | Archive, with a Release or RC version of Xcode | Release |
| 5 | Distribute to App Store Connect, "Manage Version and Build Number" | Release |
| 6 | Keep the `.xcarchive` alongside earlier archives | Release |
| 7 | Tag the archived commit `b<number>`, publish it as a pre-release GitHub Release | Dev |
| 8 | Release to TestFlight; if promoted, tag `v<version>` and publish a full Release | Dev |
| 9 | Back to step 1 | |

Note when things are decided. The numbers are fixed at step 1, at the **start** of the cycle. The
destination — TestFlight only, on to the App Store, or another turn of the loop — is decided at
step 8, at the end, and recorded there and then. The loop may run several times per marketing
version; each turn under its unique `b<number>` tag.

## Notes on the steps

**Step 1 — bump immediately after the previous upload.** Raise `CURRENT_PROJECT_VERSION` — always —
and raise `MARKETING_VERSION` to the expected next version, by as much as the coming work deserves.
That second bump is provisional: it assumes the build just uploaded is the one that reaches the App
Store. If that build later needs replacing, lower `MARKETING_VERSION` back to the version being
rebuilt — safe, because nothing has shipped under the higher number yet. The build number never goes
down. The bump comes straight after the upload, not once the outcome is known, because the outcome
takes days: TestFlight testers need time, and App Store review runs in parallel with their testing.
Development continues meanwhile, so the numbers in the tree must describe the next build, not the
last one. Add the matching Core Data model version at the same time (Annex C), so the model name
never lags the version being built. These commits show up in the log as "Preparation for next
release", "Preparation for next build" or "Updated MARKETING_VERSION to …".

**Step 3 — nothing downstream checks the tests.** The app's tests run in Xcode on the development
Mac; Photo-Club-Hub-Data's run there too and again in GitHub Actions on every push
(`.github/workflows/tests.yml`). The gate inspects only the working tree, and an Xcode Archive never
runs tests, so a green suite before the push is the whole safeguard. Pushing to origin and pulling
on the release Mac is the only channel between the two machines.

**Step 4 — what the gate does.** The build phase refuses a dirty or unpushed tree, then stamps
commit and build time into the archive. Untracked files count as dirty. Annex E has the details.

**Step 5 — the unchecked box.** Verify "Manage Version and Build Number" is off every time, and
assume it defaults back to on. A rejection with ITMS-4238 means step 1 was skipped: bump, push,
pull, re-archive. Nothing is burned and nothing drifts. _Note_: did not do this last time because
I simply couldn't find the checkbox. As long as version and build are unique (guarded by a script)
App Store Connect won't modify the numbers.

**Step 7 — every upload gets a tag**, regardless of whether the upload stays a pre-release or is released.

**Step 8 — promotion is a decision, not Apple's timing.** App Store Connect is set to release
manually rather than automatically on approval, so passing review ships nothing by itself. If the
build is promoted, tag the same commit `v<version>` and publish a full GitHub Release. If it is
abandoned ("not good enough, make another one"), record why in the `b<number>` release notes.

## Annex A — Two Macs

Development and releasing happen on two Macs, which talk only through GitHub.

- The **Development Mac** does the development and pushes to GitHub (aka origin).
- The **Release Mac** pulls from `origin` and produces the archives that go to Apple (App Store
  Connect). It keeps a copy of every archive that reaches Apple App Store Connect.

The table says which machine should do each thing, and how strictly that holds. Legend:

- **enforced** — guarded against errors by some form of automation
- **policy** — not enforced, but deviating is a mistake and does not happen in practice
- **guideline** — the intent; deviates occasionally, on the order of 1 release in 10

| Activity | Machine | Rule strength |
| --- | --- | --- |
| Development editing | development | guideline |
| Commits and pushes to origin/GitHub   | development | guideline |
| Debug builds and simulator/device runs (Device Hub)       | development | guideline |
| Deciding the next `MARKETING_VERSION` | development | policy |
| Post-release setting of the *next* marketing version | development | policy |
| Post-release bumping of the build number | development | policy |
| Running the test suites before a release | development | policy |
| Creating `v<version>` release tags | development | guideline |
| Creating `b<number>` build tags | development | guideline |
| Keeping the latest Xcode release and beta installed | development | policy |
| Getting code only by pulling from origin | release | policy |
| Archiving for App Store Connect | release | policy |
| Archiving with a Release or RC version of Xcode | release | enforced (by Apple) |
| Uploading to TestFlight / App Store | release | policy |
| Saving every TestFlight / App Store `.xcarchive` | release | policy |
| Archiving only from source pushed to origin | release | enforced (build phase script) |

Most of the split is *not* technically enforced: both Macs can do everything in principle, so much
of it is habit. Nothing here strictly *requires* two Macs — one Mac with both Xcodes could do all
of it. The two exist anyway (a 0.5 TB laptop and an older 1 TB Mac Studio), and
the split earns its keep: the extra hop makes releasing deliberate rather than casual, the
archive-of-archives has somewhere with the disk space for it, and because the Macs talk only via
GitHub, origin is always up to date.

Two rows in the table are enforced rather than habitual.

- Apple enforces the Xcode row: our development normally runs on the latest Xcode beta, but an
  archive built with a beta Xcode can only go to TestFlight, never to the App Store.
  So the release Mac generally uses a Release or RC Xcode whatever the destination.
- We enforce the last row ourselves: the gate in the build phase (Annex E) refuses to archive from a
  working tree that is dirty or not pushed to origin.

## Annex B — Version numbers

Two independent numbers, both stored in `project.pbxproj` and both set by hand on the development
Mac, normally once per release cycle (step 1; `MARKETING_VERSION` may be lowered again there if the
uploaded build has to be replaced).

`MARKETING_VERSION` is the version users see, e.g. `3.0.0`. It is a **label**: what a bump means is
the maintainer's call, it promises nothing to any other repo, and no test asserts a relationship to
anything. Semantic versioning describes an API contract, and an app has no API — so the three
components carry whatever weight the release deserves, and the release notes say what changed. The
one version decision that reaches beyond this repo is raising the Data package floor — a deliberate
edit, not a side effect of releasing (Annex D).

Nothing on GitHub stops a contributor from editing either number: a pull request may change
`project.pbxproj` like any other file, so that house rule rests on review, not on a permission. The
build number in particular counts uploads to Apple, which a contributor cannot observe.

`CURRENT_PROJECT_VERSION` is the build number, e.g. `4665`. It only ever rises, and counts archives
that reached Apple rather than releases: most builds stop at TestFlight. App Store Connect rejects
an upload whose build number is not higher than one already seen for that marketing version
(ITMS-4238, "Redundant Binary Upload"). That rejection is deliberately left armed: the Organizer's
"Manage Version and Build Number" option stays **unchecked** (step 5), so a forgotten bump fails
loudly at upload instead of shipping a silently renumbered binary.

## Annex C — The Core Data model version

The Core Data model is versioned in step with `MARKETING_VERSION`: each release gets its own
`.xcdatamodel` inside `Photo Club Hub/Model/Photo_Club_Hub.xcdatamodeld`, named after the version
with dots as underscores — `Photo_Club_Hub_3_0_1.xcdatamodel` for 3.0.1 — with `.xccurrentversion`
pointing at it. The copy is made at step 1, alongside the number bumps, through Xcode's
*Editor → Add Model Version*.

It is made whether or not the model changed, and that is the point: without it, a model named after
an older version gets edited while a newer version of the app is shipping. If `MARKETING_VERSION` is
lowered again in step 1 because the uploaded build needs replacing, the model copy follows it.

Adding a version copies the whole bundle, so `ConfigurationColors.json` and `EntityColors.json`
appear as new untracked files still carrying the older copy's timestamps. Commit them with the
model: the archive gate counts untracked files as a dirty working tree.

Fourteen of the thirty-four successive model versions are byte-identical to their predecessor, and
among recent releases nearly all are. They are the convention working, not duplicates to clean up.
Two gaps predate this being written down: nothing exists for 2.11.x, and nothing for 3.0.0 — build
4665 shipped on `Photo_Club_Hub_2_10_1.xcdatamodel`. If a 3.0.0 build 4666 is needed,
`Photo_Club_Hub_3_0_0.xcdatamodel` gets created then; otherwise the gap stays.

## Annex D — The Data package dependency

The Photo-Club-Hub-Data package is the mirror image: its version *is* a contract, in plain
[semantic versioning](https://semver.org) — MAJOR for a change that breaks consumers, MINOR for
added public API, PATCH for fixes. It has an API, so semver means something for it.

Both apps consume it the ordinary way, which is also what Xcode generates by default:

```swift
.upToNextMajorVersion(from: "3.0.0")   // resolves [3.0.0, 4.0.0)
```

A breaking package release therefore cannot arrive unasked — it lands outside the range and simply
does not resolve. Raising the floor is a deliberate edit in each app, not a side effect of releasing.

Until 2.11.x the three repos instead shared the first two components of their versions as a "release
train", with the compatibility boundary at the second position. The numbers were semver-shaped but
carried different meanings, which made the conventional `upToNextMajor` pin unsafe for anyone who
did not know the local rules. All three were aligned at **3.0.0** once and float independently from
then on: matching numbers prove nothing and are not maintained. The reasoning is in
[issue #808](https://github.com/vdhamer/Photo-Club-Hub/issues/808).

`Package.resolved` records what each release was actually built against — version *and* revision.
That is the durable answer, more precise than any version number.

## Annex E — The gate-and-stamp build phase

The `Run GateAndStamp script` build phase, the last phase of the app target, runs
`scripts/gate-and-stamp.sh`. The phase itself is only a three-line invoker, so the script stays
reviewable and greppable instead of living escaped inside `project.pbxproj`. It does two jobs, and
writes only into the built app, never the source tree, so neither Mac's working tree is affected.

- **Stamps, on every build.** Two keys are added to the built app's `Info.plist`:
  `GitCommitHash` — the exact commit, with `-dirty` appended when built from uncommitted changes —
  and `BuildDate`, local time at minute resolution. The version and build number are frozen for
  the whole development phase of a cycle, so the stamps are what distinguish and order the Debug
  installs sitting on test devices. They are shown in the iOS Settings app (#807) and in the HTML
  app's About box (Photo-Club-Hub-HTML #239).
- **Gates, only when archiving.** The phase refuses to archive from a dirty working tree or from a
  commit that is not on origin. This is what makes the last row of the Annex A table "enforced".

The script takes no arguments and is not meant to be run by hand: outside a build it exits with
`PROJECT_DIR unset, so this is not an Xcode build phase`. Photo-Club-Hub-HTML carries its own copy
at the same path, since the two repos are separate.

An archived build can therefore never read `-dirty`, and its hash matches the commit its
`b<number>` tag points at.

## Annex F — Tags and GitHub Releases

Two tags with distinct meanings, both created on the development Mac and both published as GitHub
Releases:

- `b<number>`, e.g. `b4666` — "this commit was uploaded to App Store Connect as build number
  <number>." Created for every upload (step 7), marked as a pre-release on GitHub. If the build
  never goes further, its release notes say so (superseded, rejected).
- `v<version>`, e.g. `v2.12.0` — "this build was released to the App Store." Created only when that
  decision is made (step 8), on the same commit as its `b<number>` tag, as a full GitHub Release.

A TestFlight-only build carries only its `b` tag; an App Store release carries both. Nothing about
a build's destination is inferred from how a tag was named: the tag is the record, written when the
decision happens. Tags predating this convention were applied loosely, so gaps in the older part of
the `b<number>` sequence do not all mean the same thing.

Both prefixes are protected by a tag ruleset: creating, moving and deleting `b*` and `v*` tags is
restricted to the repository admin. Moving and deleting are the valuable half — a tag is the record
of what shipped, and creation was never reachable by contributors anyway, since a fork cannot push
a tag here. The sibling repos carry the same ruleset: Photo-Club-Hub-HTML with both prefixes,
Photo-Club-Hub-Data with `v*` only, as it has no build tags and its `v*` tags are the package
contract.

Contributors cannot create these tags in any case: contributions arrive as pull requests from
forks, and a fork has no write access here, so it can neither push a tag nor publish a Release. The
ruleset covers the case where someone is granted write access.

Each repo keeps its exported copy at `.github/rulesets/release-tags.json`. That file is a record,
not configuration: GitHub reads no rules from the repository, and re-importing it would create a
second ruleset rather than update the existing one. Updating in place is
`PUT /repos/vdhamer/Photo-Club-Hub/rulesets/20984692`. A ruleset binds admins as well unless the
bypass list names them, which is what the `bypass_actors` entry (`RepositoryRole` 5, repository
admin) is for.

Background and the reasoning behind the numbering rules:
[issue #808](https://github.com/vdhamer/Photo-Club-Hub/issues/808).
