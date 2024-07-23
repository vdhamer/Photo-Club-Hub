### 2.6.3 (GitHub commit fbeb334) 13-07-24

Data
* The membership data for Fotogroep de Gender and Fotogroep Anders are now read from level2.json data files.

Maintenance
* Added a wikipedia link for the club fgDeGender. The link is loaded from a prototype level2.json file.
* Initial ability to read list of club members from a data file (`fgDeGender.level2.json`).
* Tested on iOS 18.0 beta 4 (22A5316j), Xcode 16.0 beta 4 (16A5211f) and Vision Pro 2.0 beta 4 (22N5286g).

This build #4629 was made with Xcode 16.0.

---------------------------------------------------------------------------

### 2.6.3 (GitHub commit fbeb334) 13-07-24

Portfolios screen
* Removed function to delete rows by swiping left.

Clubs and Museums screen
* Removed function to delete rows by swiping left.
* Fixed bug causing remarks about clubs and museums to be missing.
* Changed the Dutch text if no localized remarks are available.
* Added smart scrolling with optimization for iOS 18.
* Updated notes at bottom of screen.

Preferences screen
* Added button to Photo Club Hub section of Settings app for advanced settings.

Readme screen
* Removed text about deleting elements by swiping left and general cleanup.
* Changed the opening image (now shows 3 level as screenshots) and removed apple-in-glass image.

iOS Settings
* Minor text changes.
* Settings will allow you to always choose all supported languages (UIPrefersShowingLanguageSettings).

Maintenance
* Tested on iOS 18.0 beta 3 (22A5307f), Xcode 16.0 beta 3 (16A5202i) and Vision Pro 2.0 beta 3 (22N5277g).
* Updated README documentation on GitHub.

This build #4628 was made with Xcode 15.4 and was distributed via TestFlight and the App Store.

---------------------------------------------------------------------------

### 2.6.2 (GitHub commit 9e14585) 30-06-24

Prelude screen
* Changed color ordering to match app icon colors

Portfolios screen
* Swiping down the top of the screen will now erase and reload stored data

Clubs and Museums screen
* Swiping down the top of the screen will now erase and reload stored data

Who's Who screen
* Swiping down the top of the screen will now erase and reload stored data

Settings App
* Added version/build info to app's settings
* Added debug toggles

App Store
* Fixed old app name on Dutch app store

Maintenance
* Tested on iOS 18.0 beta 2 (22A5297f), Xcode 16.0 beta 2 (16A5171r), Vision Pro 2.0 beta.
* Icon prepared for home screen dark and tinted mode.
* Updated FGW member list: former coach Hans Zoete has passed away.
* Reduced number of CoreData save() transactions.

This build #4627 was made with Xcode 16.0 beta 2 (16A5171r) and distributed via the App Store.

---------------------------------------------------------------------------

### 2.6.2 (GitHub commit 1536a1e) 16-06-24

This is build #4625.

Clubs and Museums screen
* Changed icon by which an organization type (other than club or museum) is displayed on map. It shouldn't show up.

Maintenance
* Tested on iOS 18.0 beta 1, and Xcode 16.0 beta (16A5171c).
* Improved robustness of OrganizationType.getter (gave crash if value was somehow missing).
* Forced one-time reloading (from scratch) of CoreData information when release is 2.6.2 or higher.
* Changes to prepare for Swift 6 language mode (with its static data-race checking).
* Added "Manual loading" mode (compile-time setting) for testing.
* Removed some hard-coded member data for FGW club that was no longer needed.

This is build #4625 and was distributed to TestFlight users only.

---------------------------------------------------------------------------

### 2.6.2 (GitHub commit a815fbb) 28-05-24

Maintenance
* Tested on iOS 17.5.1
* Enabled full Xcode concurrency checking. Required several code changes. In preparation of Swift 6.0.
* Cleaned up code around OrganizationType. That code contained a temporary hack.

This is build #4624 and was distributed to TestFlight users only.

---------------------------------------------------------------------------

### 2.6.2 (GitHub commit 4fe7568) 20-05-24

Who's Who screen
* Cleaned up usage notes at the bottom of the screen.

Documentation
* Cleaned up level 1 description of README.md file on Github.
* Removed section on Privacy (because sensitive info and associated encryption have been removed).

Maintenance
* Added Photo Club Bernheeze to the list (`root.level1.json`).
* Tested on MacOS 14,5 (23F79), Xcode 15.4 (15F31d), SwiftLint 0.55.1, iOS 17.5 and Vision Pro 1.2 beta 5 (21O5565d).
* Fixed a SwiftLint coding rule warning (function explicitly returning void).
* Removed encryption using `git-crypt`. Member list of FGW is now fetched directly (removed data like phone numbers).

This is build #4623 and was distributed to TestFlight users only.

---------------------------------------------------------------------------

