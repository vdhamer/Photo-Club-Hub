### 2.4.0 (Github commit ???????) ??-07-23

This is build #4593 in Apple's App Store
    * Bumped version number to 2.4.0 because of the new app name
    * Updated app icon (using only one 1024x1024 image)
Prelude screen
    * Adapted logo to new app name, Photo Club Hub
Roadmap screen
    * Re-enabled the Roadmap Screen (with some related changes)
Readme screen
    * Changed app icon as shown in readme and on iOS home screen
Maintenance
    * Upgraded and tested with iOS 17.0 beta 3 (21A5268h), XCode 14.0 beta 3, Swift 5.9 and SwiftLint 0.52.3
    * turned on CoreData debugging for Run schema (https://useyourloaf.com/blog/debugging-core-data/)
    * Removed fatalError() wherever possible from shipping code
    
*In Apple's App Store, the release notes of 2.3.6 and 2.4.0 are combined.*
---------------------------------------------------------------------------
### 2.3.6 (Github commit 4ccc917) 21-06-23

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
### 2.3.5 (Github commit 62a54b7) 30-05-23

This is build #4590 in Apple's App Store
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
---------------------------------------------------------------------------
### 2.3.4 (Github commit 5c3e710) 02-04-23

This is build #4589 in Apple's App Store
Readme screen
    * Roadmap voting screen `Search` function now searches descriptions (new) and titles
    * therefore, temporarily, using vdhamer/Roadmap package fork instead of /AvdLee/Roadmap
    * repositioned multi-language image within Readme screen text
Maintenance
    * Built/tested using XCode 14.3, Swift 5.8, iOS 16.4, and SwiftLint 0.51
    * Build now requires iOS 16.4. Removed `if #available(iOS 16.4, *)` in two places in code.
    * Cleaned all references to Preferences screen (was a mix of Settings and Preferences)
    * Removed minor unused `anythingVisible` computed property.

*In Apple's App Store, the release notes of 2.3.3 and 2.3.4 are combined.*
---------------------------------------------------------------------------
### 2.3.3 (Github commit 26092a4) 25-03-23

This is build #4588 (didn't make it to Apple's App Store)
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
---------------------------------------------------------------------------
### 2.3.2 (Github commit ef445ca) 19-03-23

This is build #4587 in Apple's App Store
Readme screen
    * User can vote on possible enhancements within the app (Readme > Features and tips > Vote on roadmap items)
    * Fixed section header layout on iPad
Maintenance
    * Required iOS version is now 16.2 (was 16.0)
    * Disabled support for running the iPad version on MacOS (because Maps crashed in Photo Clubs screen)
    * Added Roadmap package
    * Updated Github README and associated screenshot for Github
    * Tested against XCode 14.3 beta 3
---------------------------------------------------------------------------
### 2.3.1 (Github commit 1793262) 05-03-23

This is build #4586 in Apple's App Store
Portfolios screen
    * Section headers on Portfolios page are now gray to attract less attention
Readme screen
    * Removed Done button
Preferences screen
    * Removed Done button
Maintenance
    * Tested against XCode 14.3 beta 2 and Swift 5.8
    * Fixed text localization issue
    * Improved Readme.md text on Github

*In Apple's App Store, the release notes of 2.3.0 and 2.3.1 are combined.*
---------------------------------------------------------------------------
### 2.3.0 (Github commit 8d35bd6) 02-03-23

This is build #4585 (didn't make it to Apple's App Store)
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
    * Updated github README file
    * FGWPrivateMembersURL? files point to different site (and temporarily use http)
    * "?" is now a supported placeholder when birthdate is unknown
---------------------------------------------------------------------------
### 2.2.10 (Github commit 09212fb) 06-02-23

This is build #4583 in Apple's App Store
Photo Clubs screen
    * Fixed bug w.r.t. dark mode.
    * Replaced "Number of photo clubs displayed at top of screen" by...
    * Photo club name displayed as section header

*In Apple's App Store, the release notes of 2.2.10 and 2.2.9 are combined.*
---------------------------------------------------------------------------
### 2.2.9 (Github commit 21a6cd6) 05-02-23

This is build #4582 (didn't make to Apple's App Store)
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
---------------------------------------------------------------------------
### 2.2.8 (Github commit 426c09c) 22-01-23

This is build #4581 in Apple's App Store
* Portfolios screen
    * Changed misleading wording of a Dutch text (shown when the returned Portfolio list is empty).
* Photo Clubs screen
    * Software can now support multiple photo clubs that share the same name but are in a different town.
    * There is now a 4th photo club to test/demo this (drag-down-to-refresh in Photo Clubs screen).
* Individual Portfolio screens
    * Portfolio title now includes name of the corresponding photo club (`photographer` @ `club>`).
* Documentation
    * Cleaned up the GitHub README.md by adding collapsible text blocks (HTML `summary`, `details`).
* Maintainability
    * Added a PhotoClubID struct.
    * Hardcoded photographer info can now contain photograperWebsite URL.
---------------------------------------------------------------------------
### 2.2.7 (Github commit 0130c45) 01-01-23

This is build #4580 in Apple's App Store
* Portfolios screen
    * Thumbnails are now shown for former members (etc).
    * Thumbnails fetch thumbnail versions of the images (instead of the larger images themselves).
    * Thumbnails automatically show the latest image per portfolio (based on latest capture date).
    * Spinning progress indicator while waiting for thumbnail response.
* Maintainability
    * Thumbnails are now read from a config.xml file per portfolio (instead of being hardcoded).
    * Used Swift 5.7 Regex Builder (introduced in iOS 16, replacing older Regex api).
    * Made parsing of the Fotogroep Waalre membership HTML file more robust.
    * Logging message cleanup. Focus on which photo club. And ERROR in caps.
---------------------------------------------------------------------------
### 2.2.6 (Github commit e763662) 25-12-22

This is build #4579 in Apple's App Store
* Adapted for iOS 16.2, Swift 5.7, XCode 14.2,  and SwiftLint 0.50.3
    * Converted to NavigationStack and replaced deprecated NavigationLink (new in iOS 16)
* Prelude screen (formerly known as Animation screen)
    * on iPad and large iPhones: user can return to Prelude screen from Portfolios screen via nav bar
    * if you press outside the central image, there is a brief flash to confirm the Button press
    * debug features available on devices with a keyboard (such as iPad with Magic Keyboard)
        * pressing "d" toggles a debug panel with coordinates of last tap on central image
        * pressing "c" toggles crosshairs to identify indicate exact location of center of screen
---------------------------------------------------------------------------
### 2.2.5 (Github commit 6f40286) 10-12-22

This is build #4578 in Apple's App Store
* Who's who screen
    * Extract date of birth from (extended) membership file for FGW instead of hardcoding this data
    * Birthdays are now also shown for former members
    * Renamed corresponding SwiftUI `view` to `WhoIsWho` to match screen label in UI
* Portfolios screen
    * Changed vice-chairman status for Fotogroep Waalre (for now GvS)
* Refactoring
    * Improved robustness of HTML parsing in FGWMembersProvider class
    * Split file FGWMemberProvider into 2 files to make SwiftLint happy
    * Extra param called `okToUseEncryptedFile` in `getFileAsString()`  for testing purposes
    * Deleted unused source control branches
---------------------------------------------------------------------------
### 2.2.4 (Github commit 15c87ab) 2-12-22

This is build #4577 in Apple's App Store
* Updated README.md file (mainly architecture topics)
* Portfolios screen
    * Changed vice-chairman status for Fotogroep Waalre (BdG)
    * Updated hardcoded thumbnails uses various Expo2022 images
* Refactoring
    * Minor: tweaked capitalization of titles
    * Upgraded to SwiftLint 0.50.1
    * Removed file DeviceOwnership.swift (it was not part of the build, but SwiftLint was checking it)
---------------------------------------------------------------------------
### 2.2.3 (Github commit 9d1dfed) 23-10-22

This is build #4576 in Apple's App Store
Release notes for 2.2.3 also contain 2.2.2 release notes
* Portfolios screen
    * Yellow question mark is no longer used (replaced by orange question mark stored internally) 
---------------------------------------------------------------------------
### 2.2.2 (Github commit 2462bf9) 23-10-22

This is build #4575 that didn't end up in Apple's App Store (forgot to merge a branch)
* Photo Clubs screen
    * Switched from MapPin to MapMarker on map (MapPin deprecated in iOS16)
    * Adapted icon representing photo clubs to match MapMarker
* Portfolios screen
    * Changed one image thumbnail (for CK)
* Who's Who screen
    * Cixed incorrect admin role of one member (CK)
* Refactoring
    * Renamed TestClubMembersProvider class
    * Added comments on club loading in Fotogroep_Waalre_App
    * Renamed insertSomeHardcodedMemberData() method
    * Renamed latestImageURL in database and struct
    * Converted WhatNew.txt to ReleaseNotes.md
    * Built with Xcode 14.1
---------------------------------------------------------------------------
### 2.2.1 (Github commit 71b3b84) 09-10-22

This is build 4574 in Apple's App Store
* Preferences screen
    * Bug fix (iPad only): incorrect attachment point at top of screen. Cosmetic flaw.
* Readme screen
    * Bug fix (iPad only): incorrect attachment point at top of screen. Cosmetic flaw.
---------------------------------------------------------------------------
### 2.2.0 (Github commit c9f0d16) 08-10-22

This is build 4573 (but it was rejected Apple's App Store because the screenshots showed device bezels)
* Minimum required iOS version is now 16.0 (16.0 is available for iPhone, 16.x is expected soon for iPad).
* Portfolios screen
    * Displays a (temp hardcoded) thumbnail image per portfolio for all current members of the FGW club
    * Increased font size (on iPad only) within the Portfolio list.
    * If no recent image is available yet (e.g. ex-members), a stylised question mark is shown.
    * While downloading the thumbnail, a sketch of an anxious-looking snail is shown (only visible if download takes a while).
    * Incidentally, both the question-mark and the snail were generated using Stable Diffusion text-to-image software.
    * The App Store videos and screenshots have been updated to reflect the new thumbnails.
    * Changed vice-chairmanship for Fotogroep Waalre.
* Photo Clubs screen
    * Swipe-left to delete an unneeded photo club (usually not needed). FGW can be deleted, but will reappears on restart.
    * Added a brief explanation at the bottom of the screen (about swiping and more).
    * Renamed "Test Photo Club" (was "Nederlands Fotografie Museum", which is simply not a photo club).
* Who's Who screen
    * Extended list of birthdays (still hardcoded) to cover all current members of FGW.
* Preferences screen
    * Minor text change (single to double quotes)
---------------------------------------------------------------------------
### 2.1.1 (Github commit 4974461) 11-09-22

This is build 4381 in Apple's App Store
* Bug fix
    * Immediate crash running Github version (due to file name error). No impact on App Store version.
* Refactoring
    * Renamed a CoreData table from Member to MemberPortfolio
    * Renamed various SwiftUI views (e.g. MemberListView > MemberPortfolioView)
    * Upgraded to XCode 14 and swiftlint 0.49.1
* SwiftUI previews
    * Now all Previews of all Views work again
---------------------------------------------------------------------------
### 2.1.0 (Github commit a658b52) 17-08-22

This is build 4379 in Apple's App Store
* Minimum required iOS version is 15.5
* Github support
    * Source code is publically available on [Github](https://github.com/vdhamer/PhotoClubWaalre)
    * Mechanism to secure some data of photo club members (GitHub related)
    * New README.md for GitHub web site (it is not included in or used by the App itself)
* Robustness
    * added an extra save() when app goes to background state
    * Linked loading of Fotogroep Waalre data to .onAppear of first view
    * Disabled autocorrection on Search text
    * removed unneeded SwiftUIEnvirontValue.png graphic from build
* Removed dedicated accessibility feature for one specific user
* Added .mp4 "App Preview" video to App Store
---------------------------------------------------------------------------
### 2.0.10 (not on Github) 1-06-22

This is build 4303 in Apple's App Store
* Fixed bug regarding updating of version/build info in iOS Settings (build script -> startup code)
* Preferences screen
    * added checking on Done button
    * added animation and sound to 2 toggles.
* Minor text changes
---------------------------------------------------------------------------
### 2.0.9 (not on Github) 23-05-22

This is build 4299 in Apple's App Store
* Many text changes in embedded Dutch language ReadMe (and a few to the English version)
* Animimation screen
    * Return, Esc and Space keys all dismiss the Prelude screen (if you have a keyboard attached)
* Used @EnvironmentObject to distribute deviceOwnership
---------------------------------------------------------------------------
### 2.0.8 (not on Github) 09-05-22

This is build 4298 in Apple's App Store
* Preferences screen
    * simplified Preferences page, while adding toggle to show club officers
* bug fix: sort oder on Photographers page was reversed
* various minor user interface improvements
* app has been tested on an M1 Mac
* Portfolio screen
    * introduced the term "portfolio" in the User Interface and Readme page
* Who's who screen
    * renamed the "Photographer" page to "Who's who" and "About" page to "Readme"
* numerous text changes to Dutch and English versions of the Readme page
* dark mode version of app icon
---------------------------------------------------------------------------
### 2.0.7 (not on Github) 01-05-22

This is build 4294 in Apple's App Store
* Preferences screen
    * fixed: "former members" no longer includes external coaches
* Portfolios screen (called Members at the time)
    * text "Members" didn't fit in navigation view when scrolling upwards
    * iPad only: shifted location of search field on Members page
* Prelude screen
    * more precise alignment of logo in Opening page
    * minimized chance of user getting stuck in the opening Prelude screen
* Photo clubs screen
    * changed order of photo clubs
* Readme screen
    * rewritten Readme page and added a Dutch language version
    * added scroll bar to the Readme page (it's fairly long)
---------------------------------------------------------------------------
### 2.0.6 (not on Github) 03-04-22

This is build 3982 in Apple's App Store
* fixed top layout of Readme page on iPhones
* new [i] button and Readme page
* extended the list of items under Preferences
* user can decide to show or hide current members via the Preferences page
* Member page can show warnings/tips if the page is empty or contains duplicate names
* animation of lock icon on Photo Clubs page (with sound)
* other minor user interface improvements: smaller click target for photo club URL, Done button, "Current members", "incl."
* prevented largest DynamicType setting from causing WAALRE to wrap in Prelude animation
---------------------------------------------------------------------------
### 2.0.5 (not on Github) 24-03-22

This is build 3976 in Apple's App Store
* made opening Prelude screen more interactive
* higher resolution version of opening image
* minor user interface improvements: icon for Preferences, URL for photo clubs
* scrolling and panning of maps can be locked by toggling a lock/unlock icon
---------------------------------------------------------------------------
### 2.0.4 (not on Github) 13-03-22

This is build 3974 in Apple's App Store
* changed membership status icons and various other user interface improvements
* new opening Prelude screen showing App icon morphing into Bayer color filter array
* internal improvements: handling of special colors
* updated App Store screenshots (to do)
---------------------------------------------------------------------------
### 2.0.3 (not on Github) 29-01-22

This is build 3966 in Apple's App Store
* new Search feature to search the lists of names
* the web addresses of club-external websites are now displayed (when the info is available)
* minor user interface improvements: Preferences page size, lilac theme color for Photo Clubs
* added club-internal websites for two persons as demo within the Easter egg
* internal improvements: SwiftUI previews, full set of localization comments, colors stored in Assets
* internal: removed test code for non-existent photo club "Old Vic" in Reykjavík
---------------------------------------------------------------------------
### 2.0.2 (not on Github) 20-01-22

This is build 3956 in Apple's App Store
* map supports panning.
* user interface refinements in icons and colors.
* highlights a person's name if app "guesses" this may be the device owner (based on device's name).
* bug fix: deceased members were not displayable (even with Preferences toggle set).
* Easter egg: pull-to-refresh the map page for basic demo of multi-club support. Swipe individual members left to delete.
* iOS Settings app now displays version and copyright information of the Photo Club Waalre app.
* App Store: fixed issue with some screenshots still showing the old version 1.x
* Internal improvements: schema migration (like firstName_ to givenName_).
* And member roles converted to enums for robustness.
---------------------------------------------------------------------------
### 2.0.1 (not on Github) 09-01-22

This is build 3566 in Apple's App Store
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
---------------------------------------------------------------------------
### 2.0.0 (not on Github) 01-01-22

This is build 31, but it didn't reach Apple's' App Store, because app was too website-like.
* First version using SwiftUI and CoreData.
* First version designed to support more than one photo club.
---------------------------------------------------------------------------
## ToDo (incomplete)

* replace NSSortDescriptor() by SortDescriptor(). Propagates to NSFetchRequest. request.wrappedValue?
* handle disappearing members
* filter who's who page
* use SwiftSoup to parse HTML page

* handle being offline better (when installing for 1st time)
* remember to update localizable texts and schema

#### TODO Difficult

* fix concurrency
* internationalization
* register CoreData into CoreSpotlight according to WWDC21
* introduce "shared" pattern (thus killing PersistenceController?)
* follow concurrency guidelines of https://developer.apple.com/videos/play/wwdc2021/10019/

#### TODO Cleanup Easy

* rename loadMembersFromServer & loadMembersFromCode
* define photoClubID as a struct instead of (name: String, town: String) tuple. Prevents repeated typedef code.
* remove TestMembersProvider
* rename Bundle Identifier from com.vdhamer.Fotogroep-Waalre2 to com.vdhamer.Fotogroep-Waalre (to force upgrading)
* fix refresh in iOS15
* move loadMembers from init to new loadMembers function (to allow refresh to work correctly?)
