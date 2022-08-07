## Technical Changes (done)
* UIKit -> SwiftUI (and adoption of Model-View-ViewModel paradigm)
* CoreData / SQLite to store persistent data
* Coding rules follow SwiftLint's defaults
* adapted for iOS 15 - including some Task/Await asynchronous behavior

## Technical Changes (to do)
* Local storage as cache for images
* No use of WKWebView for galleries
* Search field on Member list
* support for MacOS
* replace "43 total members in PhotoClub" by "xx members shown"
* PhotoClub.refreshCountries() to asynchronously lookup Country (in localized String) for photo clubs with coordinates

## Bugs
* delete a PhotoClub or Photographer gives crash due to nul Photographer. Currently .ondelete is deactivated.
* removing an external link from the website does not remove it from core data
* error message related to Settings: invalid mode 'kCFRunLoopCommonModes' provided to CFRunLoopRunSpecific ("Log noise")

## Functional Changes (done)
* faster startup (less dependent on supporting website)
* schema can support multiple photo clubs with unique/common members
* Settings window to configure what kind of members to show per photo club
* More info visible in Member list
	* who are the club officials
    * support for honorary members
	* birthday
	* URL
	* e-mail (may not be shown)
	* tel (may not be shown)
* activate filtering of Member list

## Functional Changes (to do)
* More info visible in member list
    * thumbnail
    * # of images
* Use 2-D grid on iPadOS?
* Swipe thumbnails on home page?
* Gallery supports dark mode
* Support to zoom in on pictures
* Support expositions

## Fetching and updating strategy

## Schema and tables (done)
* Photographer
	* givenName, familyName
	* birthdate?
    * isDeceased, isDeviceOwner
    * photographerWebsite
* Member
	* ^Photographer, ^PhotoClub
	* isProspectiveMember, isMentor, isFormerMember, isHonoraryMember
    * isChairman, isViceChairman, isSecretary, isTreasurer, isAdmin
    * memberWebsite
    * fromDate?, asOf, to, bondsnummer? GPS home?
* PhotoClub
	* name = id
	* GPS coordinates, kvk_nr, fotobond_nr
    * photoclubWebsite
    
## Schema and tables (to do)
* Photo
	* ^Photographer
	* OnlineImageURL?,  CachedImageURL?
	* title?
	* caption?
* SeriesInExpo
	* ^ Exposition, ^Series, orderBy
* FotoInSeries
	* title?, ^Series, ^Foto, orderBy
* Exposition
	* name
	* ^PhotoClub
	* date range
	* location
