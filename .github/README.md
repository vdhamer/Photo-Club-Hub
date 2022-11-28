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
	    <li><a href="#areas-for-contribution">Areas for Contribution</a></li> 
        </ul>
    </li>
    <li><a href="#the-app-architecture">The App's Architecture</a>
        <ul>
              <li><a href="#role-of-the-database">Role of the Database</a></li>
              <li><a href="#the-data-model">The Data Model</a></li>
	      <ul>
		 <li><a href="#photoclub">PhotoClub</a></li>
		 <li><a href="#photographer">Photographer</a></li>
		 <li><a href="#memberportfolio">MemberPortfolio</a></li>
	      </ul>
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

Photo Club Waalre is a photography club named after Waalre, a town in the south of 
The Netherlands. Its members meet since 1988, mainly to critique each other’s photos.

This app originally served as an alternative way to view the photos published on the club's web
site. The name of the app may, however, change to stress that the app can support *multiple* photo clubs.

### The Portfolio Concept

The app is meant to showcase curated images made by members of photo clubs.

The images within the app are divided into so-called `portfolios`. Within this app, 
a portfolio covers the part of a photographer's work that is associated with a single photo club.

If a photographer joined *multiple* photo clubs, the app will show *multiple* portfolios (with different
content) for that photographer. Examples:
- the photographer is _simultaneously_ a member of both club A and club B.
- the photographer was _formerly_ a member of club A, but at some point left club A and joined club B.

Images by a photographer that are *not* associated with a photo club are not supported
by the app because the app is club-oriented. The app can, however, provide a link to a
photographer's personal (club-unrelated) photography website.
Furthermore, it is up to you how formal a club should be: nothing prevents you from
setting up a one-man club, or supporting a group of photographers with a shared
interest or live in the same regio, but who only communicate online.

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
> pixel: the missing information is algorithmically reconstructed (=guessed) using surrounding pixels.

Tapping *inside* the image allows you to zoom in or out to your heart's content.
Tapping *outside* the image area gets you to the main Portfolio screen of the app.
To see the animation again, just shut down and restart the app.

But is the animation useful? Well, it was interesting to create and it runs on the device's GPU cores,
but at least it explains where the app's logo comes from.

### The User Interface Screens

- `Portfolios` shows the available portfolios
   (gallery of images of a photographer in the context of one club).
   Clicking on a name shows a screen with the contents of the selected portfolio.
   Swiping left deletes an entry, but is seldom needed.
   The `Search` bar filters the list of portfolios.

- `Settings` allows you to configure which types of portfolios you want to be visible in the
   Portfolios screen. You can, for example, choose whether or not to include former members.

- `Readme` contains in-app background information that is comparable to this text.

- `Photo Clubs` lists the photo clubs that are currently loaded.
   A purple pin on the map shows the location where a selected club meets.
   A blue pin shows the location of any other photo club on that map.
   A button with a lock icon toggles whether the map is frozen or can be zoomed-and-panned.

- `Who's Who` lists the photographers that you can be found in the app.
   It shows information that is club-independent.
   The entries may display birthdays, and clickable links to personal
   (club-independent) photography sites.
   The `Search` bar filters the list of photographers.
   
- `Single portfolio`
   The actual title of this screen is the photographer's name.
   Note that there may be multiple portfolios for that photographer: one per photo club.
   Images are shown in chronological order, with the most recent first.
   For Fotogroep Waalre, you will see the year the image was created in the caption.
   You can *swipe* left or right to manually move backwards or forwards through the portfolio.
   There is also an *autoplay* mode that advances automatically to the next image after a delay.
    
### Multi-club Support

Version 1 of the app only supported Photo Club Waalre (aka *Fotogroep Waalre* in Dutch).
Version 2 added support for multiple photo clubs.
For a preview of how that works, drag down (“pull to refresh”) the Photo Clubs page.
This loads just enough test data to demo the feature.

