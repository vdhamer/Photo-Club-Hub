<div id="top"></div>

[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![MIT License][license-shield]][license-url]

![Portfolios Screen](images/portfoliosScreen.png "Portfolios Screen")

<!-- TABLE OF CONTENTS -->
## Table of [Contents
<ul>
    <details><summary><a href="#about-the-project">About the Project</a></summary>
          <ul>
            <li><a href="#the-app">The App</a></li>
            <li><a href="#photo-clubs]">Photo Clubs</a></li>
            <li><a href="#implications">Implications of Portfolios</a>
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
            <li><a href="#photo-museums-on-the-maps">Photo Museums</a></li>
            <li><a href="#data-privacy">Data Privacy</a></li>
                <ul>
                    <li>Encryption Details</li>
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
                    <li>Schema Migration</li>
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
                     <li>PhotoClub aka Organization</li>
                     <li>Photographer</li>
                     <li>MemberPortfolio</li>
               </ul>
               <li><a href="#how-data-is-loaded">How Data is Loaded</a></li>
               <ul>
                    <li>The Old Approach</li>
                    <li>The New Approach</li>
                    <ul>
                        <li>OrganizationList: central list of photo clubs</li>
                        <li>MemberList: local lists of photo club members</li>
                        <li>ImageList: local image portfolios per club member</li>
                    </ul>
               </ul>
               <li><a href="#when-data-is-loaded">When Data is Loaded</a></li>
               <ul>
                    <li>Background Threads</li>
                    <li>SwiftUI View Updates</li>
                    <li>Core Data Contexts</li>
                    <li>Comparison to SQL Transactions</li>
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

<ul><details open><summary>

### The App

</summary>

This iOS app showcases photographs made by members of photography clubs.
It thus provides a permanent online exposition or gallery with selected work of these photographers.

Version 1 of the app only supported a _single_ photo club in Waalre, a smallish town in the Netherlands.
Version 2 added support for _multiple_ photo clubs. This allows viewers to see images from multiple clubs within a single app.
It also provides a degree of uniformity, thus sparing the user from having to find each club's website, 
discovering how to navigate within each site and how to browse through the individual images. 
Starting in version 2 the app's name was changed from _Photo Club Waalre_ to _Photo Club Hub_. 
    
To achieve this, the app retrieves software-readable lists of photo clubs, their
lists of members and their curated images from one or more servers. 
This ensures that photo clubs, club members and member images can be added or chanaged without requiring a new release of the app.

