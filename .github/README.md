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
        <li><a href="#the-name">The name</a></li>
        <li><a href="#the-portfolio-concept">The portfolio concept</a></li>
        <li><a href="#built-with">Built with</a></li>
      </ul>
    </li>
    <li>
      <a href="#installation">Installation</a>
      <ul>
        <li><a href="#cloning-the-repository">Cloning the repository</a></li>
        <li><a href="#code-signing">Code signing</a></li>
        <li><a href="#upgrading-the-app">Upgrading the app</a></li>
      </ul>
    </li>
    <li><a href="#data-privacy">Data privacy</a></li>
    <li><a href="#usage-and-features">Usage and features</a></li>
        <ul>
        <li><a href="#opening-animation">Opening animation</a></li>
        <li><a href="#The-user-interface-screens">The user interface screens</a></li>
        <li><a href="#multi-club-support">Multi-club support</a></li>
      </ul>
    <li><a href="#roadmap">Roadmap</a></li>
    <li><a href="#contributing">Contributing</a>
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

### Waalre

Photo Club Waalre is a photography club named after Waalre, a town in the south of The 
Netherlands. Its members meet since 1988 to critique each other’s photos.
There are also yearly photography excursions and photo expositions.

In future versions, the name Waalre is likely to disappear from the app
after the app starts to be used by multiple photo clubs.

### The Portfolio Concept

The app is designed to **showcase curated work of members of photo clubs**.

That work is organized into `portfolios` that hold the images.
A typical portfolio spans a period of years or even decades. 
The app shows the work in most-recent-first order.

By definition, each portfolio covers that part of a photographer's work that was shared
*within* a photo club.

Thus images by a photographer that are *not* associated with a photo club are not visible (not known)
in the app. But the app does provide a link to a photographer's "external" personal website where possible.

In the event that a photographer joined *multiple* supported photo clubs (simultaneously or over 
the years), the app will show *multiple* portfolios for that photographer.

So this app is club-and-photographer oriented rather than just photographer oriented.

### Built with

