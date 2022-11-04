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
      <a href="#about-the-project">About the Project</a>
      <ul>
        <li><a href="#waalre">Waalre</a></li>
        <li><a href="#the-portfolio-concept">The Portfolio Concept</a></li>
      </ul>
    </li>
    <li><a href="#usage-and-features">Usage and Features</a></li>
        <ul>
        <li><a href="#opening-animation">Opening Animation</a></li>
        <li><a href="#the-user-interface-screens">The User Interface Screens</a></li>
        <li><a href="#multi-club-support">Multi-club Support</a></li>
        <li><a href="#roadmap">Roadmap</a></li>
        </ul>
    <li>
      <a href="#installation">Installation</a>
      <ul>
        <li><a href="#built-with">Built With</a></li>
	<li><a href="#cloning-the-repository">Cloning the Repository</a></li>
        <li><a href="#code-signing">Code Signing</a></li>
        <li><a href="#upgrading-the-app">Upgrading the App</a></li>
	<li><a href="#data-privacy">Data Privacy</a></li>
      </ul>
    </li>
    <li><a href="#contributing">Contributing</a>
        <ul>
	    <li><a href="#how-to-contribute">How to Contribute</a></li>
	    <li><a href="#areas-for-contribution">Areas for Contribution</a></li> 
        </ul>
    </li>
    <li><a href="#the-app-architecture">The App's Architecture</a>
        <ul>
           <li><a href="#the-data-model">The Data Model</a></li>
	   <li><a href="#how-the-data-is-loaded">How the Data is Loaded</a></li>
	      <ul>
		 <li><a href="#the-current-approach">The Current Approach</a></li>
		 <li><a href="#a-better-approach">A Better Approach</a></li>
	      </ul>
	</ul>
    <li><a href="#administrative">Administrative</a></li>
	<ul>  
           <li><a href="#license">License</a></li>
           <li><a href="#contact">Contact</a></li>
           <li><a href="#acknowledgments">Acknowledgments</a></li>
	</ul>
  </ol>
</details>

## About the Project

### Waalre

Photo Club Waalre is a photography club named after Waalre, a town in the south of The 
Netherlands. Its members meet since 1988, mainly to critique each other’s photos.

The name of the photo club will probably disappear from the app's name at some point.
This would help stress that the app supports *multiple* photo clubs rather than just one.

### The Portfolio Concept

The app is designed to showcase curated images made by members of photo clubs.

The images within the app are divided into `portfolios`. Within this app, 
a portfolio covers the part of a photographer's work that was shared *within* a single photo club.

Images by a photographer that are *not* associated with a photo club are not supported by the app
because the app is club-oriented. But the app can provide a link to a photographer's personal, non-club-oriented website.

If a photographer joined *multiple* photo clubs, the app will show *multiple* portfolios (with different
content) for that photographer. An example: the photographer is simultaneously a member of both club A and club B.
Another example: the photographer was formerly a member of club A, but at some point left club A to join club B.

<p align="right">(<a href="#top">back to top</a>)</p>
 
## Usage and Features

### Opening Animation

When the app launches, it shows a large version of the app’s icon. 
If you tap somewhere inside the image, an animation turns the icon into
an image illustrating how most digital cameras detect color.

