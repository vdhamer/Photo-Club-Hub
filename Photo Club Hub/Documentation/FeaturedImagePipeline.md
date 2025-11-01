#  Featured images data flow

## Find level2.json data

- Accessing the data
  - A club's Level 2 file is available online at GitHub.
  - example: `https://raw.githubusercontent.com/vdhamer/Photo-Club-Hub/main/Photo%20Club%20Hub/ViewModel/Lists/fgDeGender.level2.json`
  - If the URL fails to load when the app starts, a version of the same file is taken from the PhotoClubHubData bundle.
    - This version corresponds to the level2.json file state _at build time_. This means it could be outdated compared to the GitHub version.
    - This means that GitHub holds the _master copy_ of (committed) Level 2 data. Both apps rely on this copy.
  - The Level 2 data used in PhotoClubHub.app is persisted by the CoreData database
  - The Level 2 data used in PhotoClubHubHTML.app is loaded into CoreData, but this happens _after clearing_ CoreData. So this isn't really persistent.

## Reading level2.json data

- Content of the Level 2 file
  - the `club` section contains data about the club
  - the `members` section contains a list of club members with avarious URLs. Also with expertise tags and the member's roles/status (not relevant here).
- The reaading is done by `level2JsonReader`
- `level2JsonReader` passes the jsonData to `mergeLevel2Json`
  - which calls `loadMember()` in a for-loop (the members may show up alphabetically based on first or last name)
 
## Processing a single member in level2.json data

- a club member may have a field with a direct URL to the featured image
  `"featuredImage": "https://www.fotoclubbellusimago.nl/uploads/5/5/1/2/55129719/2024-01-14-12-28-macro-druppels-3754-2024-alex.jpg"`
- advanced club usage may have a field pointing to the member's portfolio, and the software will find featuredImage automatically
  `"level3URL": "https://www.fcDeGender.nl/portfolios/Miep_Franssen/"`
  which contains the portfolio of image files and an (XML) index of these files.

====================================================================================

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