### 2.6.1 (GitHub commit f4d89a9) 28-04-24

Who's Who screen
* Cleaned up vertical smart scrolling (scrolling stops on item boundaries)
* Display horizontal scroll indicator where applicable
* Always show birthday and URL info (to get fixed vertical view size)

Maintenance
* Removed (broken) external URL for Hans Zoete.

This is build #4622, was released via TestFlight, and was released as v2.6.1 on the App Store.

---------------------------------------------------------------------------

### 2.6.0 (GitHub commit fe447b0) 21-04-24

Who's Who screen
* Added vertical smart scrolling (scrolling stops on item boundaries)

Maintenance
* Major: the Fotogroep Waalre portfolios were no longer accessible. Fixed by regenerating them on my own server.
* Tested on Xcode 15.4 beta 1, iOS 17.5 beta 2 (21F5058e), visionOS 1.2 beta 2 (21O5565d)
* Fixed ability to directly build GitHub (FGWPrivateMemberURL2 was missing)

This is build #4621 and will be released (with build #4619 changes) as v2.6.0 via the Apple App Store.

---------------------------------------------------------------------------

### 2.5.7 (GitHub commit fcd8918) 7-04-24

Portfolio screen
* Delete caused app to terminate (bug) when deleting last member of a club (id).
* Changed the icon shown while loading an image. It's a tortoise, generated using AI (DiffusionBee))

Clubs and Museums screen
* Deleting a club or museum now works. Deleting a club removes all members, but leaves them on the Who's Who screen.
* Updated instructions in footer (delete-related).

Who's Who screen
* Captions are now below each image.
* Deletion of photographers was disabled in previous releases.
* Deleting a photographer automatically deletes all associated memberships (cascade).
* Updated instructions in footer (delete_related).
* Changed the icon shown while loading an image. It's a tortoise, generated using AI (DiffusionBee))

Documentation
* Documented swipe-to-delete in GitHub readme.

This is build #4619 and was distributed to TestFlight users only.

---------------------------------------------------------------------------
### 2.5.6 (GitHub commit 74a487d) 4-04-24

Readme screen
* Mentioned the Search Bar as one of the app's features (because it may be overlooked).

Who's Who screen
* Fixed layout bug (for photographers with a website link and multiple portfolios).
* Updated one of the thumbnails.
* More space between horizontal scrolling thumbnails.

Documentation
* Added the search bar to the EN and NL readme.pages files.
* Added the search bar to the GitHub README.md file.

Maintenance
* Renamed 2 source files used for WhoIsWho screen (for consistency with other views).
* Moved both Readme_XX_2_5_5.pages files to Documentation directory.
* Removed unneeded EN screenshots for readme. Reduces package size somewhat.
* Renamed OrganizationList.swift to RootLevel1JsonReader.swift (and updated some comment text).
* Renamed Photographer.photographerWebsite to website.
* Tested on the short-leved iOS/iPadOS 17.4.1 build 21E237

This is build #4618 and was released as v2.5.6 on the Apple App Store.

---------------------------------------------------------------------------
### 2.5.6 (GitHub commit b7f46f7) 31-03-24