> This involves a [Bayer color filter array](https://en.wikipedia.org/wiki/Bayer_filter)
> that filters the light reaching each CMOS photocell or pixel.
> In a 24 MPixel camera, the image sensor typically consist of 4000 rows of 6000 photocells,
> each with either a red, green of blue color filter. Thus only a single color is measured per
> pixel: the missing information is estimated using surrounding pixels of that color.

Tapping *inside* the image allows you to zoom in or out to your heart's content.
Tapping *outside* the image area gets you to the main Portfolio screen of the app.
To see the animation again, just shut down and restart the app.

Is the animation useful? Well, it was interesting to create and runs on the device's GPU cores,
but at least it explains where the app's logo comes from.

### The User Interface Screens

- `Portfolios` shows the available portfolios
   (gallery of images of a photographer in the context of one club).
   Clicking on a name shows a screen with the contents of the selected portfolio.
   Swiping left deletes an entry, but is seldom needed.
   The `Search` bar filters the list of portfolios.

- `Settings` allows you to configure which portfolios you want to be visible in the
   Portfolios screen. You can, for example, choose whether or not to include former members.

- `Readme` contains in-app background information that is comparable to this text.

- `Photo Clubs` lists the photo clubs that are currently loaded.
   A purple pin on the map shows the location where a selected club meets.
   A blue pin shows the location of other nearby photo clubs.
   A lock icon sets whether the map is frozen or can be zoomed-and-panned.

- `Who's Who` lists the photographers that you can be found in the app.
   It shows information that is club-independent.
   The entries may display birthdays, and clickable links to personal
   (club-independent) photography sites.
   The `Search` bar filters the list of photographers.
   
- `<Photographer name>`
   The title of a portfolio is the photographer's name.
   Note that there may be multiple portfolios for that photographer: one per photo clubs.
   Images are shown in chronological order, with the most recent first.
   For Fotogroep Waalre, you will see the year the image was created in the caption.
   You can *swipe* to manually move forwards/backwards between the images.
   There is also an *autoplay* mode that advanced the image automatically after a few seconds.
    
### Multi-club Support

Version 1 of the app only supported Photo Club Waalre (aka *Fotogroep Waalre*).
Version 2 added support for multiple photo clubs.
For a preview of how that works, drag down (“pull to refresh”) the Photo Clubs page.
This loads just enough test data to demo the feature.

### Roadmap
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

## Installation

If you just want to install the binary version of the app, it is easiest to get it from Apple's app store ([link](https://apps.apple.com/nl/app/photo-club-waalre/id1178324330?l=en)).

### Built With

* [Swift](https://www.swift.org) - programming language
* [SwiftUI](https://developer.apple.com/xcode/swiftui/) - an Apple user interface framework
* [Core Data](https://developer.apple.com/documentation/coredata) - Apple's persistent storage framework
* [JuiceBox Pro](https://www.juicebox.net) - JavaScript image galleries
* [GitCrypt](https://github.com/AGWA/git-crypt) - encryption of selected files in Git repositories

### Cloning the Repository

To install the source code locally, it is easiest to use GitHub’s `Open with Xcode` feature.
Developers used to running Git from the command line should manage on their own.
Xcode covers the installation of the binary on a physical device or on an Xcode iPhone/iPad simulator.

### Code Signing

During the build you may be prompted to provide a developer license (personal or commercial)
in order to install the app on a physical device. This is standard by Apple for iOS apps.

Starting with iOS version 16 you will need to configure physical devices to allow them to run apps
that have not been distributed via the Apple App Store. This configuration requires enabling
Developer Mode on the device using `Settings` > `Privacy & Security` > `Developer Mode`.
Again, this is a standard iOS policy rather than something specific to this app.

### Updating the App

If you upgrade to a newer build of the app, data stored in the app's internal data storage remains available.

If needed, Core Data will automatically perform a so-called schema migration if the data
structure has changed. If you remove and reinstall the app, any existing CoreData data gets deleted.
This is standard behavior of Apple's Core Data framework, although the app does its bit
so that Core Data can track, for example, renamed struct types or renamed properties.

### Data Privacy

The following has *no impact* (zero, null, nil) on the app's functionality or user interface.
So feel free to skip this section.

The repo contains a minimal amount of encrypted data.
But encryption code can draw a lot of attention, so we are explaining it here
mainly so you don't waste time trying to figure our what's going on or whether
you consider that secure enough. It simply isn't a big deal :nerd_face:.

So... one data file in the repository is encrypted. 
As you will expect, the key needed to decrypt the file is *not* provided.
The file, in its decrypted form, gives access to a password-protected HTML page on a server
containing telephone numbers and e-mail addresses of the members of Photo Club Waalre. 
Apart from the fact that the data is of little interest, this has no impact because: 
- if the file is found to be encrypted, it is automatically substituted by a second non-encrypted file which doesn't give access to any sensitive data about members.with the sensitive data substituded by dummy values.
- (dummy or real) phone numbers and e-mail addresses are not used yet by the app.

So, all this hasstle is just so that a future App Store version *could* allow club members to
unlock extra functionality using a password, but without leaking the "sensitive" data via GitHub.

And how would the password be protected? The app can check a hash of the provided password.
But modified source code then gives access to the "sensitive" version of the web page, right?
Wrong. Bypassing the password (e.g. a code modification), does allow a user
to *see* the "dummy or real" data, right? Correct. 
But without the not-provided encryption key a user would only be able to access the non-sensitive version.
So let's get back to more relevant stuff.

<p align="right">(<a href="#top">back to top</a>)</p>

## Contributing
All contributions are welcome.
Before investing a lot of coding effort, it might be good to first describe the idea or functional change in the description of `an Issue`.
That allows for some upfront discussion and iteration of the idea. 
Contributions that don't require coding include beta testing, well thought-through feature requests, translations, and SVG icons.

### How to Contribute

If you have a suggestion that would make this better, you can fork the repo and create a pull
request.  The command line `git` commands to do this (but the Xcode IDE has equivalent commands under `Source Control`):

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

You can alternatively submit an `issue` with a tag like ”enhancement" or “bug” without having to do the code changes yourself.

### Areas for Contribution

Possible contributions include adding features, code improvements, ideas on architecture and interface specifications, 
and possibly even a dedicated backend server.

<p align="right">(<a href="#top">back to top</a>)</p>

## The App Architecture

The app uses a [Swift-style MVVM](https://www.hackingwithswift.com/books/ios-swiftui/introducing-mvvm-into-your-swiftui-project)
architecture. The model's data is fetched and updated via the internet, and is cached in a local database (Apple's CoreData framework).

The use of a Swift MVVM architecture implies that the model data is stored in structs (and in database tables) rather than in classes.

### The Data Model

Here are the 3 central concepts (aka tables or struct types). The number of tables will increase in the future.
Note that, in relational database jargon, the tables are deliberately kept fully "normalized", implying minimal data redundancy.

[![Product schema][product-schema]](https://github.com/vdhamer/PhotoClubWaalre/blob/main/Assets.xcassets/images/Schema.imageset/Schema.png)

Every `PhotoClub` has zero or more `Members` of various roles (Chairman, Admin, ...) and states (current, former, apiring, ...).
A `Member` may have multiple roles (e.g., acting as both Secretary and Admin for the same `PhotoClub`).

Some basic information about a `Photographer` (name, date of birth, personal website, ...) is
related to the `Photographer` as an individual, rather that being associated with any particular `PhotoClub`.
That club-independent information is stored in the individual's `Photographer` struct/record.

`Portfolio` represents the work of one `Photographer` in the context of one `PhotoClub`.
A `Portfolio` contains `Images` (not stored in a CoreData table yet). An `Image` can show up in multiple `Portfolios` -
meaning the photo was discussed in multiple `PhotoClubs`.

`Member` and `Portfolio` can be considered synonyms from a modeling perspective:
we create exactly one `Portfolio` for each `PhotoClub` that a `Photographer` became a `Member` of.
And every `Member` of a `PhotoClub` has exactly one `Portfolio` - even if it still contains zero images.
This one-to-one relationship between `Member` and `Portfolio` allows them to be 
modelled using once single concept (or table) that we named `MemberPortfolio`.

### How the Data is Loaded

#### The Current Approach

The app currently uses a software module per club. That module loads membership and portfolio
data from the club’s server and merges it into the in-app database.
For Photo Club Waalre, the membership data is read from a HTML table on a password protected
part of the club’s website. The portfolios use a somewhat more robust solution: 
they are read from XML files generated by a Lightroom Web plug-in called [JuiceBox-Pro](https://www.juicebox.net/). 
Thus portfolios are created and managed as Lightroom collections. 
These collections are then uploaded to the webserver with a single Upload click
(thus triggering JuiceBox-Pro) where they can be downloaded by the app.

#### A Better Approach

A major design challenge for a next stage should be to provide a clean,
standardized interface to retrieve data per photo club.
That interface is needed to load the data, but also to keeps the data up to date.
This is needed because membership data and portfolios change regularly.
The current interface is essentially a plug-in design with an adaptor per photo club.
This needs to be replaced by a standard data interface to avoid
having to modify the source code whenever a new club comes aboard.

<p align="right">(<a href="#top">back to top</a>)</p>

## Administrative

### License

Distributed under the MIT License. See `LICENSE.txt` for more information.

### Contact
Peter van den Hamer - github@vdhamer.com

Project Link: [https://github.com/vdhamer/PhotoClubWaalre](https://github.com/vdhamer/PhotoClubWaalre)

### Acknowledgments

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