See the [Architecture](#the-app-architecture) section for how this information is structured and distributed.
Help in the form of coding, testing and suggestions is highly appreciated. See the [section](#contributing) on contributing below.

</details>

<details open><summary>
    
### Photo Clubs

</summary>

> The app showcases curated images made by members of photo clubs.

Since release 2.3.0, the app structures the information in a 3-level hierarchy.
Here is a schematic representation of the "Portfolios" view that essentially puts photo clubs first:

* photo clubA (hosted on siteA)
  * portfolio1 of photographer1
    * images within portfolio1
  * portfolio2 of photographer2
    * images within portfolio2

* photo clubB (hosted on siteB)
  * portfolio3 of photographer3
    * images within portfolio3
  * portfolio4 of photographer4
    * images within portfolio4

<a/></p>

An alternative navigation path is provided by the "Who's Who" view.
This view puts the photographer first, thus allowing you to find a person without knowing the name of their club:

* photographer1
  * photo club A
      * images of photographer 1 in context of club A
  * photo club B (optional)
      * images of photographer 1 in context of club B     

* photographer2
  * photo club A (or B or whatever)
      * images of photographer 2 in context of club A

* photographer3
  * :

<a/></p>

For comparison, traditional personal websites stress the photographer's images, without any reference to clubs:
    
* website for photographer1 (hosted on site1)
  * photo galleryA (e.g. portraits)
    * portraits in galleryA
  * photo galleryB (e.g. landscapes)
    * landscapes in galleryB

* website for photographer 2 (hosted on site2)
  * photo galleryC (e.g. macro)
    * :

<a/></p>

<ul><details><summary>
        
### Implications
    
</summary>

If a photographer joined *multiple* photo clubs, the app can show *multiple* portfolios (with independent
content) for that photographer - one per photo club. This could mean that the photographer is currently 
a member of _two_ different clubs. But it could also mean that a photographer left one club and joined another club.
Or variations of these scenarios.

> In all cases, the `portfolio` concept groups the images both by photographer and by photo club. </p>

The app is thus not intended as a personal website replacement, but it can have links to a photographer's personal website.
Furthermore, nothing prevents you from supporting an online group of photography friends - assuming
that they are interested in organizing this together.

You could even consider yourself a one-person club and put your images in a single portfolio below that club.
Or you could use the club level to group a few individual photographers (by region or interest) as long as the members
of this non-club are willing to align (e.g. maintain the list of portfolios=photographers who are then a member of a loosely-knit club).

</detail></ul></detail>

</ul>
<p align="right">(<a href="#top">back to top</a>)</p>
 
## Screens

Usage of the various screens in the user interface:
<ul>

- The `Prelude` screen shows an opening animation.
  Clicking outside the central image brings you to the central `Portfolios` screen.

- The `Portfolios` screen lists all the photo clubs featured by the app.
  It allows you to first select a photo club and then select the portfolio of one of its members.
  The `Search` bar filters the lists of club members using the photographer's full name.
  Swiping left deletes an entry, but this is not normally needed and is not permanent (yet)).

  ![Portfolios Screen](images/portfoliosScreen.png "Portfolios Screen")

- The `Who's Who` screen lists all the photographers known to the app.
  It allows you to first select the photographer and then select that person's club-specific portfolio.
  If available, club-independent information (like birthdays) for that photographer is displayed here.
  The `Search` bar filters on photographer names.

- The `Clubs and Museums` screen lists all photo clubs that are known to the app.
  Each entry predominantly contains a map showing where the club is located and optionally your current location.
  A button with a lock icon toggles whether the map is can be controlled interactively (scroll, zoom, rotate, 3D).
  By default, the maps are not interactive. This mode helps scroll through the list of clubs rather than scrolling within a map.
  A _purple_ pin on the map shows where the selected club is based (e.g., a school or municipal building).
  A _blue_ pin shows the location of any other photo club that happens to be in the displayed region.
  The screen can also show any photo museums that happen to be in sight. These have different markers than the photo clubs.
  The plan is that the screen can switch between listing all photo clubs and listing all photo museums.
  
- The `Preferences` screen allows you to configure which types of portfolios you want to include in the
  Portfolios screen. You can, for example, choose whether to include former members.
  The `Preferences` screen probably should also filter the `Who's Who` screen - but it doesn't yet.

- The `Readme` screen contains background information on the app and info on app usage.

- The `individual portfolio` screen can be reached by tapping on a `portfolio` in either the
  `Portfolios` or the `Who's Who` screen.
  The title at the top of the screen shows the selected photographer and selected club affiation:
  "Jane Doe @ Club F/8".

  Images are shown in present-to-past order, based on the images's _capture_ date.
  For Fotogroep Waalre, the year the image was made is shown in the caption.

  You can _swipe_ left or right to manually move backwards or forwards through the portfolio.
  There is also an _autoplay_ mode for an automatic slide show. This screen is (for Fotogroep Waalre)
  currently based on a Javascript plug-in (`Juicebox Pro`) that is normally used in website creation.

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
on the GPU cores). But it also helps explain the app's logo: the Bayer filter array indeed consists of
one red, one blue, and _two_ green pixels.

</details>

<details open><summary>
 
### Multi-club Support

</summary>
Version 1 of the app only supported Photo Club Waalre (known as *Fotogroep Waalre* in Dutch).
Version 2 added support for multiple photo clubs. This means:

- all clubs in the system are technically handled in the same way (although some may have provided more data)
- users can find all supported clubs on the provided maps
- a photographer is shown associated with multiple clubs if applicable (e.g., former club, current club)
- the app is stepwise being prepared for larger amounts of data (data is distributed over sites)
- the app is starting to enable that clubs can manage their own data (data "within" a club is managed by the club)
</details>

<details><summary>

### Photo Museums

</summary>

The maps showing the location of photo clubs can also show the locations of selected photo museums.
A photo museum is not a photo club and is displayed on the maps using a dedicated marker.
Techncially, the app doesn't allow museums to have "members" that share images with the museum.

