#  Featured images data flow

## Location #1 = L2 = level2.json file

- Accessing the data
  - a club's Level 2 file is online at GitHub
  - path: `https://raw.githubusercontent.com/vdhamer/Photo-Club-Hub/main/Photo%20Club%20Hub/ViewModel/Lists/fgDeGender.level2.json`
  - If not reachable when the app loads, a version of the same file is taken from the PhotoClubHubData bundle.
    - this version corresponds to the level2.json file state at build time
  - the level2.json file is actually read from GitHub, so GitHub contains the master copy
  - the Level 2 data used in PhotoClubHub.app is persisted by the CoreData database
  - the Level 2 data used in PhotoClubHubHTML.app is loaded intoCoreData, but currently __after clearing__ CoreData.
- General content of Level 2 file
  - contains data about the club, and a list of club members
- Finding featured images
  - a club member may have a field with a direct URL to the featured image
  `"featuredImage": "https://www.fotoclubbellusimago.nl/uploads/5/5/1/2/55129719/2024-01-14-12-28-macro-druppels-3754-2024-alex.jpg"`
  - advanced club usage may have a field pointing to the member's portfolio
  `"level3URL": "https://www.fcDeGender.nl/portfolios/Miep_Franssen/"`
  which contains the portfolio of image files and an XML index of these files.

====================================================================================

level2.json on GitHub file gets read by level2JsonReader
passes jsonData to mergeLevel2Json()
that calls loadMember() in a for-loop, starting alphabetically with Aad Schoenmakers
that sets local params:
    featuredImage to nil (because it is not listed in online file)
    level3URL_ to http://www.vdhamer.com/fgWaalre/Aad_Schoenmakers (as in online file)

====================================================================================

And then, still within for loop, calls refreshFirstImage() on an async thread
that determines URL of xml file: http://www.vdhamer.com/fgWaalre/Aad_Schoenmakers/config.xml
For Aad Schoenmakers:
    featuredImage = http://www.vdhamer.com/fgWaalre/Aad_Schoenmakers/images/2014_ExpoFGWaalre_069.jpg
    featuredImageThumbnail = http://www.vdhamer.com/fgWaalre/Aad_Schoenmakers/thumbs/2014_ExpoFGWaalre_069.jpg
The updated data gets committed on the bgContext.

====================================================================================

When generating a memberRow for Ignite, first downloadThumbnailToLocal is called.
It uses featuredImageThumbnail = http://www.vdhamer.com/fgWaalre/Aad_Schoenmakers/thumbs/2014_ExpoFGWaalre_069.jpg
It re-encodes the JPG file (of compression 0.65).
And writes the data to "file:/Users/peter/Library/Containers/com.vdHamer.Photo-Club-Hub-HTML/Data/Build/images/2014_ExpoFGWaalre_069.jpg" in the app's sandbox.

====================================================================================

clearBuildFolder() erases buildDirectory = "file:///Users/peter/Library/Containers/com.vdHamer.Photo-Club-Hub-HTML/Data/Build"
generateContent() recreates the content, but how does it handle the Members site?

## Location #5 = D/A = Data/Assets folder

- Something puts the required images (and more?) into the Data/Assets folder
    - Path: ``/Users/petervandenhamer/Library/Containers/com.vdHamer.Photo-Club-Hub-HTML/Data/Assets/images``
    - that directory **IS** filled by copy files from elsewhere: Experiment: remove file and run Ignite app -> file reappears.
    - that directory **ISN'T** cleared at the start of a build. Experiment: introduce a new file and run Ignite app -> file doesn't disappear.
    - who copies the code from tbd to Data/Assets?? Code that handles FeaturedImages.
    
## Location #6 = D/B = Data/Build folder

- Ignite stores the images (for Level 2 thumbnails) in a directory /images/2025_fgDeGenderExpo_034.jpg relative to the root of the site
    - Path: ``/Users/petervandenhamer/Library/Containers/com.vdHamer.Photo-Club-Hub-HTML/Data/Build/images``
    - that directory **IS** filled by copying files from elsewhere. Experiment: remove file and run Ignite app -> reappeared.
    - that directory **IS** cleared at the start of a build. Experiment: introduce a new file and run Ignite app -> file disappears.
    - the 155 image files are copied over from
      ``/Users/petervandenhamer/Library/Containers/com.vdHamer.Photo-Club-Hub-HTML/Data/Assets/images`` (Note **Data/Assets** part of path)
    - who copies the code from Data/Assets to Data/Build?? Code for publishing in Ignite
