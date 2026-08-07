# CLAUDE.md

Guidance for AI coding assistants (e.g. Claude Code) working in this repository.

## Dependency on Photo Club Hub Data

The CoreData model, JSON loaders, and club `MembersProvider`s live in the
[Photo Club Hub Data](https://github.com/vdhamer/Photo-Club-Hub-Data) package, consumed as a
**remote** SwiftPM dependency pinned `upToNextMinorVersion` from 2.11.4 (#809). Package changes
therefore reach this app only after a tag and a resolve, and `Package.resolved` records the exact
version and revision every release was built against.

To co-develop app and package, add a local checkout of the package to `Photo Club Hub.xcworkspace`
— a personal workspace, deliberately git-ignored — and Xcode shadows the remote dependency with it.
Remove it to return to the resolved tag.

Do **not** use *Add Package Dependencies ▸ Add Local…*: that writes an `XCLocalSwiftPackageReference`
into `project.pbxproj`, reverting #809 and silently putting untagged package code into release builds.

The three repos share a synchronized major.minor release train, so a minor bump means bumping the
requirement here and in Photo-Club-Hub-HTML by hand.

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