Consider the showing of museums a bonus that may interest some users.
You are welcome to add a favorite photo museum via a GitHub Pull Request. It only requires extending a JSON file.
The file format is documented below under [How Data is Loaded / The New Approach](#how-data-is-loaded).

</details>

<details><summary>

### Data Privacy

</summary>
The phone numbers, e-mail addresses and ages of members of Fotogroep Waalre may not be public information.
They are read by the app, but not actually shown or used at present. For good measure, the data is stored
in encrypted form and decryted by the version of the app in the Apple App Store. The GitHub version
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
But that data is still encrypted by a private encryption key that is not provided on GitHub.

</details></ul>
</details>

<p align="right">(<a href="#top">back to top</a>)</p>

## Installation

If you just want to install the binary version of the app, just get it from Apple's app store ([link](https://apps.apple.com/nl/app/photo-club-waalre/id1178324330?l=en)).

<ul>
<details><summary>

### Built-With

</summary>

* the [Swift](https://www.swift.org) programming language
* Apple's [SwiftUI](https://developer.apple.com/xcode/swiftui/) user interface framework
* Apple's [Core Data](https://developer.apple.com/documentation/coredata) framework for persistent storage ("database")
* [Adobe Lightroom Classic](https://www.adobe.com/products/photoshop-lightroom.html) maintaining the portfolios (so far Fotogroep Waalre only)
* a low cost [JuiceBox Pro](https://www.juicebox.net) JavaScript plugin for exporting from Adobe Lightroom (so far Fotogroep Waalre only)
* the [GitCrypt](https://GitHub.com/AGWA/git-crypt) framework for encrypting selected files in a Git repository
* GitHub's [SwiftyJSON](https://GitHub.com/SwiftyJSON/SwiftyJSON) package for accessing JSON content via paths (dictionaries that recursively contain dictionaries)
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
the idea or functional change within a new or existing GitHub `Issue`.
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

</ul>

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
- [Model](https://GitHub.com/vdhamer/PhotoClubWaalre/tree/main/Fotogroep%20Waalre/Model) contains the data model.
  It contains the current version of the database model as well as older versions _as separate files_. 
  This form of versioning is un-Git-like and is still used to support install-time schema migration.
- [View](https://GitHub.com/vdhamer/PhotoClubWaalre/tree/main/Fotogroep%20Waalre/View) only
  contains SwiftUI views, which are at the Swift level structs that adhere to SwiftUI's View `protocol`.
- [ViewModel](https://GitHub.com/vdhamer/PhotoClubWaalre/tree/main/Fotogroep%20Waalre/ViewModel) includes
  the code that populates and updates the database content ("model"). 
  This layer is currently implemented _per photo club_, and stored a subdirectory per club.

</details></ul>
<ul><details><summary>

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
   form and is thus added programmatically instead. This is done in [this file](https://GitHub.com/vdhamer/PhotoClubWaalre/blob/main/Fotogroep%20Waalre/ViewModel/FotogroepWaalre/FGWMembersProvider%2BinsertSomeHardcodedMemberData.swift).
   This hardcoded data include the member's formal roles (e.g. chairman, treasurer).
5. Photo club data is minimal (name, town/country, GPS, website), but is currently still hardcoded.

Some of these gaps are addressed [below](#a-better-approach).
</details></ul>

<ul><details><summary>

### The Data Model

</summary>
Here are the entities managed by the app's internal Core Data database. The entities (rounded boxes) are tables and arrows are relationships in the underlying SQLite database.</p>

![Data model](images/dataModel.png "The data model")

Note that the tables are fully "normalized" in the relational database sense.
This means that redundancy in all stored data is minimized via referencing. 

Optional properties in the database with names like `PhotoClub.town_` have a corresponding computed
property that is non-optional named `PhotoClub.town`. This allows `PhotoClub.town` to always return
a `String` value such as "Unknown town" rather than an optional `String?` value.

<ul><details><summary>
    
#### Organization

</summary>
This table contains both photo clubs and musea. Many properties apply to both.
The relationship to `OrganizationType` is used to distinguish betweene both.
Currently `OrganizationType` (essentially an enum) has only two allowed values: `club` and `museum`.
But, for example,`festivals` could also be added in the future.

An organization is uniquely identified by its `name` *and* a `town`.
Including the town is necessary because two towns might have local photo clubs that happen to have the same name.
This is unlikely for musea, but the same approach is used just in case.

An `Organization` has a rough address down to the `town` level and GPS `coordinates`.
The GPS coordinates can precisely indicate where the club meets (often good enough for navigation purposes). 
The GPS coordinates are used to insert markers on a map. 
The GPS coordinates are also used to localize `town` and `country` names by asking an online mapping 
service to convert GPS coordinates into a textual address, using the device's current location as input.
</details></ul>

<ul><details><summary>

#### Photographer

</summary>
Some basic information about a `Photographer` (name, date of birth, personal website, ...) is
related to the `Photographer` as an individual, rather to the `Photographer's` membership of any
specific `PhotoClub`. This club-independent information is stored in the individual's `Photographer`
struct/record.
</details></ul>

<ul><details><summary>

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
</details></ul>

<ul><details><summary>

#### OrganizationType

</summary>
This is a tiny table used to hold the supported types of `Organization` records.
It could be used someday to drive a picker in a data editing tool.
For now, it ensures that each `Organization` belong to exactly one of the supported `OrganizationTypes`.
And it could be used to generate statistics about how man `Organizations` per `OrganizationType` are supported.
</details></ul>

<ul><details><summary>

#### Language

</summary>
The `Language` table is a tiny table to hold the languages supported by the OrganizationList.json file.
For now, it is intended only to support the `LocalizedDescription` table. 
It is not in use yet (Jan 2024).
Initially a hardcoded equivalent is used to load localized descriptions from OrganizationList.json.

By storing it in the database, the set of supported `Languages` in OrganizationList.json can be opended.
For example, a museum in Portugal may have an English and a Portugues description, 
even when the user interface is only localized to English and Dutch.
This allows the app to display Portuguese text for the local museum if the device is set to Portuguese,
while the user interface will be shown in English as long as Portuguese is not supported.

A side benefit of this approach is that localized descriptions can be provided without having to wait until
the app provides full support for a language.
</details></ul>

<ul><details><summary>

#### LocalizedDescription

</summary>
The `LocalizedDescription` table holds very brief descriptions of an `Organization` in zero or more `Languages`. 
Descriptions are optional, but are recommended. The `LocalizedDescription` table, but is not filled yet.
Instead the localized description texts are temporarily stored in hard-coded property fields
(`descriptionEN`, `descriptionNL`) in the `Organization` table.

An `Organization` record can be linked to 0, 1, 2 or more `Languages` regardless of whether the app fully supports that language.
The ISO 2 or 3-letter code of the language and a readable name are stored in `Language`.
The actual text shown in the user interface is shown in the `LocalizedDescription` table.

If the device is configured at the iOS level to use e.g. FR for French, the app will give priority to displaying `LocalizedDescriptions` in French if encountered.
Otherwise it defaults to English, if available. If preferred langugages are not available, it will use a less suitable language if available.
</details></ul>
</details></ul>
    
<ul><details><summary>

### How Data is Loaded

</summary>
<ul><details><summary>

#### The Old Approach

</summary>
The app currently uses a software module per club. This means a club can
concievably store their online list of members (`MemberPortfolios`) in any format.
It is then up to the software module to convert it to the app's internal data representation.
Similarly, a club could store their list of `Images` per member (`MemberPortfolio`) in any
conceivable format as long as the software module does the conversion.

Thus, the software module per photo club loads membership and portfolio data across the network.
The data will likely be stored on the club’s website somewhere, presumable in a simple file format.
That data is then loaded into the in-app database, but also used to updated the database.
This updating is done (on a background thread) whenever the app lauches,
and thus takes care of changed membership lists as well as changed image portfolios.

For Photo Club Waalre, the __membership list__ is read from an HTML table on a
page on the club’s website. HTML is messy to parse, but also serves as a web page
for the club's website.

In the case of Photo Club Waalre, the membership list is password protected in Wordpress and the app bypasses that password 
using a long key and the Wordpress [Post Password Token](https://wordpress.org/plugins/post-password-plugin/) plugin. 
The GitHub version uses a (redacted) copy of the membership list in order to show real data. Details about these details
can be found above.
    
The __image lists__ or `portfolios` use a more robust and easier to maintain approach: 
for Photo Club Waalre, portfolios are read from XML files generated by an Adobe Lightroom
Web plug-in called [JuiceBox-Pro](https://www.juicebox.net/). 
Thus portfolios are created and maintained within a Lightroom Classic catalog as a set of 
Lightroom collections. A portfolio can be uploaded or updated to the webserver using the Upload (ftp) button
of Lightroom's Web module. This triggers JuiceBox-Pro to generate an XML index file for the portfolio
and to upload the actual images to the server. All required settings (e.g. copyright,
choice of directory) only need to be configured once per portfolio (=member).
</details></ul>

<ul><details><summary>

#### The New Approach

</summary>
A major design goal for the near future is to provide a clean,
standardized interface to retrieve data per photo club.
This data is then loaded into into the in-app CoreData database.
It is also needed to keep the CoreData database up to date whenever
clubs, members or images are added.
The old approach is essentially a plug-in design with an adaptor per photo club.

The new approach replaces this by a standardizable data interface to avoid
having to modify the source code to add (or modify/remove) clubs, members or images.
The basic idea here is to store the required information in a hierarchical, distributed way.
This allows the app to load the information in a three step process:

__1. OrganizationList: central list of photo clubs__</p>

The app loads a list of photo clubs from a fixed location (URL). Because the file is kept external to the actual app,
the list can be updated without requiring an app software update.
The file is in a fixed JSON syntax and contains a list of supported photo clubs.

As a bonus, the list can also contain information about photography museums. The properties of clubs and museums largely overlap,
but a photo club _can_ notably include the location (URL) of a MemberList.json data source while a museum _cannot_.

Here is an example of the format of the OrganizationList. This minimal example contains one photo club and one photo museum:

``` json
{
    "clubs": [
        {
            "idPlus": {
                "town": "Eindhoven",
                "fullName": "Fotogroep de Gender",
                "nickName": "FG deGender"
            },
            "coordinates": {
                "latitude": 51.42398,
                "longitude": 5.45010
            }
            "website": "https://www.fcdegender.nl",
            "memberList": "https://www.example.com/deGenderMemberList.json",
            "remark": [
                { "language": "NL", "value": "Opgelet: Fotogroep de Gender gebruikt als domeinnaam nog altijd fcdegender.nl (van Fotoclub)." }
            ],
            "nlSpecific": {
                "fotobondNumber": 1620
            }
        }
    ],
    "museums": [
        {
            "idPlus": {
                "town": "New York",
                "fullName": "Fotografiska New York",
                "nickName": "Fotografiska NYC"
            },
            "coordinates": {
                "latitude": 40.739278,
                "longitude": -73.986722
            }
            "website": "https://www.fotografiska.com/nyc/",
            "wikipedia": "https://en.wikipedia.org/wiki/Fotografiska_New_York",
            "remark": [
                { "language": "EN", "value": "Fotografiska New York is a branch of the Swedish Fotografiska museum." }
                { "language": "NL", "value": "Fotografiska New York is een dependance van het Fotografiska museum in Stockholm." }
            ]
        }
    ]
}
```
Note that:
- All fields within `idPlus` and `coordinates` are required. All other fields can be omitted if the data is not available or not applicable.
- `idPlus.town` and `idPlus.fullName` together serve to differentiate clubs or museums from others. Try to avoid changing these strings. 
- `coordinates` is used to draw the club on the map and to [generate](http://www.vdhamer.com/reversegeocoding-for-localizing-towns-and-countries/) localized versions of town and country names. Latitudes are in the range [-90.0, +90.0] where negative `latitude` means south of the Equator. Longitude values are in the range [-180.0, +180.0] where negative `longitude` means west of Greenwich London.
- The `memberList` field (for clubs only) allows the app to find the next level list with membership data. It is reserved for future use.
- The `wikipedia` field contains a link to a Wikipedia page for a museum. It is unlikely that a photo club will have a page in Wikipedia, but it would work.
- The `remark` field contain a brief remark note withy something worth knowing about the item. The `remark` contains an array of alternative strings in multiple languages. The app selects which language to use based on the device's language settings.
- The `nlSpecific` container has optional fields that are only relevant for clubs in the Netherlands. `fotobondNumber` is an ID number assigned by the national federation of photo clubs.
</p>

__2. MemberList: local lists of photo club members__</p>

Each MemberList defines the current (and potentially former) members of a single club.
For each member, a URL is stored pointing to the final list level (portfolio per member).
MemberList also includes the URL of an image used as thumbnail for that member.
MemberList can be stored and managed on the club's own server. The file needs to be in
a JSON format to allow the app to interpret it correctly.
A future editing tool (app or web-based) would help ensure syntactic and schema consistency.

Here is an example of the (draft) format of the MemberList of a photo club with a single member:

``` json
{
    "club": [
        {
            "idPlus": {
                "town": "Eindhoven",
                "fullName": "Fotogroep de Gender",
                "nickName": "FG deGender"
            },
            "coordinates": {
                "latitude": 51.42398,
                "longitude": 5.45010
            }
            "website": "https://www.fcdegender.nl",
            "memberList": "https://www.example.com/deGender.memberList.json"
        }
    ],
    "members": [
        {
            "name": {
                "givenName": "Peter",
                "infixName": "van den",
                "familyName": "Hamer"
            },
            "roles": {
                "admin": true
            },
            "birthday": "9999-10-18T00:00:00.000Z",
            "website": "https://glass.photo/vdhamer",
            "featuredImage": "http://www.vdhamer.com/wp-content/uploads/2023/11/PeterVanDenHamer.jpg",
            "imageList": "https://www.example.com/FG_deGender/Peter_van_den_Hamer.imagelist.json"
        },
    ]
}
```

Notes about the `club` section:
- `club` is the same as one object/record in the OrganizationList. It documents the club that the MemberList is for.
- the `town` and `fullName` fields are required.
- `town` and `fullName` must exactly match the corresponding fields in the OrganizationList.json file.
- the `memberList` field can be provided, but it's value is generally overruled by the OrganizationList's "memberList" value.
- a club's `nickName`, `latitude`, `longitude`, and `website` can overrule the corresponding OrganizationList fields if needed.</p>

Notes about the `members` section:
- a member's `givenName`, `infixName` and `familyName` are used to uniquely identify the photographer.
- `givenName` and `familyName` are required. An omitted "infixName" is equivalent to "infixName" = "".
- `infixName` will often be empty. It enables correctly sorting European surnames: "van Aalst" sorts like "Aalst".
- the `imageList` field allows the app to find the next level list about the selected images per member.</p>

__3. ImageList: local image portfolios per club member__</p>

The list of images (per club member) is fetched only when a portfolio is selected for viewing.
There is thus no need to prefetch the entire 3-level tree (root/memberlist/imagelist).
Again, this index needs to be in a fixed format, and thus will possibly 
require an editing tool to guard the syntax. Currently this tool already exists:
index and files are exported from Lightroom using a Web plug-in.
Depending on local preference, this level can be managed by a club volunteer, 
or distributed across the individual club members. 
In the latter case, a portfolio can be updated whenever a member wants.
In the former (and more formal) case, the club can have some kind of approval 
or rating system in place.
</details></ul>
</details></ul>

<ul><details><summary>

### When Data is Loaded

</summary>
<ul><details><summary>

#### Background Threads

</summary>

Membership lists are loaded into Core Data using a dedicated background thread per photo club.
So if, for example, 10 clubs are loaded, there will be a main thread for SwiftUI, 
a few predefined lower priority threads, plus 10 temporary background threads (one per club).
Each background thread reads optional data stored inside the app itself, and then reads optional online data.
A club's background thread disappears as soon as the club’s membership data is fully loaded.

These threads start immediately once the app is launched (in `Foto_Club_Hub_Waalre_App.swift`).
This means that background loading of membership data already starts while the Prelude View is displayed.

</details></ul>
<ul><details><summary>

#### SwiftUI View Updates

</summary>

It also means that slow background threads might complete after the list of members is displayed in
the Portfolio View. This may cause an update of the membership lists in the Portfolio View.
This will be rarely noticed because the Portfolio View displays data from the Core Data database,
and thus usually arleady contains data persisted from a preceding run. But you might see updates
found within the online data or updates when the app is run for the first time.
</details></ul>
<ul><details><summary>

#### Core Data Contexts

</summary>

Each thread is associated with a Core Data `NSManagedObjectContext]`.
In fact, the thread is started using `myContext.perform()`.
The trick to using Core Data in a multi-threaded app is to ensure that all database fetches/inserts/updates 
are performed using the Core Data `NSManagedObjectContext` while running the associated thread. Schematically:<P>

- create `NSManagedObjectContext` of type Background. A CoreData feature.
  - create thread using myContext.perform(). A CoreData feature using an OS feature.
    - perform database operations from within the thread while passing this CoreData context. A CoreData feature.
    - commit data to database using `myContext.save()`. A CoreData feature.
    - do any other required operations ended by additional `myContext.save()`. A CoreData feature.
  - end usage of the thread. The thread will disappear. A Swift feature.
- the `myContext` object disappears when it is no longer used. A Swift feature.

</P>The magic happens within `myContext.save()`.
During the `myContext.save()` any changes are committed to the database 
so that other threads can now see those changes and the changes are persistently stored.
Note that `myContext.save()` can throw an exception - especially if there are 
inconsistencies such as data merge conflicts, or violations of database constraints.
</details></ul>

<ul><details><summary>

#### Comparison to SQL Transactions

</summary>
A Core Data `NSManagedObjectContext` can be seen as a counterpart to an SQL transactions.<P>

- create thread. An OS/language feature.
  - start transaction. An SQL feature.
    - perform SQL operations from within a thread. This is implicitly within the transaction context. An SQL feature.
    - end transaction (commit or rollback). SQL feature.
  - optionally start a next transaction (begin transaction > SQL operations > commit transaction)
- end thread. An OS/language feature.</P>

</details></ul>
</details></ul>
    
<p align="right">(<a href="#top">back to top</a>)</p>

## Administrative

### License

Distributed under the MIT License. See `LICENSE.txt` for more information.

### Contact

Peter van den Hamer - vdhamer@gmail.com

Project Link: [https://GitHub.com/vdhamer/PhotoClubWaalre](https://GitHub.com/vdhamer/PhotoClubWaalre)

### Acknowledgments

* The opening Prelude screen uses a photo of colorful building by Greetje van Son.
* One file with club member data is encrypted using [git-crypt](https://GitHub.com/AGWA/git-crypt).
* The interactive Roadmap screen uses the [AvdLee/Roadmap](https://GitHub.com/AvdLee/Roadmap) package. The screen is currently disabled because the backend provider of Roadmap stopped supporting it.
* The diagram with Core Data entities was generated using the [Core Data Model Editor](https://GitHub.com/Mini-Stef/Core-Data-Model-Editor) tool by Stéphane Millet.
* JSON parsing uses the [SwiftyJSON/SwiftyJSON](https://GitHub.com/SwiftyJSON/SwiftyJSON) package.

<p align="right">(<a href="#top">back to top</a>)</p>

<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[contributors-shield]: https://img.shields.io/GitHub/contributors/vdhamer/PhotoClubWaalre.svg?style=for-the-badge
[contributors-url]: https://GitHub.com/vdhamer/PhotoClubWaalre/graphs/contributors
[forks-shield]: https://img.shields.io/GitHub/forks/vdhamer/PhotoClubWaalre.svg?style=for-the-badge
[forks-url]: https://GitHub.com/vdhamer/PhotoClubWaalre/network/members
[stars-shield]: https://img.shields.io/GitHub/stars/vdhamer/PhotoClubWaalre.svg?style=for-the-badge
[stars-url]: https://GitHub.com/vdhamer/PhotoClubWaalre/stargazers
[issues-shield]: https://img.shields.io/GitHub/issues/vdhamer/PhotoClubWaalre.svg?style=for-the-badge
[issues-url]: https://GitHub.com/vdhamer/PhotoClubWaalre/issues
[license-shield]: https://img.shields.io/GitHub/license/vdhamer/PhotoClubWaalre.svg?style=for-the-badge
[license-url]: https://GitHub.com/vdhamer/PhotoClubWaalre/blob/main/.GitHub/LICENSE.md
