<div id="top"></div>

[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![MIT License][license-shield]][license-url]

[![Portfolios Screen Shot][portfolios-screenshot]](https://github.com/vdhamer/PhotoClubWaalre)

<!-- TABLE OF CONTENTS -->
## Table of Contents
<ul>
	<details><summary><a href="#about-the-project">About the Project</a></summary>
      	<ul>
        	<li><a href="#whats-waalre">What's Waalre?</a></li>
        	<li><a href="#the-portfolio-concept">The Portfolio Concept</a></li>
			<li><a href="#implications-of-portfolios">Implications of Portfolios</a>
      	</ul>
    </details>
    <details><summary><a href="#screens">Screens</a></summary>
		<ul>
			<li><a href="#the-user-interface-screens">The User Interface Screens</a></li>
      	</ul>
    </details>
    <details><summary><a href="#features">Features</a></summary>
		<ul>
			<li><a href="#opening-animation">Opening Animation</a></li>
			<li><a href="#multi-club-support">Multi-club Support</a></li>
			<li><a href="#roadmap">Roadmap</a></li>
			<li><a href="#data-privacy">Data Privacy</a></li>
				<ul>
					<li><a href="#encryption-details">Encryption Details</a></li>
				</ul>
       	</ul>
    </details>
	<details><summary><a href="#installation">Installation</a></summary>
     	<ul>
    	   	<li><a href="#built-with">Built-With</a></li>
    	   	<li><a href="#cloning-the-repository">Cloning the Repository</a></li>
    	   	<li><a href="#code-signing">Code Signing</a></li>
    	   	<li><a href="#upgrading-the-app">Upgrading the App</a></li>
				<ul>
					<li><a href="schema-migration">Schema Migration</a></li>
				</ul>
      	</ul>
    </details>
    <details><summary><a href="#contributing">Contributing</a></summary>
       	<ul>
			<li><a href="#areas-for-contribution">Areas for Contribution</a></li> 
       	</ul>
	</details>
    <details><summary><a href="#the-app-architecture">The App's Architecture</a></summary>
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
	</details>
	<details><summary><a href="#administrative">Administrative</a></summary>
		<ul>  
       		<li><a href="#license">License</a></li>
       		<li><a href="#contact">Contact</a></li>
       	<li><a href="#acknowledgments">Acknowledgments</a></li>
		</ul>
	</details>
</ul>

## About the Project
<ul> 
<details><summary>

### What's Waalre?

</summary>
Photo Club Waalre is a photography club named after Waalre, a town in the south of 
The Netherlands. Its members meet since 1988, mainly to critique each other’s photos.</p>

This app originally served as an alternative way to view the photos published on the club's web
site. We expect to change the name of the app now that the app has been redesigned to support *multiple* photo clubs.
</details>
<details open><summary>
	
### The Portfolio Concept

</summary>

> The app showcases curated images made by members of photo clubs.

Since release 2.3.0, the app shows images using the following 3-level hierarchy:

* photo clubA (hosted on siteA)
  * portfolio1 for photographer1
    * images in portfolio1
  * portfolio2 for photographer2
    * images in portfolio2

* photo clubB (hosted on siteB)
  * portfolio3 for photographer3
    * images in portfolio3
  * portfolio4 for photographer4
    * images in portfolio4

<a/></p>

The `portfolio` level thus holds a photographer's images that are associated with one particular photo club.
The `photo club` level is the level at which a club's portfolios and images are administered. 
You can see photo club as the level at which "their" potfolios of images are hosted and curated.

For comparison, here's what personal websites of photographers tend to do:
	
* website for photographer1 (hosted on site1)
  * photo galleryA (e.g. portraits)
    * images in galleryA
  * photo galleryB (e.g. landscapes)
    * images in galleryB

* website for photographer 2 (hosted on site2)
  * photo galleryC
    * :

<a/></p>

<ul><details><summary>
		
### Implications of Portfolios
	
</summary>

As mentioned above, this app focusses on photographers as members of photo clubs.

If a photographer joined *multiple* photo clubs, the app can show *multiple* portfolios (with independent
content) for that photographer. This can be relevant if a photographer is simultaneously 
a member of _two_ clubs. But it also works if a photographer left one club and joined another club. 
In either case (and a lot of variations on this), the `portfolio` concept keeps both sets of images separate.</p>

Despite the focus on photo clubs, the app can link to a photographer's personal photography website.
Such sites often showcase a photographer's work as an individual.
Furthermore, nothing prevents you from supporting an online group of photography friends:
you will only need to give this "club" a name, and decide what images to post here.

If you really want, you could even consider yourself a one-person club and optionally use the portfolio concept
to organize different types of images. But a straightforward website would probably work file for this.

</detail></ul></detail>
</ul>
<p align="right">(<a href="#top">back to top</a>)</p>
 
## Screens

Usage of the various screens in the user interface:
<ul>

- The `Prelude` screen shows an opening animation.
  Clicking outside the central image brings you to the central `Portfolios` screen.

- The `Portfolios` screen lists the available portfolios
  (see above definition of `portfolio`).
  Clicking on a portfolio shows a screen with the "detailed" contents of that portfolio.
  Swiping left deletes an entry, but this is not normally needed and is currently harmless.
  The `Search` bar filters the list using the photographer's full name.

- The `individual portfolio` screen shows the portfolio of a user-selected photographer.
  The title at the top of the screen shows the photographer's name and club affiation: "Robert Capa @ Magnum Photos".

  Images are shown in present-to-past order, based on the images's *capture* date.
  For Fotogroep Waalre, the year the image was made is shown in the caption.

  You can *swipe* left or right to manually move backwards or forwards through the portfolio.
  There is also an *autoplay* mode for an automatic slide show. This screen is (for Fotogroep Waalre)
  currently based on a commercial Javascript module (Juicebox Pro) that is normally used on websites.

- The `Settings` screen allows you to configure which types of portfolios you want to include in the
  Portfolios screen. You can, for example, choose to include former members in addition to
  the default of current members.

- The `Readme` screen contains information about the app.

- The `Photo Clubs` screen lists the photo clubs that are currently loaded.
  A button with a lock icon toggles whether the map can be dragged-and-pinched.
  Interactive maps are powerful, but can be inconvenient if you need to scroll to other photo clubs.
  A _purple_ pin on the map shows where the club is based (e.g., a school or municipal building).
  A _blue_ pin shows the location of any other photo club that are visible on that map.

- The `Who's Who` screen lists the photographers that can be found in the app.
  It shows information that is club-independent.
  Whenever available, it displays birthdays or clickable links to personal
  (club-independent) photography websites.
  The `Search` bar filters the list of photographers.

</detail></ul></detail>
</ul>
<p align="right">(<a href="#top">back to top</a>)</p>
 
## Features
<ul>
<details><summary>

### Opening Animation

</summary>
When the app launches, it shows a large version of the app’s icon. 
Tapping on the icon turns it into an interactive image illustrating how most digital cameras detect color.</p>

> This involves a [Bayer color filter array](https://en.wikipedia.org/wiki/Bayer_filter)
> that filters the light reaching each photocell or pixel.
> In a 24 MPixel camera, the image sensor typically consist of an array of 4000 by 6000 photocells.
> Each photocell on the chip is not color-sensitive. But by placing a miniscule red, green of blue color filter on
> cop, it because best at seeing one specific color range. Thus in most cameras, only one color is measured per
> pixel: the two missing color channels for that pixel are estimated using color information from surrounding pixels.

Tapping *inside* the image allows you to zoom in or out to your heart's content.
Tapping *outside* the image brings you to the central screen of the app: a list of Portfolios.

You will see the Prelude animation again whenever you shut down and restart the app.
On wide screens (iPad, iPhone Pro Max) there is a navigation button that allows you to go back.

Why provide such a fancy opening screen? Well, it was partly a nice challenge to make (it actually runs
on the GPU cores). But it also helps explain the app's logo: the Bayer filter array indeed consists of one red,
one blue, and _two_ green pixels.
</details>

<details open><summary>
 
### Multi-club Support

</summary>
Version 1 of the app only supported Photo Club Waalre (known as *Fotogroep Waalre* in Dutch).
Version 2 added support for multiple photo clubs.
For a preview of how that works, drag down (“pull to refresh”) the Photo Clubs page.
This loads a little bit of additional data to demo the feature.
</details>

<details><summary>

### Data Privacy

</summary>
The phone numbers, e-mail addresses and ages of members of Fotogroep Waalre may not be public information.
They are read by the app, but not actually shown or used at present. For good measure, the data is stored
in encrypted form and decryted by the version of the app in the Apple App Store. The Github version
circumvents the encrypted data altogether, which - although a detail - turns out to be tricky to do reliably.

<ul><details><summary>

#### Encryption details

</summary>
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
</details></ul>
</details>

<details><summary>

### Roadmap

</summary>

- [x] Put the app's source code on GitHub.
	- [x] Handle private data about members in a secure way
    - [ ] Publish article in Dutch photo club [organization](https://fotobond.nl)
- [ ] Support expositions by photo clubs. Here is an [example](https://www.fotogroepwaalre.nl/fotos/Expo2022/#2).
- [x] MemberPortfoliosView: show thumbnails of most recent photos.
- [ ] MemberPortfoliosView: automatically remove members who are no longer on the online membership lists.
- [ ] MemberGaleryView: replace use of WebKit by SwiftUI equivalent
- [ ] Support onboarding of clubs without any code changes. A really large change, see below.
- [ ] Notifications when new images are published. An intermediate step towards the previous item.

See the [open issues](https://github.com/vdhamer/PhotoClubWaalre/issues) for a list of
proposed enhancements and known limitations.
</ul></detail>

<p align="right">(<a href="#top">back to top</a>)</p>


## Installation

If you just want to install the binary version of the app, just get it from Apple's app store ([link](https://apps.apple.com/nl/app/photo-club-waalre/id1178324330?l=en)).
<ul>
<details><summary>

### Built-With

</summary>

* the [Swift](https://www.swift.org) programming language
* Apple's newer [SwiftUI](https://developer.apple.com/xcode/swiftui/) user interface framework
* Apple's [Core Data](https://developer.apple.com/documentation/coredata) framework for persistent storage ("database")
* [Adobe Lightroom Classic](https://www.adobe.com/products/photoshop-lightroom.html) maintaining the portfolios (so far Fotogroep Waalre only)
* a low cost [JuiceBox Pro](https://www.juicebox.net) JavaScript plugin for exporting from Adobe Lightroom (so far Fotogroep Waalre only)
* the [GitCrypt](https://github.com/AGWA/git-crypt) framework for encrypting selected files in a Git repository
</details>

<details><summary>

### Cloning the Repository

</summary>
To install the source code locally, it is easiest to use GitHub’s `Open with Xcode` feature.
Developers used to running Git from the command line should manage on their own.
Xcode covers the installation of the binary on a physical device or on an Xcode iPhone/iPad simulator.
</details>

<details><summary>

### Code Signing

</summary>
During the build you may be prompted to provide a developer license (personal or commercial)
when you want to install the app on a physical device. This is a standard Apple iOS policy
rather than something specific to this app.

Starting with iOS 16.0 you will also need to configure physical devices to allow them to run apps
that have _not_ been distributed via the Apple App Store. This configuration requires enabling
`Developer Mode` on the device using `Settings` > `Privacy & Security` > `Developer Mode`.
Again, this is a standard Apple iOS policy. This doesn't apply to MacOS.
</details>

<details><summary>

### Updating the App

</summary>

If you update to a newer build of the app, all app data stored in the device's internal data storage 
will remain available. If you choose to remove and reinstall the app, the database content will be lost.
Fortunately, this has no real implications for the user as the data storage doesn't contain any relevant user data (so far).
	
<ul><details><summary>
	
#### Schema Migration
	
</summary>
If the data structure has changed from one version to a later version,
Core Data will automatically perform a so-called schema migration.
If you remove and reinstall the app, the Core Data database is lost, but this isn't an issue as the 
database so far doesn't contain any user data.
Schema migration is standard feature of Apple's Core Data framework, although the app does its bit
so that Core Data can track, for example, renamed struct types or renamed properties.
</details>
</details></ul>

<p align="right">(<a href="#top">back to top</a>)</p>

## Contributing
Bug fixes and new features are welcome.
Before investing effort in designing, coding testing, and refining features, it is best to first describe
the idea or functional change within a new or existing Github `Issue`.
That allows for some upfront discussion and prevents wasted effort due to overlapping initiatives.

You can submit an `Issue` with a tag like ”enhancement" or “bug” without commiting to make the code changes yourself.
Essentially that is an idea, bug, or feature request, rather than an offer to help.
</ul>

<ul><details><summary>

### Areas for Contribution

</summary>
Possible contributions include adding features, code improvements, ideas on architecture and interface
specifications, and possibly even a dedicated backend server.

Contributions that do not involve coding include beta testing, thoughtful and detailed feature requests,
translations, and icon design improvements.
</details></ul>

<p align="right">(<a href="#top">back to top</a>)</p>

## The App Architecture

The app uses a [SwiftUI-based MVVM](https://www.hackingwithswift.com/books/ios-swiftui/introducing-mvvm-into-your-swiftui-project)
architecture pattern.

<ul><details><summary> 

### MVVM Layers

</summary>
The use of a SwiftUI-based MVVM architecture implies that 
- the `model`'s data is stored in 
lightweight _structs_ rather than in _classes_. It also implies that any changes to the
model's data automatically trigger the required updates to 
- the SwiftUI's struct-based `Views`, while
- the intermediate class-based `ViewModel` layer translates between the `Model` and `View` layers.

Each of the layers has its own directory (found at the linked locations):
- [Model](https://github.com/vdhamer/PhotoClubWaalre/tree/main/Fotogroep%20Waalre/Model) contains the data model.
  It contains the current version of the database model as well as older versions _as separate files_. 
  This form of versioning is un-Git-like and is still used to support install-time schema migration.
- [View](https://github.com/vdhamer/PhotoClubWaalre/tree/main/Fotogroep%20Waalre/View) only
  contains SwiftUI views, which are at the Swift level structs that adhere to SwiftUI's View `protocol`.
- [ViewModel](https://github.com/vdhamer/PhotoClubWaalre/tree/main/Fotogroep%20Waalre/ViewModel) includes
  the code that populates and updates the database content ("model"). 
  This layer is currently implemented _per photo club_, and stored a subdirectory per club.

</details>
<details><summary>

### Role of the Database 

</summary>
The model's data is loaded and updated via the internet, and is stored in an on-device database. 
Internally the database is [SQLite](https://en.wikipedia.org/wiki/SQLite), but that is invisible because
it is wrapped inside Apple's Core Data framework.

Because the data in the app's local database is available online,
the app *could* have chosen to fetch that data over the network each time the app is launched.
By using a database, however, the app launches faster: on startup, the app 
can already display the content of the on-device database.

This implies showing the state of the data as it was at the end of the previous session.
That data might be a bit outdated, but is should be accurate enough to start off with. 

To handle any data updates, asynchrous calls fetch fresher data over the network. 
And the MVVM architecture uses this to update the user interface `Views` as soon as the requested data arrives.
So occasionally, maybe one or two seconds after the app launches, the user may see the Portfolios screen update. 
This can happen, for example if a club's online member list changed since the previous session.

To be precise, the above is the target architecture. Right now there are still a few gaps -
but because it usually works well enough, a user typically won't notice:
1. the lists of images per portfolio are *not* stored in the database yet.
   These images are also not cached. Image caching is a roadmap item.
2. the image thumbnail per portfolio is stored in the database as a URL.
   The actual file is not stored locally or cached yet. Thumbnail caching is a roadmap item. 
3. members who are removed from the online membership list are not automatically deleted from the
   database. This requires a bit more administration, because these individuals don't show up
   iterates through the online membership list. This is simply because those names/records are
   _not_ on the online list anymore!
4. in the case of Fotogoep Waalre, some member data is not yet available online in a machine-readable
   form and is thus added programmatically instead. This is done in [this file](https://github.com/vdhamer/PhotoClubWaalre/blob/main/Fotogroep%20Waalre/ViewModel/FotogroepWaalre/FGWMembersProvider%2BinsertSomeHardcodedMemberData.swift).
   This hardcoded data include the member's formal roles (e.g. chairman, treasurer).
5. Photo club data is minimal (name, town/country, GPS, website), but is currently still hardcoded.

Some of these gaps are addressed [below](#a-better-approach).
</details>

<details><summary>

### The Data Model

</summary>
Here are the three central concepts (also know as database entities or tables or struct types).

Note that the tables are fully "normalized" in the relational database sense,
This means that redundancy in the stored data is minimized via references. 

Optional properties in the database with names like `PhotoClub.town_` have a corresponding computed
property that is non-optional like `PhotoClub.town`. This allows `PhotoClub.town` to always return
a string value such as "Unknown town".

[![Product schema][product-schema]](https://github.com/vdhamer/PhotoClubWaalre/blob/main/Assets.xcassets/images/Schema.imageset/Schema.png)

<ul><details><summary>
	
#### PhotoClub

</summary>
A `PhotoClub` is uniquely identified by its `name` *and* a `town`. Including the town helps when two towns happen to have a photo club with the same name.

A `PhotoClub` has a rough address down to the `town` level and GPS coordinates. The GPS coordinates can precisely representing where the club meets (say at the address level). The GPS coordinates are used to insert markers on a map.

> A minor bug: `town` and `country` are not currently localized because they are stored in the database rather than the source code itself.
> Thus "Nederland" should be labelled "The Netherlands" if your device setting is set to English. The same applies to major cities.
> This could be fixed by recognizing "supported" locations, and then using iOS facilities to localize strings. But this would
> go against the vision of configuring club information without requiring any updates to the software. So the best solution is
> to do a reverse geolocation lookup (GPS --> localized strings), thus replacing the stored `town` and `country` strings in the database.
</details>

<details><summary>

#### Photographer

</summary>
Some basic information about a `Photographer` (name, date of birth, personal website, ...) is
related to the `Photographer` as an individual, rather to the `Photographer's` membership of any
specific `PhotoClub`. This club-independent information is stored in the individual's `Photographer`
struct/record.
</details>

<details><summary>

#### MemberPortfolio

</summary>
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
</details>
</details>
	
<details><summary>

### How the Data is Loaded

</summary>
<ul><details><summary>

#### The Current Approach

</summary>
The app currently uses a software module per club. This means a club can
in theory store their online list of members (`MemberPortfolios`) in any conceivable format.
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

The portfolios use another approach which is more elegant, technically more robust and easier
to maintain: for Photo Club Waalre, portfolios are read from XML files generated by an Adobe Lightroom
Web plug-in called [JuiceBox-Pro](https://www.juicebox.net/). 
Thus portfolios are created and maintained within a Lightroom Classic catalog as a set of 
Lightroom collections. A new or changed portfolio can be uplaoded (ftp) to the webserver using the Upload button
of Lightroom's Web module. This triggers JuiceBox-Pro to generate an XML index file for the portfolio
and to upload the actual images to a server on the directory. All required settings (e.g. copyright
choice of directory) only need to be configured once per portfolio.
</details>

<details><summary>

#### A Better Approach

</summary>
A major design challenge for a next stage should be to provide a clean,
standardized interface to retrieve data per photo club.
That interface is needed to load the data, but also to keeps the data up to date.
This is needed because membership data and portfolios change every few weeks.
The current interface is essentially a plug-in design with an adaptor per photo club.
This needs to be replaced by a standard data interface to avoid
having to modify the source code whenever a new club comes onboard.
</details></ul>
	</details></ul>
	
<p align="right">(<a href="#top">back to top</a>)</p>

## Administrative

<ul>

### License

Distributed under the MIT License. See `LICENSE.txt` for more information.

### Contact

Peter van den Hamer - github@vdhamer.com

Project Link: [https://github.com/vdhamer/PhotoClubWaalre](https://github.com/vdhamer/PhotoClubWaalre)

### Acknowledgments

* The opening Prelude screen uses a photo of colorful building by Greetje van Son
* A file with club member data is encrypted using [git-crypt](https://github.com/AGWA/git-crypt)

</ul>
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
