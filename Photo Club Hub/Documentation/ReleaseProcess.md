#  Release process

How a version of Photo Club Hub reaches TestFlight and the App Store, and which parts of that are
not open to contributors. Releasing is done by the maintainer. If you are contributing code, the
part that concerns you is the last section: do not touch version numbers, and do not create tags.

## Two Macs

Development and releasing happen on different machines, which communicate only through GitHub.

- The **development Mac** does the development and pushes to origin.
- The **release Mac** pulls from origin and produces the archives that go to Apple. It keeps a copy
  of every archive that reached Apple.

Almost none of this split is technically enforced: both Macs can do everything, so most of it is
habit. The table says which machine is supposed to do each thing, and how firmly that holds.

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
| Archiving only from source pushed to origin | release | guideline |

The Xcode row is the only hard constraint: development normally runs on the latest Xcode beta, but
an archive built with a beta Xcode can go to TestFlight and never to the App Store. The release Mac
therefore stays on a non-beta Xcode whatever the destination, while the development Mac keeps both
installed.

App Store users never receive two patch levels of the same `major.minor`: at most one patch level of
a given `major.minor` reaches the App Store. The target `major.minor` is therefore decided up front,
at step 1 of the loop below.

Nothing here strictly *requires* two Macs — one Mac with both Xcodes could do all of it. The two
exist anyway (a 0.5 TB laptop and an older 1 TB Mac Studio), and the split earns its keep: the
archive-of-archives needs the disk space, the extra hop makes releasing deliberate rather than
casual, and because the Macs talk only via GitHub, origin is always up to date.

## Version numbers

Two independent numbers, both stored in `project.pbxproj` and both set by hand on the development
Mac:

- `MARKETING_VERSION` — the semantic version users see, e.g. `2.11.3`. Its `major.minor` is shared
  with the Photo-Club-Hub-Data and Photo-Club-Hub-HTML repos as a release train; the patch level
  floats per repo. See `CLAUDE.md` for what a minor bump implies for the package dependency.
- `CURRENT_PROJECT_VERSION` — the build number, e.g. `4665`. It only ever rises. App Store Connect
  rejects an upload whose build number is not higher than one already seen for that marketing
  version (ITMS-4238, "Redundant Binary Upload").

## The release loop

Releasing is a loop rather than a one-off sequence. One turn of it:

1. **Bump, immediately after the previous upload to App Store Connect.** On the development Mac,
   raise `CURRENT_PROJECT_VERSION`, and `MARKETING_VERSION` too unless the next release is a patch.
   Commit and push. These commits are recognisable in the log as "Preparation for next release" or
   "Updated MARKETING_VERSION to …".
2. **Develop** on the development Mac, keeping `ReleaseNotes.md` and origin up to date as work lands.
3. **Push to origin** once more for the release, then pull on the release Mac — the only channel
   between the two.
4. **Archive** on the release Mac, with a non-beta Xcode. A TestFlight-only build may technically be
   archived with a beta Xcode, but it can then never be promoted to the App Store.
5. **Distribute to App Store Connect** from the Organizer.
6. **Keep the `.xcarchive`** on the release Mac, alongside every earlier one.
7. **Copy the source tree** on the release Mac. Redundant with git, but a fast way to find, fetch and
   diff files later.
8. **Tag the commit and publish a GitHub Release** (see below).
9. **Release in App Store Connect** to TestFlight, or to TestFlight and then the App Store.
10. Back to step 1.

Skipping step 1 does not stop the release. Xcode's "Manage Version and Build Number" option is on
by default and silently renumbers the *uploaded* app, not the source tree, so the upload succeeds
with a build number that exists nowhere in git. Recovering means abandoning that build number and
bumping again to realign.

Note when things are decided. The numbers are fixed at step 1, at the start of the cycle. The
destination — TestFlight only, on to the App Store, or "this build is not good enough, make another
one" — is decided at step 9, at the end. The loop therefore may run several times per marketing
version, and a build number is committed to long before anyone knows what will become of it. The
tag written at step 8 already encodes that destination, which is one of the things under review in
[issue #808](https://github.com/vdhamer/Photo-Club-Hub/issues/808).

## Tags and GitHub Releases

Every archive submitted to Apple should carry a tag: the binary ends up on several machines, and
its commit point needs to be recoverable.

- `v<semver>`, e.g. `v2.10.0` — a version that reached the App Store.
- `b<number>`, e.g. `b4663` — a build that went to TestFlight only. Marked as a pre-release on
  GitHub.

Both are published as GitHub Releases. The convention has been applied loosely in the past, so gaps
in the `b<number>` sequence do not all mean the same thing: some are build numbers burned by a
forgotten step 1, some are archives that failed early and were never worth tagging, and some are
builds superseded before any tester saw them.

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
