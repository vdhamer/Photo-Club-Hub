<div id="top"></div>

[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![MIT License][license-shield]][license-url]

[![Portfolios Screen Shot][portfolios-screenshot]](https://github.com/vdhamer/PhotoClubWaalre)

<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
      <ul>
        <li><a href="#the-name">The Name</a></li>
        <li><a href="#portfolios">Portfolios</a></li>
        <li><a href="#built-with">Built With</a></li>
      </ul>
    </li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#installation">Installation</a></li>
      </ul>
    </li>
    <li><a href="#usage">Usage and features</a></li>
        <ul>
        <li><a href="#opening-animation">Opening animation</a></li>
        <li><a href="#the-screens">The screens</a></li>
        <li><a href="#multi-club-support">Multi-club support</a></li>
      </ul>
    <li><a href="#roadmap">Roadmap</a></li>
    <li>
        <a href="#contributing">Contributing</a>
        <ul>
            <li><a href="#areas-for-contribution">Areas for contribution</a></li>
            <li><a href="#one-likely-big-change">One likely big change</a></li>
            <li><a href="#how-to-contribute">How to contribute</a></li>
        </ul>
    </li>
    <li><a href="#about-the-model">About the model</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
    <li><a href="#acknowledgments">Acknowledgments</a></li>
  </ol>
</details>

## About The Project

### The name

Photo Club Waalre is a photography club named after Waalre, a town in the south of The Netherlands. Since 1988 its club members meet to critique each other’s photos, organize excursions, and hold yearly photo expositions.

### Portfolios

The goal of this app is to **showcase curated work of members of photo clubs**.

The work is organized into `portfolios`. Each portfolio covers that part of a photographer's work that was shared within a photo club. If a photographer is (or was) a member of more than one of the supported photo clubs, the app will contain multiple portfolios for that photographer.

Each portfolio is shown in chronological order, with the latest work shown first, and typically spans multiple years.

### Built With
* [Swift](https://www.swift.org)
* [Core Data](https://developer.apple.com/documentation/coredata)
* [SwiftUI](https://developer.apple.com/xcode/swiftui/)

<p align="right">(<a href="#top">back to top</a>)</p>

## Getting Started
To get a local copy up and running, use GitHub’s `Open with Xcode` feature, compile and run on a simulator or physical device. Those who prefer running git from the command line should be able to manage on their own.

### Installation

<p align="right">(<a href="#top">back to top</a>)</p>

## Usage and features

### Opening animation

When the app opens, it shows a large image corresponding to the app’s icon. If you tap somewhere inside the image, it zooms out to show the full image representing how digital cameras see color.

This involves a Bayer color filter array that filters the light per pixel. The filter array is shown here superimposed on a colorful photo.

Tapping inside the image allows you to zoom in or out to your heart's content. Tapping outside the image area ends the animation. You can trigger the animation again by restarting the app. A single tap outside the image allows you to skip the animation entirely.

### The screens

- `Portfolios` shows the available portfolios (gallery of images of a photographer in the context of one club).
    Clicking on one item shows a `detail` screen with the contents of the selected portfolio.
    Swiping left can, in exceptional cases, be used to delete an entry.
    The `Search` bar filters the list of portfolios.
- `Settings` allows you to configure what types of members you want to see in the list of Portfolios.
- `Readme` contains a scrollable explanation, similar to what you are reading.
- `Photo clubs` lists the photo clubs that are currently loaded.
    A purple pin on the map show the location of the club's club house (where they meet).
    A blue pin shows the location of other loaded photo clubs.
    A lock icon selects whether a map can be zoomed and panned, or is pinned in place.
- `Photographers` lists the photographers currently loaded into the app. It gives information which is club-independent.
    The entries may store birthdays, and clickable links to personal (club-independent) photography sites.
    The `Search` bar filters the list of portfolios.
    
### Multi-club support

Version one the app only supported Photo Club Waalre (aka *Fotogroep Waalre*), but Version 2 supports multiple photo clubs. For a preview, drag down (“pull to refresh”) the Photo Club page. This loads just enough test data to show what multi-club support looks like.

<p align="right">(<a href="#top">back to top</a>)</p>

## Roadmap
- [x] Distribute the source code on GitHub
    - [ ] Publish article to get attention in Dutch photo club [organization](https://fotobond.nl)
- [ ] MemberListView: show thumbnails of most recent photos
- [ ] MemberListView: remove members who are removed on server
- [ ] MemberGaleryView: use of WebKit by SwiftUI equivalent
- [ ] Support onboarding of clubs without code changes
- [ ] Notifications of portfolio changes (?)

See the [open issues](https://github.com/vdhamer/PhotoClubWaalre/issues) for a full list of proposed features (and known issues).

<p align="right">(<a href="#top">back to top</a>)</p>

## Contributing
All contributions are greatly appreciated.

### Areas for contribution

Welcome contributions include adding features, code improvements, ideas on architecture and interface definition, and possibly even a backend.

Contributions that don't require coding are also welcome: beta testing via TestFlight, feature requests, translations, SVG icon design, and maybe UI/UX design.

### One likely big change

A central design challenge for a next stage will be to provide a clean, standardized interface to retrieve data per photo club. The interface is needed to load the data, but also keeps the data within the app up to date. After all, membership data and portfolios change regularly. The current interface is essentially a plug-in design with an adaptor per photo club. This needs to be replaced by a standard data interface to avoid having to extend the source code whenever a new club comes aboard.

The app currently uses a software module per club. That module loads membership and portfolio data from the club’s server and merges it into the in-app database. For Photo Club Waalre, the membership data is read from a HTML table on a password protected part of the club’s website. The portfolios use a somewhat more robust solution: they are read from XML files generated by a Lightroom Web plug-in called JuiceBox-Pro Thus portfolios are created and managed as Lightroom collections. These collections are then uploaded to the webserver with a single Upload click (thus triggering JuiceBox-Pro) where they can be downloaded by the app.

### How to contribute

If you have a suggestion that would make this better, you can fork the repo and create a pull request.  The command line `git` commands to do this (but the Xcode IDE has equivalent commands under `Source Control`):

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

You can alternatively submit an `issue` with a tag like ”enhancement" or “bug” without having to do the code changes yourself. 

<p align="right">(<a href="#top">back to top</a>)</p>

## About the model

The app uses a [Swift-style MVVM](https://www.hackingwithswift.com/books/ios-swiftui/introducing-mvvm-into-your-swiftui-project) design, meaning the model data is stored in structs (and in database tables) rather than in classes. As an intro for developers, here is a quick tour of the model. 

[![Product schema][product-schema]](https://github.com/vdhamer/PhotoClubWaalre/tree/readme#about-the-model)

Every `PhotoClub` has zero or more `Members` of various types (current, former, etc.). Some of these `Members` have a formal role like chairman within the `PhotoClub`. We will come back to why `Member` is not visible in the model in a moment.

Some of information about a `Photographer` (like name, birthday, a personal website) is unrelated to the `Photographer's` `Member`ship of a `PhotoClub`.

`Portfolios` represent the body of work of a `Photographer` in the context of a single `PhotoClub`. A `Portfolio` contains `Images`, but an `Image` could be in multiple `Portfolios` - depending on where the `Image` was shared.

`Member` and `Portfolio` can be considered synonyms from a modeling perspective: we create exactly one `Portfolio` for each `PhotoClub` that a `Photographer` joined.  And every `Member` of a `PhotoClub` has exactly one `Portfolio` in the app. Therefore `Member` and `Portfolio` are from a formal perspective synonyms, and thus modelled as a single concept or table.

<p align="right">(<a href="#top">back to top</a>)</p>

## License

Distributed under the MIT License. See `LICENSE.txt` for more information.

<p align="right">(<a href="#top">back to top</a>)</p>

## Contact
Peter van den Hamer - github@vdhamer.com

Project Link: [https://github.com/vdhamer/PhotoClubWaalre](https://github.com/vdhamer/PhotoClubWaalre)

<p align="right">(<a href="#top">back to top</a>)</p>

## Acknowledgments

* The opening image animation uses an image by Greetje van Son.

<p align="right">(<a href="#top">back to top</a>)</p>

<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[contributors-shield]: https://img.shields.io/github/contributors/vdhamer/PhotoClubWaalre.svg?style=for-the-badge
[contributors-url]: https://github.com/vdhamer/PhotoClubWaalre/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/vdhamer/PhotoClubWaalre.svg?style=for-the-badge
[forks-url]: https://github.com/vdhamer/PhotoClubWaalre/network/members
[stars-shield]: https://img.shields.io/github/stars/vdhamer/PhotoClubWaalre.svg?style=for-the-badge
[stars-url]: https://github.com/vdhamer/PhotoClubWaalre/stargazers
[issues-shield]: https://img.shields.io/github/issues/vdhamer/PhotoClubWaalre.svg?style=for-the-badge
[issues-url]: https://github.com/vdhamer/PhotoClubWaalre/issues
[license-shield]: https://img.shields.io/github/license/vdhamer/PhotoClubWaalre.svg?style=for-the-badge
[license-url]: https://github.com/vdhamer/PhotoClubWaalre/blob/main/.github/LICENSE.txt
[portfolios-screenshot]: images/portfolios.png
[product-schema]: ../Assets.xcassets/images/Schema.imageset/Schema.jpg