* [Swift](https://www.swift.org) - programming language
* [SwiftUI](https://developer.apple.com/xcode/swiftui/) - user interface framework
* [Core Data](https://developer.apple.com/documentation/coredata) - persistent storage framework
* [JuiceBox Pro](https://www.juicebox.net) - JavaScript image galleries

<p align="right">(<a href="#top">back to top</a>)</p>

## Installation

If you just want to install the binary version of the app, it is simplest to get it from Apple's app store ([link](https://apps.apple.com/nl/app/photo-club-waalre/id1178324330?l=en)).

### Cloning the repository

To install the code locally, it is easiest to use GitHub’s `Open with Xcode` feature.
Those used to running Git from the command line should be able to manage on their own.
Xcode handles the installation on a device or Xcode iPhone/iPad simulator.

### Code signing

During the build you may be prompted to provide a developer license (personal or commercial)
in order to install the app on a physical device. This is standard by Apple for iOS apps.

Starting on iOS version 16 you may need to configure a physical device to allow it to run apps
that haven't passed through the Apple App Store. This requires enabling Developer Mode using
Settings > Privacy & Security > Developer Mode. Again, this is a policy by Apple rather
than something specific about this app.

### Updating the app

If you upgrade to a newer build of the app, data stored in the app's internal data storage
stays available.

If necessary the device will do a so-called schema migration if the data
structure has changaed. If you remove and reinstall the app, this data gets reset.
This is standard behavior of Apple's Core Data framework, although the app does its bit
so that Core Data can track, for example, renamed properties in a persisted object.

## Data privacy

The following has **no impact** (zero, null, nil) on the app's functionality or user interface.
So feel free to skip reading this.

The repo contains a minimal amount of encrypted data.
But encryption code can draw a lot of attention, so we are explaining it here
mainly so you don't waste time trying to figure our what's going on or whether
you consider that secure enough. It simply isn't a big deal :nerd_face: :

So... one data file in the repository is encrypted. 
As you will expect, the key needed to decrypt the file is *not* provided.
The file, in its decrypted form, gives access to a password-protected HTML page on a server
containing telephone numbers and e-mail addresses of one specific photo club's members. 
Apart from the fact that the data is of little interest, this has no impact because: 
- the data, when is found to be encrypted, is automatically substitutded by a second non-encrypted page with the supposedly sensitive data removed. Meaning it contains dummy phone numbers and e-mail addresses.
- the data (dummy or real) is currently not used yet by the app

So, all this hasstle is just so that a future App Store version *could* allow club members to
unlock extra functionality using a password,
but without leaking the "sensitive" data via GitHub.

And how would the password be protected? The app can check a hash of the provided password.
But the source code then gives me access to the "sensitive" version of the web page, right?
Wrong. Somehow bypassing the password (e.g. a modification of the code), does allow a user
to *see* the "dummy or real" data, right? Correct. 
But without the not-provided encryption key a user still cannot access the sensitive version
of the page. You would only be able to access the non-sensitive version.
Back to more relevant stuff.

<p align="right">(<a href="#top">back to top</a>)</p>

## Usage and features

### Opening animation

When the app launches, it shows a large version of the app’s icon. 
If you tap somewhere inside the image, an animation turns the icon into
a digitial image illustrating how most digital cameras detect color.

> This involves a [Bayer color filter array](https://en.wikipedia.org/wiki/Bayer_filter)
> that filters the light reaching each CMOS photocell or pixel.
> In a 24 MPixel camera, the image sensor typically consist of 4000 rows of 6000 photocells,
> each with either a red, green of blue color filter. Thus only a single color is measured per
> pixel: the missing information is estimated using surrounding pixels of that color.

Tapping **inside** the image allows you to zoom in or out to your heart's content.
Tapping **outside** the image area gets you to the main Portfolio screen of the app.
To see the animation again, just shut down and restart the app.

Is the animation useful? Well, it was a bit tricky to make (it runs on the device's GPU cores),
but at least it explains where the app's logo came from.

### The user interface screens

- `Portfolios` shows the available portfolios
   (gallery of images of a photographer in the context of one club).
   Clicking on a name shows a screen with the contents of the selected portfolio.
   Swiping left deletes an entry, but is seldom needed.
   The `Search` bar filters the portfolios to only show photographers with that name.

- `Settings` allows you to configure which kinds of members you want to see in the list of
   Portfolios. You can for example choose to show former members.

- `Readme` contains in-app background information that is comparable to this text.

- `Photo clubs` lists the photo clubs that are currently loaded.
    A purple pin on the map shows the location where a selected club meets.
    A blue pin shows the location of non-selected photo clubs.
    A lock icon sets whether the map is frozen or can be zoomed and panned.

- `Photographers` lists the photographers currently loaded into the app. I
	It shows information that is club-independent.
    The entries may display birthdays, and clickable links to personal
    (club-independent) photography sites.
    The `Search` bar filters the list of photographers.
    
### Multi-club support

Version 1 of the app only supported Photo Club Waalre (aka *Fotogroep Waalre*).
Version 2 added support for multiple photo clubs.
For a preview of how that works, drag down (“pull to refresh”) the Photo Club page.
This loads just enough test data to demo the feature.

<p align="right">(<a href="#top">back to top</a>)</p>

## Roadmap
- [x] Put the app's source code on GitHub.
	- [x] Handle private data about members in a secure way
    - [ ] Publish article in Dutch photo club [organization](https://fotobond.nl)
- [ ] MemberListView: show thumbnails of most recent photos
- [ ] MemberListView: automatically remove members who are removed on the server
- [ ] MemberGaleryView: replace use of WebKit by SwiftUI equivalent
- [ ] Support onboarding of clubs without any code changes. A big challenge.
- [ ] Notifications when new images are added to the portfolios.
- [ ] Support expositions by photo clubs.

See the [open issues](https://github.com/vdhamer/PhotoClubWaalre/issues) for a full list of
proposed features (and known issues).

<p align="right">(<a href="#top">back to top</a>)</p>

## Contributing
All contributions are welcome.

### Areas for contribution

Possible contributions include adding features, code improvements, ideas on architecture and interface specifications, and possibly even a dedicated backend server.

Contributions that don't require coding include beta testing, well thought-through feature requests, translations, and SVG icons.

### One likely big change

A major design challenge for a next stage will be to provide a clean,
standardized interface to retrieve data per photo club.
The interface is needed to load the data, but also to keeps the data up to date.
This is needed because membership data and portfolios change regularly.
The current interface is essentially a plug-in design with an adaptor per photo club.
This needs to be replaced by a standard data interface to avoid
having to modify the source code whenever a new club comes aboard.

The app currently uses a software module per club. That module loads membership and portfolio
data from the club’s server and merges it into the in-app database.
For Photo Club Waalre, the membership data is read from a HTML table on a password protected
part of the club’s website. The portfolios use a somewhat more robust solution: 
they are read from XML files generated by a Lightroom Web plug-in called [JuiceBox-Pro](https://www.juicebox.net/). 
Thus portfolios are created and managed as Lightroom collections. 
These collections are then uploaded to the webserver with a single Upload click
(thus triggering JuiceBox-Pro) where they can be downloaded by the app.

### How to contribute

If you have a suggestion that would make this better, you can fork the repo and create a pull
request.  The command line `git` commands to do this (but the Xcode IDE has equivalent commands under `Source Control`):

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

You can alternatively submit an `issue` with a tag like ”enhancement" or “bug” without having to do the code changes yourself.

<p align="right">(<a href="#top">back to top</a>)</p>

## About the model

The app uses a [Swift-style MVVM](https://www.hackingwithswift.com/books/ios-swiftui/introducing-mvvm-into-your-swiftui-project)
design, meaning the model data is stored in structs (and in database tables) rather than in
classes. As an intro for developers, here is a quick tour of the model. 

[![Product schema][product-schema]](https://github.com/vdhamer/PhotoClubWaalre/blob/main/Assets.xcassets/images/Schema.imageset/Schema.png)

Every `PhotoClub` has zero or more `Members` of various types (current, former, etc.).
Some of these `Members` have a formal role (e.g., Chairman) within the `PhotoClub`.

Some of information about a `Photographer` (like name, birthday, a personal website) is
unrelated to the `Photographer's` `Member`ship of a `PhotoClub`.

`Portfolio` represent the work of a single `Photographer` in the context of a single `PhotoClub`.
A `Portfolio` contains `Images`, but an `Image` could be in multiple `Portfolios` - depending
on where the `Image` was shared.

`Member` and `Portfolio` can be considered synonyms from a modeling perspective:
we create exactly one `Portfolio` for each `PhotoClub` that a `Photographer` joined.
And every `Member` of a `PhotoClub` has exactly one `Portfolio` in the app.
Therefore `Member` and `Portfolio` are formally synonyms, 
and thus modelled here as a single concept or table called `MemberPortfolio`.

<p align="right">(<a href="#top">back to top</a>)</p>

## License

Distributed under the MIT License. See `LICENSE.txt` for more information.

<p align="right">(<a href="#top">back to top</a>)</p>

## Contact
Peter van den Hamer - github@vdhamer.com

Project Link: [https://github.com/vdhamer/PhotoClubWaalre](https://github.com/vdhamer/PhotoClubWaalre)

<p align="right">(<a href="#top">back to top</a>)</p>

## Acknowledgments

* The opening image animation uses a photo by Greetje van Son
* A file with club member data is encrypted using [git-crypt](https://github.com/AGWA/git-crypt)

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
[license-url]: https://github.com/vdhamer/PhotoClubWaalre/blob/main/.github/LICENSE.md
[portfolios-screenshot]: images/portfolios.png
[product-schema]: ../Assets.xcassets/images/Schema.imageset/Schema.png
