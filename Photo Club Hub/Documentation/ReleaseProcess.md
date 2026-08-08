#  Release process

How a version of Photo Club Hub reaches TestFlight and the App Store, and which parts of that are
not open to contributors. Releasing is done by the maintainer. If you are contributing code, the
part that concerns you is the last section: do not touch version numbers, and do not create tags.

## Two Macs

Development and releasing happen on different machines, which communicate only through GitHub.

- The **development Mac** does the development and pushes to origin.
- The **release Mac** pulls from origin and produces the archives that go to Apple. It keeps a copy
  of every archive that reached Apple.

Little of this split is technically enforced: both Macs can do everything, so most of it is habit.
The table says which machine is supposed to do each thing, and how firmly that holds.

- **enforced** — the other Mac is technically prevented
- **policy** — not enforced, but deviating is a mistake and does not happen in practice
- **guideline** — the intent; deviates occasionally, on the order of 1 release in 10

| Activity | Machine | Rule strength |
| --- | --- | --- |
| Development editing | development | guideline |
| Commits and pushes to origin | development | guideline |
| Debug builds and simulator runs | development | guideline |
| Deciding the target `major.minor` for the next release | development | policy |
| Post-release setting of the next marketing version | development | policy |
| Post-release bumping of the build number | development | policy |
| Creating `v<semver>` release tags | development | guideline |
| Creating `b<number>` build tags | development | guideline |
| Keeping the latest released and beta Xcode installed | development | policy |
| Getting code only by pulling from origin | release | policy |
| Archiving for App Store Connect | release | policy |
| Archiving with a non-beta Xcode | release | enforced (by Apple) |
| Uploading to TestFlight / App Store | release | policy |
| Keeping every shipped `.xcarchive` | release | policy |
| Archiving only from source pushed to origin | release | enforced (build phase) |

Two rows are enforced rather than habitual. Apple enforces the Xcode row: development normally runs
on the latest Xcode beta, but an archive built with a beta Xcode can go to TestFlight and never to
the App Store, so the release Mac stays on a non-beta Xcode whatever the destination. The last row
is enforced by us: the gate in the build phase (below) refuses to archive from a working tree that
is dirty or not pushed to origin.

App Store users never receive two patch levels of the same `major.minor`: at most one patch level of
a given `major.minor` reaches the App Store. The target `major.minor` is therefore decided up front,
at step 1 of the loop below.

Nothing here strictly *requires* two Macs — one Mac with both Xcodes could do all of it. The two
exist anyway (a 0.5 TB laptop and an older 1 TB Mac Studio), and the split earns its keep: the
archive-of-archives needs the disk space, the extra hop makes releasing deliberate rather than
casual, and because the Macs talk only via GitHub, origin is always up to date.

## Version numbers

Two independent numbers, both stored in `project.pbxproj` and both set by hand on the development
Mac, exactly once per release cycle (step 1 of the loop):

- `MARKETING_VERSION` — the semantic version users see, e.g. `2.11.3`. Its `major.minor` is shared
  with the Photo-Club-Hub-Data and Photo-Club-Hub-HTML repos as a release train; the patch level
  floats per repo. See `CLAUDE.md` for what a minor bump implies for the package dependency.
- `CURRENT_PROJECT_VERSION` — the build number, e.g. `4665`. It only ever rises. App Store Connect
  rejects an upload whose build number is not higher than one already seen for that marketing
  version (ITMS-4238, "Redundant Binary Upload"). That rejection is deliberately left armed: the
  Organizer's "Manage Version and Build Number" option stays **unchecked** (step 5), so a forgotten
  bump fails loudly at upload instead of shipping a silently renumbered binary.

## The gate-and-stamp build phase

A script phase in the Xcode project does two jobs. It writes only into the built app, never the
source tree, so neither Mac's working tree is affected.