### Roadmap
- [x] Put the app's source code on GitHub.
	- [x] Handle private data about members in a secure way
    - [ ] Publish article in Dutch photo club [organization](https://fotobond.nl)
- [ ] Support expositions by photo clubs. Here is an [example](https://www.fotogroepwaalre.nl/fotos/Expo2022/#2).
- [ ] MemberListView: show thumbnails of most recent photos. Already partially working prototype.
- [ ] MemberListView: automatically remove members who are no longer on the online membership lists.
- [ ] MemberGaleryView: replace use of WebKit by SwiftUI equivalent
- [ ] Support onboarding of clubs without any code changes. A big challenge, see below.
- [ ] Notifications when new images are published.

See the [open issues](https://github.com/vdhamer/PhotoClubWaalre/issues) for a list of
proposed enhancements and known limitations.

<p align="right">(<a href="#top">back to top</a>)</p>

## Installation

If you just want to install the binary version of the app, it is easiest to get it from Apple's app store ([link](https://apps.apple.com/nl/app/photo-club-waalre/id1178324330?l=en)).

### Built With

* [Swift](https://www.swift.org) - programming language
* [SwiftUI](https://developer.apple.com/xcode/swiftui/) - one of Apple's user interface frameworks
* [Core Data](https://developer.apple.com/documentation/coredata) - Apple's persistent storage framework
* [JuiceBox Pro](https://www.juicebox.net) - JavaScript image galleries
* [GitCrypt](https://github.com/AGWA/git-crypt) - encryption of selected files in Git repositories

### Cloning the Repository

To install the source code locally, it is easiest to use GitHub’s `Open with Xcode` feature.
Developers used to running Git from the command line should manage on their own.
Xcode covers the installation of the binary on a physical device or on an Xcode iPhone/iPad simulator.

### Code Signing

During the build you may be prompted to provide a developer license (personal or commercial)
when you want to install the app on a physical device. This is a standard Apple iOS policy
rather than something specific to this app.

Starting with iOS version 16 you will also need to configure physical devices to allow them to run apps
that have _not_ been distributed via the Apple App Store. This configuration requires enabling
`Developer Mode` on the device using `Settings` > `Privacy & Security` > `Developer Mode`.
Again, this is a standard Apple iOS policy.

### Updating the App

If you update to a newer build of the app, app data stored in the device's internal data storage 
will remain available.

If the data structure has changed, Core Data will automatically perform a so-called schema migration.
If you remove and reinstall the app, any existing CoreData data gets deleted.
This is standard behavior of Apple's Core Data framework, although the app does its bit
so that Core Data can track, for example, renamed struct types or renamed properties.

### Data Privacy

The following has *no impact* (zero, null, nil) on the app's functionality or user interface.
So feel free to skip this section.

The repo contains a 1 tiny file with encrypted data.
But encryption code can draw a lot of attention, so we are explaining it here
mainly so you don't waste time trying to figure our what's going on or whether
you consider that secure enough. It simply isn't a big deal :nerd_face:.

So... one tiny data file in the repository is encrypted. 
As you will expect, the key needed to decrypt the file is *not* provided.
The file, in its decrypted form, gives access to a password-protected HTML page on a server.
The HTML page contains telephone numbers and e-mail addresses of members of Photo Club Waalre. 
Apart from the fact that the data is of little interest, this has no impact because: 
- if the file is found to be encrypted, it is automatically substituted by another non-encrypted file 
  which doesn't give access to any sensitive data about members: it contains dummy data.
- phone numbers and e-mail addresses (real or dummy) are not used yet by the app.

So, all this hasstle is just so that a future App Store version *could* allow club members to
unlock extra functionality using a club-specific password,
but without leaking the supposedly sensitive data to non-members via GitHub.

But how would this future club-specific password be protected?
The app might try to check a hash of the provided password.
But a simple source code modification then gives access to the encrypted version of the web page.
Actually, not quite 🤓. Bypassing the password via a code modification, would allow the app to
fetch the encrypted data rather than the unencrypted dummy data. 
But that data is still encrypted by a private encryption key that is not provided on Github.

<p align="right">(<a href="#top">back to top</a>)</p>

## Contributing
All contributions are welcome.
Before investing a lot of coding effort, it might be good to first describe the idea or functional change in the description of `an Issue`.
That allows for some upfront discussion and iteration of the idea.

You can alternatively submit an `issue` with a tag like ”enhancement" or “bug” without having to do the code changes yourself.

### Areas for Contribution

Possible contributions include adding features, code improvements, ideas on architecture and interface
specifications, and possibly even a dedicated backend server.

Contributions that don't require coding include beta testing, well thought-through feature requests,
translations, and SVG icons.

<p align="right">(<a href="#top">back to top</a>)</p>

## The App Architecture

The app uses a [SwiftUI-based MVVM](https://www.hackingwithswift.com/books/ios-swiftui/introducing-mvvm-into-your-swiftui-project)
architecture pattern. 

The use of a SwiftUI-based MVVM architecture implies that the model data is stored in _structs_ 
rather than in slightly more heavyweight _classes_. It also implies that any changes to the
model data automatically trigger the required updates to the SwiftUI's `Views` and
that the gap between the `Model` and `View` layers are bridged by a `ViewModel` glue layer.

Each of the three layers has its own source code directory:
- [Model](https://github.com/vdhamer/PhotoClubWaalre/tree/main/Fotogroep%20Waalre/Model) contains the
  data model. It contains both the current version and older versions as separate files,
  as needed for schema migration.
- [View](https://github.com/vdhamer/PhotoClubWaalre/tree/main/Fotogroep%20Waalre/View) exclusively
  contains SwiftUI views.
- [ViewModel](https://github.com/vdhamer/PhotoClubWaalre/tree/main/Fotogroep%20Waalre/ViewModel) includes
  the code that populates and updates the model data.

### Role of the Database 

The model's data is loaded and updated via the internet, and is stored in an on-device database. 
Internally the database is [SQLite](https://en.wikipedia.org/wiki/SQLite), but that is abstracted
away using Apple's Core Data framework.

Because the data in the app's local database is in principle available online,
the app *could* have chosen to fetch that data over the network whenever the app is launched.
By using a database, however, the app starts up quicker because, at launch, the app 
can already display the database as left behind by the previous session.
That data might be a bit outdated, but is should be accurate enough to start off with. 

To handle any data updates, an asynchrous call fetches the current version of the data over the network. 
And the MVVM architecture uses this to update the user interface views as soon as the requested data arrives.
So occasionally, maybe one or two seconds after the app launches, the user may see the portfolio list
on the Portfolios screen change (using an animation). 
This can happen, for example if a club's online member list changed since the last session.

To be precise, the above is the target architecture. Right now there are still a few gaps -
even though it works well enough a user typically won't notice:
1. the lists of images per portfolio are *not* stored in the database yet.
   These images are also not cached. Image caching is a roadmap item.
2. members who are removed from the online membership list are not automatically deleted from the
   database. This requires a bit more administration, because these individuals don't show up
   iterates through the online membership list. This is simply because those names/records are
   _not_ on the online list anymore!
3. in the case of Fotogoep Waalre, some member data is not yet available online in a machine-readable
   form and is thus added programmatically instead. This is done in [this file](https://github.com/vdhamer/PhotoClubWaalre/blob/main/Fotogroep%20Waalre/ViewModel/FotogroepWaalre/FGWMembersProvider%2BinsertSomeHardcodedMemberData.swift).
   Examples of this hardcoded data include the club's officials (e.g. Chairman) and the date of birth of
   member.

Again, these 3 gaps need fixing. Some of these issues are addressed [below](#a-better-approach).

### The Data Model

Here are the three central concepts (also know as database entities or tables or struct types).

Note that the tables are fully "normalized" in the relational database sense,
meaning that redundancy in the data as stored has been minimized. 
Optional properties in the database with names like `PhotoClub.town_` have a corresponding computed
property that is not optional like `PhotoClub.town`. This allows `PhotoClub.town` to always return
a string value such as "Unknown town".

[![Product schema][product-schema]](https://github.com/vdhamer/PhotoClubWaalre/blob/main/Assets.xcassets/images/Schema.imageset/Schema.png)

#### PhotoClub

A `PhotoClub` is uniquely identified by it `name` *and* a `town` - just in case two towns have a photo club with the same name.

A `PhotoClub` has a rough address down to the `town` level and GPS coordinates representing where the club meets (say at the address level).
The GPS coordinates are used to insert markers on a map.

Esoteric side note: `town` and `country` are not currently localized.
Thus Germany should be labelled Deutschland (D) or Duitsland (NL), etc.
This can be fixed someday by doing a reverse geolocation lookup using the GPS coordinates
instead of storing `town` and `country` in the database.

#### Photographer

Some basic information about a `Photographer` (name, date of birth, personal website, ...) is
related to the `Photographer` as an individual, rather to the `Photographer's` membership of any
specific `PhotoClub`. This club-independent information is stored in the individual's `Photographer`
struct/record.

#### MemberPortfolio

Every `PhotoClub` has (zero or more) `Members` who can have various roles (`isChairman`, `isAdmin`, ...)
representing the tasks they perform in the photo club. A `Member` may have multiple roles within one
`PhotoClub` (e.g., members is both `isSecretary` and `isAdmin`).

Members also have a status, the implicit default being `isCurrent` membership.
Explicit status values include `isFormer`, `isAspiring`, `isHonorary` and `isMentor`.

`Portfolio` represents the work of one `Photographer` in the context of one `PhotoClub`.
A `Portfolio` contains `Images` (the list is not stored in the database yet). 
An `Image` can show up in multiple `Portfolios` if the `Photographer` presented the same photo within
multiple `PhotoClubs`.

`Member` and `Portfolio` can be considered *synonyms* from a modeling perspective:
we create exactly one `Portfolio` for each `PhotoClub` that a `Photographer` became a `Member` of.
And every `Member` of a `PhotoClub` has exactly one `Portfolio` - even if it still contains zero images - 
because this is needed to store information about this membership.
This one-to-one relationship between `Member` and `Portfolio` allows them to be 
modelled using once concept (aka table) instead of two. We named that `MemberPortfolio`.

### How the Data is Loaded

#### The Current Approach

The app currently uses one software module per club. This means a club can
in theory store their list of members (`MemberPortfolios`) any way they like.
It is then up to the software module to convert it to the app's internal data representation.
Similarly, a club can store their list of `Images` per member (`MemberPortfolio`) any way they like
and again leave it up to the software module to do the conversion.

Thus, the software module per photo club loads membership and portfolio data from the internet.
The data will likely be stored on the the club’s webserver, presumable in a simple file format.
The data is used to initialize the in-app database as well as to update it. 
This updating is done in background whenever the app lauches,
and thus takes care of changes in club membership as well as changes in member portfolios. 

For Photo Club Waalre, the membership data is read from an HTML table on a password protected
part of the club’s website. HTML is a bit messy to parse, but means the web page containing
the table can be displayed as as a password protected part of the website.

The portfolios use another approach which is somewhat more elegant as well as more robust and easier
to maintain: for Photo Club Waalre, portfolios are read from XML files generated by an Adobe Lightroom
Web plug-in called [JuiceBox-Pro](https://www.juicebox.net/). 
Thus portfolios are created and maintained within a Lightroom Classic catalog as a set of 
Lightroom collections. A new or changed portfolio can be uploaded to the webserver using the Upload button
of Lightroom's Web module. This triggers JuiceBox-Pro to generate an XML index file for the portfolio
and to upload the actual images to a server on the directory. All required settings (e.g. copyright
choice of directory) only need to be configured once per portfolio.

#### A Better Approach

A major design challenge for a next stage should be to provide a clean,
standardized interface to retrieve data per photo club.
That interface is needed to load the data, but also to keeps the data up to date.
This is needed because membership data and portfolios change regularly.
The current interface is essentially a plug-in design with an adaptor per photo club.
This needs to be replaced by a standard data interface to avoid
having to modify the source code whenever a new club comes onboard.

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
