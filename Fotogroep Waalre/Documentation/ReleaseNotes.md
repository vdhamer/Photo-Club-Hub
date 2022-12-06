---------------------------------------------------------------------------
### 2.2.5 (Github hash ???????) ??-12-22

* Improved robustness of HTML parsing in FGWMembersProvider class
* Portfolios screen
    * Changed vice-chairman status for Fotogroep Waalre (GvS)
* Who's who screen
    * extract date of birth from (extended) membership file for FGW instead of hardcoding this data
    * birthday now also shown for ex-members
---------------------------------------------------------------------------
### 2.2.4 (Github hash 15c87ab) 2-12-22

This is build (4577) in Apple's App Store
* Updated README.md file (mainly architecture topics)
* Portfolios screen
    * Changed vice-chairman status for Fotogroep Waalre (BdG)
    * Updated hardcoded thumbnails uses various Expo2022 images
* Refactoring
    * Minor: tweaked capitalization of titles
    * upgraded to SwiftLint 0.50.1
    * removed file DeviceOwnership.swift (it was not part of the build, but SwiftLint was checking it)
---------------------------------------------------------------------------
### 2.2.3 (Github hash 9d1dfed) 23-10-22

This is build (4576) in Apple's App Store
Release notes for 2.2.3 also contain 2.2.2 release notes
* Portfolios screen
    * yellow question mark is no longer used (replaced by orange question mark stored internally) 
---------------------------------------------------------------------------
### 2.2.2 (Github hash 2462bf9) 23-10-22

This is build (4575) didn't end up in Apple's App Store (forgot to merge a branch)
* Photo Clubs screen
    * Switched from MapPin to MapMarker on map (MapPin deprecated in iOS16)
    * adapted icon representing photo clubs to match MapMarker
* Portfolios screen
    * changed one image thumbnail (for CK)
* Who's Who screen
    * fixed incorrect admin role of one member (CK)
* Refactoring
    * Renamed TestClubMembersProvider class
    * Added comments on club loading in Fotogroep_Waalre_App
    * Renamed insertSomeHardcodedMemberData() method
    * Renamed latestImageURL in database and struct
    * Converted WhatNew.txt to ReleaseNotes.md
    * Built with Xcode 14.1
---------------------------------------------------------------------------
### 2.2.1 (Github hash 71b3b84) 09-10-22

This is build 4574 in Apple's App Store
* Preferences screen
    * Bug fix (iPad only): incorrect attachment point at top of screen. Cosmetic flaw.
* Readme screen
    * Bug fix (iPad only): incorrect attachment point at top of screen. Cosmetic flaw.
---------------------------------------------------------------------------
### 2.2.0 (Github hash c9f0d16) 08-10-22

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
### 2.1.1 (Github hash 4974461) 11-09-22

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
### 2.1.0 (Github hash a658b52) 17-08-22

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
    * Return, Esc and Space keys all dismiss the opening animation (if you have a keyboard attached)
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
* Animation screen
    * more precise alignment of logo in Opening page
    * minimized chance of user getting stuck in the opening animation
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
* prevented largest DynamicType setting from causing WAALRE to wrap in Intro animation
---------------------------------------------------------------------------
### 2.0.5 (not on Github) 24-03-22

This is build 3976 in Apple's App Store
* made opening animation more interactive
* higher resolution version of opening image
* minor user interface improvements: icon for Preferences, URL for photo clubs
* scrolling and panning of maps can be locked by toggling a lock/unlock icon
---------------------------------------------------------------------------
### 2.0.4 (not on Github) 13-03-22

This is build 3974 in Apple's App Store
* changed membership status icons and various other user interface improvements
* new opening animation showing App icon morphing into Bayer color filter array
* internal improvements: handling of special colors
* updated App Store screenshots (to do)
---------------------------------------------------------------------------
### 2.0.3 (not on Github) 29-01-22

This is build 3966 in Apple's App Store
* new Search feature to search the lists of names
* the web addresses of club-external websites are now displayed (when the info is available)
* minor user interface improvements: Settings page size, lilac theme color for Photo Clubs
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
* Settings app now displays version and copyright information of the Photo Club Waalre app.
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
* added icons to Settings popup
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