- **Stamps, on every build.** Two keys are added to the built app's `Info.plist`:
  `GitCommitHash` — the exact commit, with `-dirty` appended when built from uncommitted changes —
  and `BuildDate`, local time at minute resolution. Because the version and build number are frozen
  for the whole development phase of a cycle, the stamps are what distinguish and order the Debug
  installs sitting on test devices. They are shown in the iOS Settings app (#807) and in the HTML
  app's About box (Photo-Club-Hub-HTML #239).
- **Gates, only when archiving.** The phase refuses to archive from a dirty working tree or from a
  commit that is not on origin. This is what makes the last row of the two-Mac table "enforced".

An archived build can therefore never read `-dirty`, and its hash matches the commit its
`b<number>` tag points at.

## The release loop

Releasing is a loop rather than a one-off sequence. One turn of it:

1. **Bump, immediately after the previous upload to App Store Connect.** On the development Mac,
   raise `CURRENT_PROJECT_VERSION`, and `MARKETING_VERSION` too unless the next release is a patch.
   Commit and push. These commits are recognisable in the log as "Preparation for next release" or
   "Updated MARKETING_VERSION to …".
2. **Develop** on the development Mac, keeping `ReleaseNotes.md` and origin up to date as work lands.
3. **Push to origin** once more for the release, then pull on the release Mac — the only channel
   between the two.
4. **Archive** on the release Mac, with a non-beta Xcode. The build phase refuses a dirty or
   unpushed tree, then stamps commit and build time into the archive.
5. **Distribute to App Store Connect** from the Organizer, with "Manage Version and Build Number"
   **unchecked** — verify this every time, and assume it defaults back to on. A rejection with
   ITMS-4238 means step 1 was skipped: bump, push, pull, re-archive. Nothing is burned and nothing
   drifts.
6. **Keep the `.xcarchive`** on the release Mac, alongside every earlier one. No separate source
   tree copy is needed: the stamp in the archive names the commit, and git does find, fetch and
   diff.
7. **Tag the archived commit `b<number>`** and publish it as a pre-release GitHub Release, from the
   development Mac. Every upload gets this tag, whatever later becomes of the build.
8. **Release in App Store Connect** to TestFlight, or to TestFlight and then the App Store. If the
   build is promoted to the App Store, tag the same commit `v<semver>` and publish a full GitHub
   Release. If the build is abandoned ("not good enough, make another one"), record why in the
   `b<number>` release notes.
9. Back to step 1.

Note when things are decided. The numbers are fixed at step 1, at the start of the cycle. The
destination — TestFlight only, on to the App Store, or another turn of the loop — is decided at
step 8, at the end, and recorded there and then. The loop may run several times per marketing
version; each turn leaves its own `b<number>` tag.

## Tags and GitHub Releases

Two tags with distinct meanings, both created on the development Mac and both published as GitHub
Releases:

- `b<number>`, e.g. `b4666` — "this commit was uploaded to App Store Connect as build number
  <number>." Created for every upload (step 7), marked as a pre-release on GitHub. If the build
  never goes further, its release notes say so (superseded, rejected).
- `v<semver>`, e.g. `v2.12.0` — "this build was released to the App Store." Created only when that
  decision is made (step 8), on the same commit as its `b<number>` tag, as a full GitHub Release.

A TestFlight-only build carries only its `b` tag; an App Store release carries both. Nothing about
a build's destination is inferred from how a tag was named: the tag is the record, written when the
decision happens. Tags predating this convention were applied loosely, so gaps in the older part of
the `b<number>` sequence do not all mean the same thing.

## If you contribute code

- **Do not change `MARKETING_VERSION` or `CURRENT_PROJECT_VERSION`.** They are set between releases
  by the maintainer; a pull request that touches them conflicts with the next preparation commit.
- **Do not create `b…` or `v…` tags, or publish GitHub Releases.**
- **Do add your change to `ReleaseNotes.md`.** That is the part of the release that contributors
  own.
- Everything else about contributing is in the `Contributing` section of the
  [README](https://github.com/vdhamer/Photo-Club-Hub/blob/main/.github/README.md).

Background and the reasoning behind the numbering rules:
[issue #808](https://github.com/vdhamer/Photo-Club-Hub/issues/808).
