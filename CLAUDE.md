# CLAUDE.md

Guidance for AI coding assistants (e.g. Claude Code) working in this repository.

## Dependency on Photo Club Hub Data

The CoreData model, JSON loaders, and club `MembersProvider`s live in the
[Photo Club Hub Data](https://github.com/vdhamer/Photo-Club-Hub-Data) package, consumed as a
**remote** SwiftPM dependency pinned `upToNextMajorVersion` from 3.0.0 (#809, #808). Package changes
therefore reach this app only after a tag and a resolve, and `Package.resolved` records the exact
version and revision every release was built against.

The app is opened as `Photo Club Hub.xcodeproj`, **without a workspace**. Workspaces were used for a
while and dropped, in this repo and in Photo-Club-Hub-HTML: with both a project and a workspace level,
edits too easily land at the wrong one. Package changes reach the app through a tag and a resolve.

When the remote package cannot be fetched (e.g. GitHub unreachable), the stopgap is a **SwiftPM
mirror**, the same in both apps: a git-ignored file at
`Photo Club Hub.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/configuration/mirrors.json`
that redirects the package URL to a local clone:

```json
{"object":[{"mirror":"<absolute path to the Photo-Club-Hub-Data clone>",
            "original":"https://github.com/vdhamer/Photo-Club-Hub-Data"}],"version":1}
```

Xcode and `xcodebuild` then resolve from the clone's git history and check out the commit pinned in
`Package.resolved`, so the build is the exact pinned version. The clone's working tree is ignored:
uncommitted edits and untagged commits do not reach the app, and a new package version still needs a
tag (locally, until it can be pushed). The file holds an absolute path on one Mac, which is why it is
never committed. Delete it as soon as the remote works again, resolve package versions, and check that
`Package.resolved` is unchanged.

A temporary workspace that adds the local package was used for this before, and is no longer the
stopgap: it builds the package's working tree rather than the pinned tag, rewrites the package repo's
own `Package.resolved`, and brings back the project-versus-workspace confusion described above.

Do **not** use *Add Package Dependencies ▸ Add Local…*: that writes an `XCLocalSwiftPackageReference`
into `project.pbxproj`, reverting #809 and silently putting untagged package code into release builds.

## Version numbers

The app's `MARKETING_VERSION` is a **label for users**. What a bump means is the maintainer's call;
it is not coupled to the package's number and no test asserts a relationship.
`CURRENT_PROJECT_VERSION` is the build number: it counts archives that reached Apple, many of which
stop at TestFlight, and App Store Connect enforces that it rises.

The Data package's version is the opposite — a **contract**, in plain semantic versioning, with MAJOR
reserved for changes that break consumers. This app pins `upToNextMajorVersion` from 3.0.0, so a
breaking package release can never arrive unasked: raising the floor is a deliberate edit here and in
Photo-Club-Hub-HTML.

The two were aligned at 3.0.0 once, when the old "release train" — three repos sharing a version
prefix, with the compatibility boundary at the second position — was dropped in favour of ordinary
semver. **They float apart from then on**; matching numbers prove nothing and are not maintained.
Full description in `Photo Club Hub/Documentation/ReleaseProcess.md`; the reasoning is in #808.

## Planning & process live in GitHub, not local files

GitHub is the technical and process source of truth across the Photo Club Hub repos
(Photo-Club-Hub, Photo-Club-Hub-Data, Photo-Club-Hub-HTML). Implementation plans, design
rationale, and follow-up work belong in **GitHub issues**, not in local `.md` files — the
maintainer and other contributors do not read local planning files.

- When you produce a plan or capture follow-up work, write it into the relevant GitHub issue
  (create one if needed) and make that issue self-sufficient: code sketches, file paths,
  decisions, and verification steps.
- Do not leave parallel local plan files; they go stale and nobody reads them.
- A short pointer in your own notes/memory is fine, but the content must live in GitHub.
