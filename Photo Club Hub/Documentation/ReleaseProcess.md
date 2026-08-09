#  Release process

How a version of Photo Club Hub reaches TestFlight and the App Store, and which parts of that are
not open to contributors. Releasing is done by the maintainer. If you are contributing code, the
part that concerns you is the last section: do not touch version numbers, and do not create tags.

## Two Macs

Development and releasing happen on two different Macs, which communicate only through GitHub.

- The **Development Mac** does the development and pushes to GitHub (aka origin).
- The **Release Mac** pulls from origin and produces the archives that go to Apple (App Store Connect). It keeps a copy
  of every archive that reached Apple.

The table says which machine is supposed to do each thing, and how strictly that is adhered to. Legend:

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
| Creating `v<version>` release tags | development | guideline |
| Creating `b<number>` build tags | development | guideline |
| Keeping the latest Xcode release and beta installed | development | policy |
| Getting code only by pulling from origin | release | policy |
| Archiving for App Store Connect | release | policy |
| Archiving with a release or RC version of Xcode | release | enforced (by Apple) |
| Uploading to TestFlight / App Store | release | policy |
| Saving every TestFlight / App Store `.xcarchive` | release | policy |
| Archiving only from source pushed to origin | release | enforced (build phase script) |

Two rows are enforced rather than habitual.

- Apple enforces the Xcode row: development normally runs on the latest Xcode beta, but an archive
  built with a beta Xcode can go to TestFlight and never to the App Store, so the release Mac stays
  on a release or RC Xcode whatever the destination.
- We enforce the last row ourselves: the gate in the build phase (below) refuses to archive from a
  working tree that is dirty or not pushed to origin.

The next `MARKETING_VERSION` is decided up front, at step 1 of the loop below, and it binds nobody
else: it is a label for users, not a promise to another repo. The one version decision that does
reach beyond this repo is raising the Data package floor, which is a deliberate edit rather than a
consequence of releasing (see below).

Most of this split between the machines is *not* technically enforced: in principle both Macs can do
everything, so much of it is habit. Nothing here strictly *requires* two Macs — one Mac with both
Xcodes could do all of it. The two exist anyway (a 0.5 TB laptop and an older 1 TB Mac Studio), and
the split earns its keep: the extra hop makes releasing deliberate rather than casual, the
archive-of-archives has somewhere with the disk space for it, and because the Macs talk only via
GitHub, origin is always up to date.

## Version numbers

Two independent numbers, both stored in `project.pbxproj` and both set by hand on the development
Mac, exactly once per release cycle (step 1 of the loop).

`MARKETING_VERSION` is the version users see, e.g. `3.0.0`. It is a **label**: what a bump means is
the maintainer's call, it promises nothing to any other repo, and no test asserts a relationship to
anything. Semantic versioning describes an API contract, and an app has no API — so the three
components carry whatever weight the release deserves, and the release notes say what changed.

`CURRENT_PROJECT_VERSION` is the build number, e.g. `4665`. It only ever rises, and counts archives
that reached Apple rather than releases: most builds stop at TestFlight. App Store Connect rejects
an upload whose build number is not higher than one already seen for that marketing version
(ITMS-4238, "Redundant Binary Upload"). That rejection is deliberately left armed: the Organizer's
"Manage Version and Build Number" option stays **unchecked** (step 5), so a forgotten bump fails
loudly at upload instead of shipping a silently renumbered binary.

## The Data package dependency

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

What each release was actually built against is recorded in `Package.resolved` — version *and*
revision — which is the durable answer, and more precise than any version number.

## The gate-and-stamp build phase

The `Run GateAndStamp script` build phase, the last phase of the app target, runs
`scripts/gate-and-stamp.sh` — the phase itself is only a three-line invoker, so the script stays
reviewable and greppable instead of living escaped inside `project.pbxproj`. It does two jobs, and
writes only into the built app, never the source tree, so neither Mac's working tree is affected.

- **Stamps, on every build.** Two keys are added to the built app's `Info.plist`:
  `GitCommitHash` — the exact commit, with `-dirty` appended when built from uncommitted changes —
  and `BuildDate`, local time at minute resolution. Because the version and build number are frozen
  for the whole development phase of a cycle, the stamps are what distinguish and order the Debug
  installs sitting on test devices. They are shown in the iOS Settings app (#807) and in the HTML
  app's About box (Photo-Club-Hub-HTML #239).
- **Gates, only when archiving.** The phase refuses to archive from a dirty working tree or from a
  commit that is not on origin. This is what makes the last row of the two-Mac table "enforced".

The script takes no arguments and is not meant to be run by hand: outside a build it exits with
`PROJECT_DIR unset, so this is not an Xcode build phase`. Photo-Club-Hub-HTML carries its own copy
at the same path, since the two repos are separate.

An archived build can therefore never read `-dirty`, and its hash matches the commit its
`b<number>` tag points at.

## The release loop

Releasing is a loop:

1. **Bump, immediately after the previous upload to App Store Connect.** On the development Mac,
   raise `CURRENT_PROJECT_VERSION` — always — and `MARKETING_VERSION` if the previous cycle reached
   the App Store, by as much as the coming release deserves. Commit and push. These commits are
   recognisable in the log as "Preparation for next release" or "Updated MARKETING_VERSION to …".
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
   build is promoted to the App Store, tag the same commit `v<version>` and publish a full GitHub
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
- `v<version>`, e.g. `v2.12.0` — "this build was released to the App Store." Created only when that
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
