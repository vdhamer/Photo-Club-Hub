# Contributing to Photo Club Hub

Photo Club Hub is a volunteer project. Help is welcome, and not only with code. Everything moves faster with
more people involved, including how quickly new ideas come up and get refined.

## Where to start

The project spans four repositories. Each has a list of GitHub Issues labeled **Good first issue** (small,
already decided, no deep knowledge of the code needed) and **Help wanted** (bigger chunks that suit someone
with a specific skill).

| Repository | What it is | Starter issues |
|---|---|---|
| [Photo-Club-Hub](https://github.com/vdhamer/Photo-Club-Hub) | the iOS app, and (for now) the live club data | [good first issue](https://github.com/vdhamer/Photo-Club-Hub/issues?q=is%3Aopen+label%3A%22Good+first+issue%22), [help wanted](https://github.com/vdhamer/Photo-Club-Hub/issues?q=is%3Aopen+label%3A%22Help+wanted%22) |
| [Photo-Club-Hub-HTML](https://github.com/vdhamer/Photo-Club-Hub-HTML) | a macOS app that generates the equivalent website | [good first issue](https://github.com/vdhamer/Photo-Club-Hub-HTML/issues?q=is%3Aopen+label%3A%22Good+first+issue%22), [help wanted](https://github.com/vdhamer/Photo-Club-Hub-HTML/issues?q=is%3Aopen+label%3A%22Help+wanted%22) |
| [Photo-Club-Hub-Data](https://github.com/vdhamer/Photo-Club-Hub-Data) | the Swift package both apps use: data model and loaders. The live data is moving here. | [good first issue](https://github.com/vdhamer/Photo-Club-Hub-Data/issues?q=is%3Aopen+label%3A%22Good+first+issue%22), [help wanted](https://github.com/vdhamer/Photo-Club-Hub-Data/issues?q=is%3Aopen+label%3A%22Help+wanted%22) |
| [Photo-Club-Hub-Project](https://github.com/vdhamer/Photo-Club-Hub-Project) | project-wide work: roadmap, translations, non-code tasks | [help wanted](https://github.com/vdhamer/Photo-Club-Hub-Project/issues?q=is%3Aopen+label%3A%22Help+wanted%22) |

Before investing effort in a change, say so in a comment on the issue, or open a new issue for an idea that
has none yet. That allows some upfront discussion and refinement, and can avoid two people doing the same work.
You can also open an issue (a bug, an idea, a feature request) without offering to do the work yourself.

## Help that needs no code

- **Your club's data.** A club appears in the app once someone supplies its name and location (Level 1),
  then its members (Level 2). See [Level1_creation_EN.md](../Photo%20Club%20Hub/Documentation/Level1_creation_EN.md)
  and [Level2_creation_EN.md](../Photo%20Club%20Hub/Documentation/Level2_creation_EN.md).
  The data files live in this repository's [JSON](../JSON) folder.
- **Translations.** The app and website are in English and Dutch. A third language is welcome:
  [Project#24](https://github.com/vdhamer/Photo-Club-Hub-Project/issues/24) lists what that involves.
- **Testing, reviews and ideas.** Report bugs, write an App Store review, write step-by-step instructions
  for club members, or suggest improvements to the design or even the app's icon.

## Building the iOS app

1. Clone the repository, for example with GitHub's *Open with Xcode*, and open `Photo Club Hub.xcodeproj`
   in the latest stable release of Xcode. There is no workspace.
2. Xcode fetches the [Photo-Club-Hub-Data](https://github.com/vdhamer/Photo-Club-Hub-Data) package by itself.
   Do not use *Add Package Dependencies ▸ Add Local…* for it; changes to the package go through a pull
   request in its own repository.
3. Under *Signing & Capabilities*, select your own team (a free personal team is enough) and, if needed, change
   the bundle identifier.
4. Run on a simulator or on a real device. To build confidence, run the provided regression tests with ⌘U.
   The Data package has its own tests.

If [SwiftLint](https://github.com/realm/SwiftLint) is installed, it runs during every build with its default
rules and no configuration file. Please fix its warnings in the code rather than switching rules off.

## Pull requests

- Keep a pull request small and about one issue, and mention that issue (`Fixes #123`) in the description.
- A branch named after the issue, such as `123-short-title`, makes it easy to find later.
- New text that users see goes into the string catalogs in [Localization](../Localization), in English.
  Add the Dutch translation if you can; if not, say so and it will be added.
- Detail: use US spelling in code, comments and English text.

Questions are welcome: comment on a related issue, or open a new one. Thank you for helping!