Clubs and Museums screen
* Added a Search bar for filtering organizations on name and town (at top of screen).
* Shows stats at top of screen ("77 organizations", "2 organizations (of 77)"
* Disable deletion of a individual organizations because it deleted them all. Bug had no lasting impact.

Who's Who screen
* Shows stats that match stats of Clubs and Museums screen

Documentation
* Fixed a layout problem in the layout of `README.md` text on GitHub (`detail`/`summary`).
* Added screenshots of all screens to `README.md` text on GitHub.
* Improved documentation of JSON file formats in `README.md`
* Cleanup of `ReleaseNotes.md` (for better Markdown compliance)

Maintenance
* Renamed `OrganizationList.json` to `root.level1.json` (OrganizationList.json is still supported)
* Improved error message if `root.level1.json` file not found
* Renamed `memberList` field in `level1.json` files to `level2URL`
* Updated Level 2 (HTML) file for Fotogroep Waalre (GvdK)
* Added a Dutch photo club (FC Den Dungen)
* Cleaned up string translation issues
* Tested on MacOS 14.4.1

This is build #4617 and was sent out to Apple Testflight users only.

---------------------------------------------------------------------------
### 2.5.5 (GitHub commit cffe1e4) 20-03-24

Clubs and Museums screen
* Remarks can now be shown in any language (previously: just English and Dutch).

Maintenance
* Tested on iOS/iPadOS 17.4.1, MacOS 14.4, Xcode 14.3, VisionOS 1.1 beta 4.
* Added the Photo Elysée museum in Lausanne.
* Added two local photo clubs: Boxtel, De Fotoschouw.
* Added Dutch translations for remarks for all museums.
* Updated opening image of README on GitHub.

This is build #4616, and was submitted as release 2.5.5 on the Apple App Store.

---------------------------------------------------------------------------
### 2.5.4 (GitHub commit 769676c) 02-03-24

Readme screen
* Many changes to the English and Dutch versions of the built-in Readme text.
* Added description of how to add a photo club or museum to the app.
* Created a .pages version of English and Dutch Readme screen for reviewing.

Portfolios screen
* performance improvement: fewer calls to WkWebView(): from once per thumbnail to once per screen.

Who's Who screen
* performance improvement: fewer calls to WkWebView(): from once per thumbnail to once per screen.

Maintenance
* Tested with iOS 17.4 RC, MacOS 14.3, Xcode 14.3 RC, VisionOS 1.1 beta 4.
* Added Fotogroep Best as a Level 1 supported photo club.
* Fixed broken shields in GitHub README.md.
* Removed empty targets for testing and UI testing.
* Removed Version2Changes.md file (no longer being updated).

This is build #4615, and is available as release 2.5.4 on the Apple App Store.

---------------------------------------------------------------------------
### 2.5.3 (GitHub commit 83a9e0c) 12-02-24

Clubs and Museums screen
* Removed member count for photo museums and clubs with no available member data
* Show wikipedia URL for museums (clickable "W" icon if link is available). Data comes from JSON file.
* Added some Dutch translations.
* Removed support for kvkNumber. It worked, but is Netherlands only, and not very relevant.
* Clubs are shown before Museums.

Readme screen
* Significant text updates. Stored ReleaseNotesEN.pages in git repository.

Maintenance
* Renamed PhotoClub table to Organization table (because it can now contain museums)
* Replaced musea -> museums in English text.
* Tested with with iOS 17.4 beta 2, MacOS 14.3, Xcode 14.3 beta 2, VisionOS 1.1 beta
* Converted SwiftyJSON from package to file (as a temp workaround)
* Added basic info about dozens of nearby photo clubs (as an example, and for screenshots)
* Removed image property in OrganizationList.json. User can see an image of the building via the Wikipedia link.
* fgDeGender has a new chairman. This info doesn't come from a json file yet.
* Refreshed screenshots on Apple App Store

This is build #4614, and was published on the Apple App Store (with the changes in build #4613)

---------------------------------------------------------------------------
### 2.5.3 (GitHub commit 02e860a) 19-01-24

Clubs and Museums screen
* Renamed screen from `Photo Clubs` to `Clubs` to save space (for future mode picker).
* Maps can display various photography museums (example: there are three in Manhattan, NYC).
* Additional photo clubs (and museums) are loaded from a data file (OrganizationList.json hosted on GitHub).
* A photoclub's (or museum)'s country is determined from its GPS coordinates. This handles localization: "Frankrijk" (NL) = "France" (EN).
* Town names are also translated if applicable: "Den Haag" (NL) = "The Hague" (EN).
* No footnote anymore about pull-to-refresh.
* Museums are rendered on maps using a special marker pin.
* Top of screen shows how long the list is (e.g. "25 items").
* Single line remark can be provided per club/museum. That text is localized if the translation is available.

Portfolios screen
* Name of towns are now shown in the correct language.
* Limited the font size of the footers in case the device's text display size was increased (in Settings).
* Removed the 3 Test Fotoclubs. They are now shown correctly as museums.

Readme screen
* Significant text updates and added new pictures. Removed section on data model. It's on GitHub readme.

Maintenance
* Tested with with iOS 17.2.1, MacOS 14.2.1, GitCrypt 0.7.0.1, Xcode 14.2
* Centralized code for loading and of input data (file: `PhotoClubHubApp`).
* Updated data model picture in GitHub README.md file.
* .xcloc localization files are no longer included in the Photo Club Hub target (not used in bundle).

This is build #4613, and was sent out to Apple Testflight users only.

---------------------------------------------------------------------------
### 2.5.2 (GitHub commit 7cc0780) 16-12-23

Photo Clubs screen
* User location is shown on map when user presses a new MapUserLocationButton() control.
* Map controls are hidden when map is locked. In version 2.5.0 they were disabled, but not hidden.

Maintenance
* Tested with with iOS 17.2, MacOS 14.2, Xcode 14.1, and swiftlint 0.53.0 (there are issues with 0.54.0).
* Updated GitHub README.md and portfolios.jpg screenshot.
* Updated status of BdG and PvdH within FG de Gender
* Corrected URL Fotomuseum Den Haag
* Fixed compiler warning about compound uniqueness constraint not being SwiftData compatible (yet?)
* Added package dependency for SwiftyJSon 5.0.1
* Localized NSLocationWhenInUseUsageDescription from EN to NL
* Renamed source directories and file names named "Fotogroep Waalre" (old app name)

This is build #4610 in Apple's App Store.

---------------------------------------------------------------------------
### 2.5.1 (GitHub commit 51501f7) 22-11-23

Photo Clubs screen
* Added Fotogroep Anders (Eindhoven), Bellus Imago (partial), and Fotogroep de Gender (partial).
* Bug fix: the 2nd map from top could initially be displayed at default coordinates (lots of ocean blue).
* Maps have a few new features like rotate, 3D, compas, and scale. For some you need to zoom in. For compas you need to rotate. 
* Markers on map show a camera icon.
* Markers on the map show name of the club if you select them (touch).
* Minor layout changes.

Readme screen
* Removed deprecated text about ability to vote for Roadmap features (has been disabled for a while).
* Fixed text that now iOS 17.0 (rather than 16.4) is required,

Maintenance
* Replaced deprecated API Map calls by newer SwiftUI MapKit equivalent. This fixed 3 compiler warnings.
* Tested with MacOS 14.1.1, Xcode 15.1 Beta 3 and iOS 17.1.1.
* Completed English list of localizable strings (also for cases where no translation is necessary).
* Set ITSAppUsesNonExemptEncryption to false in info.plist (to automate answer to question during releasing).
    
This is build #4608 in Apple's App Store.

---------------------------------------------------------------------------
### 2.5.0 (GitHub commit beafb53) 3-11-23

Portfolios screen
* Minor design changes (e.g. separator lines, footer text).
* Club names like "Photo Club Waalre (Waalre)" are now displayed as "Photo Club Waalre".

Photo Clubs screen
* Added Fotogroep De Gender (with a single test member) for testing. Drag down Photo Clubs screen to load this data.

Who's Who screen
* Shows high-resolution image per club a photographer is associated with.
* Each image has an overlay caption explaining how the photographer is associated with that club.
* Clicking on one of these images brings you to the complete set of images in that Portfolio.
* Club names like "Photo Club Waalre (Waalre)" are now displayed as "Photo Club Waalre".

Maintenance
* Requires iOS 17.0 or higher.
* Cleaned up logging and passing of PersonName structs.
* Upgraded and tested with MacOS 14.1, Xcode 15.1 Beta 2 and iOS 17.1.
    
This is build #4603 in Apple's App Store.

---------------------------------------------------------------------------
### 2.4.2 (GitHub commit 3548647) 13-09-23

Portfolio screen
* Fixed bug where users were incorrectly labelled "former member". This release is to fix this bug.

Readme screen
* Fixed a typo in Dutch language version

Maintenance
* Upgraded and tested with MacOS 13.5.2, SwiftLint 0.52.4, Xcode 15.0 RC1
    
This is build #4596 in Apple's App Store.

---------------------------------------------------------------------------
### 2.4.1 (GitHub commit 2ee61a1) 9-09-23

Portfolio screen
* Added a 2nd admin for FGWaalre

Who's Who screen
* Display name in "familyName, givenName infixName" format.
* Supports Dutch convention of sorting names like "Jan van Doesburg" under the D (Doesburg) rather than the V (van).
* A trick to avoid a mix between the old and new member name formats when migrating data from older releases.

Maintenance
* Updated screenshot used on GitHub readme
* Changed sorting of photo clugs from `priority: Int` to `pinned: Bool`.
* Upgraded and tested with iOS 17.0 beta 8 (21A5325a), XCode 14.0 beta 8.
* Replaced NSSortDescriptor by newer SortDescriptor (in ViewModel files).
* Renamed PhotogroepWaalreApp.swift file.
* Updated documentation on GitHub README.md to cover concurrency approach.
* Changed the name of the CoreData model to reflect the name change of the app.

This is build #4594 in Apple's App Store.

---------------------------------------------------------------------------
### 2.4.0 (GitHub commit 276c9f3) 4-08-23

This is build #4593 in Apple's App Store
* Bumped version number to 2.4.0 because of the new app name.

Prelude screen
* Adapted logo to new app name, Photo Club Hub.

Portfolio screen
* Replaced images for former FGWaalre coach Theo van Waas
* Moved Bettina from member to ex-member of FGWaalre

Readme screen
* Changed app icon as shown in Readme screen and iOS home screen

Concurrency
* Used com.apple.CoreData.concurrencyDebug = 1 to find concurrence errors around Core Data
* All photoclub data is fetched on a background thread
* Fetching info about thumbnails moved from foreground to background thread

Maintenance
* Upgraded and tested with iOS 17.0 beta 4 (21A5291g), XCode 14.0 beta 5, Swift 5.9 and SwiftLint 0.52.3
* Removed fatalError() wherever possible from shipping code
* Changed GPS coordinates of Test Photo Club Rotterdam (the museum plans to move)
* Cleanup of model (schema) versions
    
In Apple's App Store, the release notes of 2.3.6 and 2.4.0 are combined.*

---------------------------------------------------------------------------
### 2.3.6 (GitHub commit 4ccc917) 21-06-23

This is build #4591, which was _not_ released in Apple's App Store

* Changed user-visible app name to Photo Club Hub (NL: Fotoclub Hub)

Settings screen
* By default "Former members" are now shown. The user can change this behavior in the Preferences screen.

Readme screen
* Textual changes and a new figure

Maintenance
* Upgraded and tested with iOS 17.0 beta 1 (21A5248u), XCode 14.0 beta 1, Swift 5.9
* Temporarily set new ENABLE_USER_SCRIPT_SANDBOXING = NO (swiftlint reading non-swift files)
* Reduced priority of Fotogroepw Waalre from 3 to 1 to ensure basic alphabetical order
---------------------------------------------------------------------------
### 2.3.5 (GitHub commit 62a54b7) 30-05-23

Photo Clubs screen
* Displays a help message in the (rare) case that there are zero clubs loaded

Roadmap screen
* Disabled the Roadmap Screen because the underlying third-party countAPI service is currently down

Readme screen
* preview of coming name change for the app

Maintenance
* Removed fopen() warnings when Metal initializes the first time the app is run
* Changed URL from vdhamer.com to www.vdhamer.com (invisible to user)
* Upgraded and tested with iOS 16.5, MacOS 13.4, XCode 13.4.1 RC, Swift 5.8.1 and SwiftLint 0.52.2
    
This is build #4590 in Apple's App Store.

---------------------------------------------------------------------------
### 2.3.4 (GitHub commit 5c3e710) 02-04-23

Readme screen
* Roadmap voting screen `Search` function now searches descriptions (new) and titles
* therefore, temporarily, using vdhamer/Roadmap package fork instead of /AvdLee/Roadmap
* repositioned multi-language image within Readme screen text

Maintenance
* Built/tested using XCode 14.3, Swift 5.8, iOS 16.4, and SwiftLint 0.51
* Build now requires iOS 16.4. Removed `if #available(iOS 16.4, *)` in two places in code.
* Cleaned all references to Preferences screen (was a mix of Settings and Preferences)
* Removed minor unused `anythingVisible` computed property.

This is build #4589 in Apple's App Store.
In Apple's App Store, the release notes of 2.3.3 and 2.3.4 are combined.

---------------------------------------------------------------------------
### 2.3.3 (GitHub commit 26092a4) 25-03-23

Readme screen
* Bug fix: colors of status field of Roadmap items didn't get triggered in Dutch translation
* Updated the Readme text
* Added "MacOS support" to the Roadmap questionnaire

Maintenance
* Disabled support (in App store) for running the iPad version on MacOS (because Photo Clubs screen crashed)
* Fixed bug in AvdLee/Roadmap related to `statusTintColor` when status strings are localized 
* Built using XCode 14.3 RC and tested with iOS 16.4 RC
* Removed WebView.swift (dead code)
* Disabled support for running the iPad version on MacOS (because Maps crashed in Photo Clubs screen)

This is build #4588 (didn't make it to Apple's App Store)

---------------------------------------------------------------------------
### 2.3.2 (GitHub commit ef445ca) 19-03-23

Readme screen
* User can vote on possible enhancements within the app (Readme > Features and tips > Vote on roadmap items)
* Fixed section header layout on iPad

Maintenance
* Required iOS version is now 16.2 (was 16.0)
* Disabled support for running the iPad version on MacOS (because Maps crashed in Photo Clubs screen)
* Added Roadmap package
* Updated GitHub README and associated screenshot for GitHub
* Tested against XCode 14.3 beta 3

This is build #4587 in Apple's App Store.

---------------------------------------------------------------------------
### 2.3.1 (GitHub commit 1793262) 05-03-23

Portfolios screen
* Section headers on Portfolios page are now gray to attract less attention

Readme screen
* Removed Done button

Preferences screen
* Removed Done button

Maintenance
* Tested against XCode 14.3 beta 2 and Swift 5.8
* Fixed text localization issue
* Improved Readme.md text on GitHub

This is build #4586 in Apple's App Store.
In Apple's App Store, the release notes of 2.3.0 and 2.3.1 are combined.

---------------------------------------------------------------------------
### 2.3.0 (GitHub commit 8d35bd6) 02-03-23

Portfolios screen
* List of portfolios is now grouped into sections, each representing a different photo club.
* Increased font size of photographer's name
* Show data source per photo club (in section footer)
* Loads 3 dummy photo clubs (named start with Test) at startup to demonstrate multi-club support.

Photo Clubs screen
* Removed section header (it was redundant)

Who's Who screen
* Temporarily added count of names at top of screen

Readme screen
* Converted to `bottom sheet`

Preferences screen
* Converted to `bottom sheet`

Maintenance
* Tested against XCode 14.3 beta 1
* Updated GitHub README file
* FGWPrivateMembersURL? files point to different site (and temporarily use http)
* "?" is now a supported placeholder when birthdate is unknown

This is build #4585 (didn't make it to Apple's App Store).

---------------------------------------------------------------------------
### 2.2.10 (GitHub commit 09212fb) 06-02-23

Photo Clubs screen
* Fixed bug w.r.t. dark mode.
* Replaced "Number of photo clubs displayed at top of screen" by...
* Photo club name displayed as section header

This is build #4583 in Apple's App Store.
In Apple's App Store, the release notes of 2.2.10 and 2.2.9 are combined.

---------------------------------------------------------------------------
### 2.2.9 (GitHub commit 21a6cd6) 05-02-23

Portfolios screen
* Small layout change to scrolling list (saves some horizontal space).
* Number of portfolios displayed at top of screen.

Photo Clubs screen
* Small layout change to scrolling list.
* Number of photo clubs displayed at top of screen.
* Updated the text at the botton of the screen.
* Fixed bug when multiple photo clubs have same name (locks were not independent).
* Made lock settings persistent.
* Added an extra Test photo club (Test Club, in The Hague, NL)

Maintenance
* Tested on iOS/iPadOS 16.3.
* Updated .gitignore file.

This is build #4582 (didn't make to Apple's App Store).

---------------------------------------------------------------------------
### 2.2.8 (GitHub commit 426c09c) 22-01-23

Portfolios screen
* Changed misleading wording of a Dutch text (shown when the returned Portfolio list is empty).

Photo Clubs screen
* Software can now support multiple photo clubs that share the same name but are in a different town.
* There is now a 4th photo club to test/demo this (drag-down-to-refresh in Photo Clubs screen).

Individual Portfolio screens
* Portfolio title now includes name of the corresponding photo club (`photographer` @ `club>`).

Documentation
* Cleaned up the GitHub README.md by adding collapsible text blocks (HTML `summary`, `details`).

Maintainability
* Added a PhotoClubID struct.
* Hardcoded photographer info can now contain photograperWebsite URL.

This is build #4581 in Apple's App Store.

---------------------------------------------------------------------------
### 2.2.7 (GitHub commit 0130c45) 01-01-23

Portfolios screen
* Thumbnails are now shown for former members (etc).
* Thumbnails fetch thumbnail versions of the images (instead of the larger images themselves).
* Thumbnails automatically show the latest image per portfolio (based on latest capture date).
* Spinning progress indicator while waiting for thumbnail response.

Maintainability
* Thumbnails are now read from a config.xml file per portfolio (instead of being hardcoded).
* Used Swift 5.7 Regex Builder (introduced in iOS 16, replacing older Regex api).
* Made parsing of the Fotogroep Waalre membership HTML file more robust.
* Logging message cleanup. Focus on which photo club. And ERROR in caps.

This is build #4580 in Apple's App Store.

---------------------------------------------------------------------------
### 2.2.6 (GitHub commit e763662) 25-12-22

* Adapted for iOS 16.2, Swift 5.7, XCode 14.2,  and SwiftLint 0.50.3
* Converted to NavigationStack and replaced deprecated NavigationLink (new in iOS 16)

Prelude screen (formerly known as Animation screen)
* on iPad and large iPhones: user can return to Prelude screen from Portfolios screen via nav bar
* if you press outside the central image, there is a brief flash to confirm the Button press
* debug features available on devices with a keyboard (such as iPad with Magic Keyboard)
* pressing "d" toggles a debug panel with coordinates of last tap on central image
* pressing "c" toggles crosshairs to identify indicate exact location of center of screen

This is build #4579 in Apple's App Store.

---------------------------------------------------------------------------
### 2.2.5 (GitHub commit 6f40286) 10-12-22

Who's who screen
* Extract date of birth from (extended) membership file for FGW instead of hardcoding this data
* Birthdays are now also shown for former members
* Renamed corresponding SwiftUI `view` to `WhoIsWho` to match screen label in UI

Portfolios screen
* Changed vice-chairman status for Fotogroep Waalre (for now GvS)

Refactoring
* Improved robustness of HTML parsing in FGWMembersProvider class
* Split file FGWMemberProvider into 2 files to make SwiftLint happy
* Extra param called `okToUseEncryptedFile` in `getFileAsString()`  for testing purposes
* Deleted unused source control branches

This is build #4578 in Apple's App Store.

---------------------------------------------------------------------------
### 2.2.4 (GitHub commit 15c87ab) 2-12-22

* Updated README.md file (mainly architecture topics)

Portfolios screen
* Changed vice-chairman status for Fotogroep Waalre (BdG)
* Updated hardcoded thumbnails uses various Expo2022 images

Refactoring
* Minor: tweaked capitalization of titles
* Upgraded to SwiftLint 0.50.1
* Removed file DeviceOwnership.swift (it was not part of the build, but SwiftLint was checking it)

This is build #4577 in Apple's App Store.

---------------------------------------------------------------------------
### 2.2.3 (GitHub commit 9d1dfed) 23-10-22

Release notes for 2.2.3 also contain 2.2.2 release notes

Portfolios screen
* Yellow question mark is no longer used (replaced by orange question mark stored internally) 

This is build #4576 in Apple's App Store.

---------------------------------------------------------------------------
### 2.2.2 (GitHub commit 2462bf9) 23-10-22

Photo Clubs screen
* Switched from MapPin to MapMarker on map (MapPin deprecated in iOS16)
* Adapted icon representing photo clubs to match MapMarker

Portfolios screen
* Changed one image thumbnail (for CK)

Who's Who screen
* Cixed incorrect admin role of one member (CK)

Refactoring
* Renamed TestClubMembersProvider class
* Added comments on club loading in Fotogroep_Waalre_App
* Renamed insertSomeHardcodedMemberData() method
* Renamed latestImageURL in database and struct
* Converted WhatNew.txt to ReleaseNotes.md
* Built with Xcode 14.1

This is build #4575 that didn't end up in Apple's App Store (forgot to merge a branch).

---------------------------------------------------------------------------
### 2.2.1 (GitHub commit 71b3b84) 09-10-22

Preferences screen
* Bug fix (iPad only): incorrect attachment point at top of screen. Cosmetic flaw.
* Readme screen
* Bug fix (iPad only): incorrect attachment point at top of screen. Cosmetic flaw.

This is build #4574 in Apple's App Store.

-------------------------------------------------------------------------
### 2.2.0 (GitHub commit c9f0d16) 08-10-22

* Minimum required iOS version is now 16.0 (16.0 is available for iPhone, 16.x is expected soon for iPad).

Portfolios screen
* Displays a (temp hardcoded) thumbnail image per portfolio for all current members of the FGW club
* Increased font size (on iPad only) within the Portfolio list.
* If no recent image is available yet (e.g. ex-members), a stylised question mark is shown.
* While downloading the thumbnail, a sketch of an anxious-looking snail is shown (only visible if download takes a while).
* Incidentally, both the question-mark and the snail were generated using Stable Diffusion text-to-image software.
* The App Store videos and screenshots have been updated to reflect the new thumbnails.
* Changed vice-chairmanship for Fotogroep Waalre.

Photo Clubs screen
* Swipe-left to delete an unneeded photo club (usually not needed). FGW can be deleted, but will reappears on restart.
* Added a brief explanation at the bottom of the screen (about swiping and more).
* Renamed "Test Photo Club" (was "Nederlands Fotografie Museum", which is simply not a photo club).

Who's Who screen
* Extended list of birthdays (still hardcoded) to cover all current members of FGW.

Preferences screen
* Minor text change (single to double quotes)

This is build #4573 (but it was rejected Apple's App Store because the screenshots showed device bezels).

---------------------------------------------------------------------------
### 2.1.1 (GitHub commit 4974461) 11-09-22

Bug fix
* Immediate crash running GitHub version (due to file name error). No impact on App Store version.

Refactoring
* Renamed a CoreData table from Member to MemberPortfolio
* Renamed various SwiftUI views (e.g. MemberListView > MemberPortfolioView)
* Upgraded to XCode 14 and swiftlint 0.49.1
* SwiftUI previews
* Now all Previews of all Views work again

This is build #4381 in Apple's App Store.

---------------------------------------------------------------------------
### 2.1.0 (GitHub commit a658b52) 17-08-22

* Minimum required iOS version is 15.5

GitHub support
* Source code is publically available on [GitHub](https://GitHub.com/vdhamer/PhotoClubWaalre)
* Mechanism to secure some data of photo club members (GitHub related)
* New README.md for GitHub web site (it is not included in or used by the App itself)

Robustness
* added an extra save() when app goes to background state
* Linked loading of Fotogroep Waalre data to .onAppear of first view
* Disabled autocorrection on Search text
* removed unneeded SwiftUIEnvirontValue.png graphic from build
* Removed dedicated accessibility feature for one specific user
* Added .mp4 "App Preview" video to App Store

This is build #4379 in Apple's App Store.

---------------------------------------------------------------------------
### 2.0.10 (not on GitHub) 1-06-22

* Fixed bug regarding updating of version/build info in iOS Settings (build script -> startup code)

Preferences screen
* added checking on Done button
* added animation and sound to 2 toggles.
* Minor text changes

This is build #4303 in Apple's App Store.

---------------------------------------------------------------------------
### 2.0.9 (not on GitHub) 23-05-22

* Many text changes in embedded Dutch language ReadMe (and a few to the English version)

Animimation screen
* Return, Esc and Space keys all dismiss the Prelude screen (if you have a keyboard attached)
* Used @EnvironmentObject to distribute deviceOwnership

This is build #4299 in Apple's App Store/

---------------------------------------------------------------------------
### 2.0.8 (not on GitHub) 09-05-22

Preferences screen
* simplified Preferences page, while adding toggle to show club officers
* bug fix: sort oder on Photographers page was reversed
* various minor user interface improvements
* app has been tested on an M1 Mac

Portfolio screen
* introduced the term "portfolio" in the User Interface and Readme page

Who's who screen
* renamed the "Photographer" page to "Who's who" and "About" page to "Readme"
* numerous text changes to Dutch and English versions of the Readme page
* dark mode version of app icon

This is build #4298 in Apple's App Store.

---------------------------------------------------------------------------
### 2.0.7 (not on GitHub) 01-05-22

Preferences screen
* fixed: "former members" no longer includes external coaches

Portfolios screen (called Members at the time)
* text "Members" didn't fit in navigation view when scrolling upwards
* iPad only: shifted location of search field on Members page

Prelude screen
* more precise alignment of logo in Opening page
* minimized chance of user getting stuck in the opening Prelude screen
* Photo clubs screen
* changed order of photo clubs

Readme screen
* rewritten Readme page and added a Dutch language version
* added scroll bar to the Readme page (it's fairly long)

This is build #4294 in Apple's App Store.

---------------------------------------------------------------------------
### 2.0.6 (not on GitHub) 03-04-22

* fixed top layout of Readme page on iPhones
* new [i] button and Readme page
* extended the list of items under Preferences
* user can decide to show or hide current members via the Preferences page
* Member page can show warnings/tips if the page is empty or contains duplicate names
* animation of lock icon on Photo Clubs page (with sound)
* other minor user interface improvements: smaller click target for photo club URL, Done button, "Current members", "incl."
* prevented largest DynamicType setting from causing WAALRE to wrap in Prelude animation

This is build #3982 in Apple's App Store.

---------------------------------------------------------------------------
### 2.0.5 (not on GitHub) 24-03-22

* made opening Prelude screen more interactive
* higher resolution version of opening image
* minor user interface improvements: icon for Preferences, URL for photo clubs
* scrolling and panning of maps can be locked by toggling a lock/unlock icon

This is build #3976 in Apple's App Store.

---------------------------------------------------------------------------
### 2.0.4 (not on GitHub) 13-03-22

* changed membership status icons and various other user interface improvements
* new opening Prelude screen showing App icon morphing into Bayer color filter array
* internal improvements: handling of special colors
* updated App Store screenshots (to do)

This is build #3974 in Apple's App Store.

---------------------------------------------------------------------------
### 2.0.3 (not on GitHub) 29-01-22

* new Search feature to search the lists of names
* the web addresses of club-external websites are now displayed (when the info is available)
* minor user interface improvements: Preferences page size, lilac theme color for Photo Clubs
* added club-internal websites for two persons as demo within the Easter egg
* internal improvements: SwiftUI previews, full set of localization comments, colors stored in Assets
* internal: removed test code for non-existent photo club "Old Vic" in Reykjavík

This is build #3966 in Apple's App Store.

---------------------------------------------------------------------------
### 2.0.2 (not on GitHub) 20-01-22

* map supports panning.
* user interface refinements in icons and colors.
* highlights a person's name if app "guesses" this may be the device owner (based on device's name).
* bug fix: deceased members were not displayable (even with Preferences toggle set).
* Easter egg: pull-to-refresh the map page for basic demo of multi-club support. Swipe individual members left to delete.
* iOS Settings app now displays version and copyright information of the Photo Club Waalre app.
* App Store: fixed issue with some screenshots still showing the old version 1.x
* Internal improvements: schema migration (like firstName_ to givenName_).
* And member roles converted to enums for robustness.

This is build #3956 in Apple's App Store.

---------------------------------------------------------------------------
### 2.0.1 (not on GitHub) 09-01-22

* Minor: moved documentation files out of target / bundle.
* Minor: changed accent colors in all List sections. Causes .accentcolor to turn gray when a page loses focus.
* Stopped showing URLs in website
* App name localized to system level preferences (but not to app-level preference)
* switched to using WKWebView to run JavaScipt-based website. Uses NavigationLink instead of Link.
* icons show role of members (instead of first letter) in Members screen
* moved lists of members / photoclubs / photographers to separate pages
* added entitlement for app background fetches (not working?)
* display home location of any supported photo club (with surrounding photo clubs) on a map
* added icons to Preferences popup
* added 3000 to build number to allow shipping as Fotogroep Waalre bundel

This is build #3566 in Apple's App Store.

---------------------------------------------------------------------------
### 2.0.0 (not on GitHub) 01-01-22

* First version using SwiftUI and CoreData.
* First version designed to support more than one photo club.

This is build #31, but it didn't reach Apple's' App Store, because app was too website-like.

---------------------------------------------------------------------------
