## Creating a level1.json file for a number of clubs

This step-by-step guide describes how to create a list of clubs, for example for clubs in a geographic region.
The resulting file is intended to be read automatically by [Photo Club Hub](https://github.com/vdhamer/Photo-Club-Hub)
and [Photo Club Hub HTML](https://github.com/vdhamer/Photo-Club-Hub-HTML). This is why there are requirements regarding the format ("Level 1" JSON).
Separate instructions exist for adding lists of _club members_ ("Level 2" JSON). Level 2 data can be provided at a later time.

> 🕚 Creating a Level 1 file with one or two clubs for the very first time will probably take about 1 hour.
> That time is needed to understand the approach and to figure out how to work with the required software.
> After that, adding and adjusting the data will only take minutes per club.

1. Make a local copy of the [TemplateMin.level1.json](https://github.com/vdhamer/Photo-Club-Hub/blob/main/JSON/TemplateMin.level1.json) ("Min") and    [TemplateMax.level1.json](https://github.com/vdhamer/Photo-Club-Hub/blob/main/JSON/TemplateMax.level1.json) ("Max") example files.
   _Min_ contains the smallest possible example. _Max_ is an example with almost all available options.
   Follow the Min and Max links to get a small "Download raw file" button at the top right.

3. Make a **copy** of the [Max](https://github.com/vdhamer/Photo-Club-Hub/blob/main/JSON/TemplateMax.level1.json) file and give it a suitable file name:
   - For Afdeling #3 (Drenthe - Vechtdal) you could choose `clubsNL03.level1.json`.

   </br>

   > Tip: If you prefer, you can also start from the [Min](https://github.com/vdhamer/Photo-Club-Hub/blob/main/JSON/TemplateMin.level1.json) file instead of Max.
   > The [Min](https://github.com/vdhamer/Photo-Club-Hub/blob/main/JSON/TemplateMin.level1.json) file
   > shows what it looks like when almost all optional fields are missing.
   > This means that you have to add any extra fields you want to fill in yourself, for example by copying those lines from Max.
   > In principle, mistakes can be made during this copying, by taking over slightly too much or too little. Or by adding the extra data in the wrong place.
   > That is not a big deal, though: step 7 explains how you can check the file. The JSON format is simply picky about brackets and commas.

4. Adjust the naming for each **club**: `town`, `fullName`, and `nickName`:
    > Tip: to edit the file, use for example [JSON Editor Online](https://jsoneditoronline.org).
    > That program is specifically designed to create and check so-called "JSON" text files.
    > As an alternative you can use a bare-bones editor such as [Windows NotePad](https://en.wikipedia.org/wiki/Notepad), [NotePad++](https://en.wikipedia.org/wiki/Notepad%2B%2B) or [Sublime Text](https://en.wikipedia.org/wiki/Sublime_Text).
    Microsoft Word or Apple Pages are unsuitable because they inherently use their own file format (.docx and .pages).

    - For the short name, `nickName`, we use a kind of convention such as `fcDenDungen` (for "Fotoclub Den Dungen") or `fgWaalre` (for "Fotogroep Waalre").
    This nickname is mainly used for Level 2 file names and for web addresses.

5. Adjust the location of the club (`coordinates`):
    - The coordinates are used to indicate the nominal location of a club on maps. This lets you discover clubs nearby. The app does _not_ work with a traditional street address.
    - For the Netherlands the coordinates will look like e.g. 51.12345 and 5.67890. So with a dot instead of a comma. And values are around 52 and 5.
    - You can read the coordinates from [maps.google.com](https:/maps.google.com) by right-clicking the chosen address with your mouse.
    - We normally choose the location where the club meets or exhibits. If that is undesirable, you can choose a well-known
    square, station or monument nearby. As an alternative you can use fewer digits after the decimal point. This introduces a less precise location that may be e.g. a kilometer away.
    - If you accidentally leave out `coordinates`, the club is shown at coordinates 0, 0. That is in the middle of the sea near West Africa. You will then see a map in the app with nothing but blue ocean on the equator west of Africa.
    </br>

    > Tip: The list of clubs does not need to be complete in one go:
    > you can add just 1 or 2 clubs first to see whether everything goes well.
    > And then make the list more complete in a subsequent version.

6. Preferably add a remark (`remark`).
    - This highlights something special about this club. It makes the information a bit more interesting to browse through. Practical information is of course allowed too.
      Avoid a standard sentence that applies to almost all clubs (so not "we strive to take better photos" or "we consider ourselves quite sociable").
    - Try not to make the text longer than 100 characters (just a guideline). That is about the length of a Twitter/X "tweet".
    - `remark` contains at least a Dutch (NL) and an English (EN) translation. The iOS app automatically chooses the language to display based on the iOS settings.

7. For affiliated clubs, add their four-digit Fotobond number ("fotobondNumber"). See TemplateMax.level1.json for examples.
    - This consists of 3 lines of text. If a club is not a member of the Fotobond, these 3 lines should be left out: this is how the app knows whether a club is affiliated with the Fotobond.

8. This verification step is mainly useful if you do __not__ use [JSON Editor Online](https://jsoneditoronline.org).
    - With [JSON Editor Online](https://jsoneditoronline.org) no separate JSON check is needed.
      It continuously checks during entry whether the text complies with the JSON rules.
      This flags certain input errors immediately as a red warning, including the line number where the error was found.
    - To manually check a text file for this kind of error in this step, you can copy the entire content into [JSON Editor Online](https://jsoneditoronline.org).
        - JSON Editor Online finds the first error. After correction (which can be done within JSON Editor Online) it goes looking for a next error.
        - The JSON format is rather strict regarding commas, colons, opening/closing of brackets and quotation marks.
          That is why we recommend starting from an example file here.
        - On the other hand, JSON is completely _not_ picky about the amount of spaces, tabs or new lines.
          Indenting the text is very useful for human readers, but the software analyzes the
          content entirely based on the punctuation mentioned. Example: the fragment
          ``` json
          "coordinates": {"latitude": 51.39184, "longitude": 5.46144}
          ```
          and
          ``` json
          "coordinates": {
             "latitude": 51.39184,
             "longitude": 5.46144
          }
          ```
          are equivalent as far as the software (and the JSON standard) is concerned.
    </br>

    > Tip: it is handy to put the clubs in alphabetical order of __town__ (municipality) in the Level 1 file:
    > that way it stands out if a club appears twice on the list or if a club is accidentally missing.

9. **Send** us the `level1.json` file you created. That may also be an interim version. We will try to respond within 24 hours.
    - Our role is to safeguard the _technical_ correctness and to offer help.
      We do not check whether the supplied club information itself is correct. Corrections and additions can always be made afterwards.
    - After a technical check, we place the file on a web server and arrange the integration with the app where needed.
      In the future there will (sooner or later) be the option to place a Level 1 file online at your own location.
      The app then finds the file at a fixed address. But the file can be updated "locally" without central involvement.

10. **Check** whether everything works as desired via the [Photo Club Hub](https://www.fotobond-brabantoost.nl/nieuws/fotoclub-hub-app/) iOS app.
Or via a web page generated by us that is reachable from [/clubs](https://www.fcDeGender.nl/clubs).

## What about `level1URLIncludes`?

This chapter is mainly relevant for files with an "unwieldy" number of clubs:
it offers the possibility to split large Level 1 files into smaller files.
Despite the splitting, the whole is still seen as a whole by the app
because the files can refer to each other (via "links", so to speak).

So, when in doubt, feel free to skip this little chapter about "include" files.

### How exactly does it work?

The previous chapter described how you can create a new file called, for example,
`name.level1.json`. But there are 2 open questions:

Q: How does the app actually know that the file `name.level1.json` needs to be loaded?

A: The app can discover this if there is _another_ file with a reference to the `name.level1.json` file.

Q: Can the file `name.level1.json` itself also contain references to other Level 1 files?

A: Yes. These other files can be regarded as an integral part ("include") of `name.level1.json`.

Both aspects use one and the same mechanism: every Level 1 file
can specify via `level1URLIncludes` that additional underlying Level 1 files must be loaded.
Only the very first (highest, `root.level1.json`) file is found via a fixed name and location (URL).
Let's go into this a little deeper now:

### Splitting Level 1 files

Here is an example of a file called `clubsNL.level1.json`.
It covers, directly or indirectly, the clubs in the Netherlands:

``` json
{
    "level1Header": {
        "level1URL": "https://raw.githubusercontent.com/vdhamer/Photo-Club-Hub/refs/heads/main/JSON/clubsNL.level1.json",
        "level1URLIncludes": [
            "https://raw.githubusercontent.com/vdhamer/Photo-Club-Hub/refs/heads/main/JSON/clubsNL03.level1.json",
            "https://raw.githubusercontent.com/vdhamer/Photo-Club-Hub/refs/heads/main/JSON/clubsNL16.level1.json"
        ],
        "maintainerEmail": "vdhamer@msn.com"
    }
}
```

In this case it contains no individual clubs,
but only references to 2 underlying files: `clubNLS03.level1.json` and `clubsNL16.level1.json`.
It can be extended with more references.
When reading `clubsNL.level1.json`, the apps will check whether there are clubs directly in the file
(in this case not) and additionally read the two lower Level 1 files mentioned.

For the users of the app there is no difference between a `clubsNL.level1.json` file with 80 clubs
and a `clubsNL.level1.json` file with 2 references to files that together contain those 80 clubs.

The advantage of splitting is mainly organizational:
by splitting a long list of clubs into shorter sub-lists
you can clearly agree (and see via `maintainerEmail`) who maintains which sub-file.

### Finding all Level 1 files

In the example above, `clubsNL03.level1.json` is found via a reference from `clubsNL.level1.json` (clubs in the Netherlands).
In a similar way, `clubsNL.level1.json` can be found from a file called `clubs.level1.json` (clubs in all countries).
In turn, `clubs.level1.json` is found from a file called `root_.level1.json` or `root.level1.json`.
That file is the only level1.json that the software finds via a fixed name and location.
All other level1.json files are found via references.

### Summary of the Include mechanism

Starting from a fixed name such as `root.level1.json`, the apps read all relevant Level 1 files via references.
In this tree structure of files, in addition to a branch (`clubsNL.level1.json`) with Dutch clubs
you also find the branch (`museums.level1.json`) with international photography museums. Currently that looks like this:

``` json
{
    "level1Header": {
        "level1URL": "https://raw.githubusercontent.com/vdhamer/Photo-Club-Hub/refs/heads/main/JSON/root_.level1.json",
        "level1URLIncludes": [
            "https://raw.githubusercontent.com/vdhamer/Photo-Club-Hub/refs/heads/main/JSON/clubsNL.level1.json",
            "https://raw.githubusercontent.com/vdhamer/Photo-Club-Hub/refs/heads/main/JSON/museums.level1.json"
        ],
        "maintainerEmail": "vdhamer@msn.com"
    }
}
```

Here `clubsNL.level1.json` in turn refers on to the regional divisions of the Dutch Fotobond.
The divisions contain the lists of `clubs` per division.

Note: this tree structure mainly serves to keep the input data manageable.
Currently the tree structure is not preserved during reading or shown to the user.

There are, by the way, temporarily two versions of the start file:
`root_.level1.json` (for new versions of the software) and `root.level1.json` for old versions of the software.

## Bonus information

### The `Level1.json` format
<details><summary>Details (click to expand)</summary></p>

- [JSON](https://en.wikipedia.org/wiki/JSON) is a very well-known standard in the IT world.
[Here](https://codebeautify.org/json-cheat-sheet) is a short explanation of JSON.
For our purpose it is probably sufficient to carefully follow the available example files:
[TemplateMax.level1.json](https://github.com/vdhamer/Photo-Club-Hub/blob/main/JSON/TemplateMax.level1.json) and
[TemplateMin.level1.json](https://github.com/vdhamer/Photo-Club-Hub/blob/main/JSON/TemplateMin.level1.json).

- All information between the brackets in the `optional: { }` part of the file may be omitted.
That is not a JSON convention, but a choice within this app.
These are therefore fields that you can add later, for example once the required data has been collected.
</details></p>


### Input fields about clubs
<details><summary>Details (click to expand)</summary></p>

- A detailed English description of all supported fields in a 'level1.json' file can be found in the [README.md](https://github.com/vdhamer/Photo-Club-Hub/blob/main/.github/README.md#level-1-adding-clubs) file.
It is often practical to start from an existing Level 1 such as [this real one](https://github.com/vdhamer/Photo-Club-Hub/blob/main/JSON/clubsNL16.level1.json)
or [this schematic one](https://github.com/vdhamer/Photo-Club-Hub/blob/main/JSON/clubTemplates.level1.json) example.

- All fields that describe an individual photo club under `clubs:` in a Level 1 file also appear in the `club:` part at the top of a Level 2 file. The fields are described in somewhat more detail in [that documentation](https://github.com/vdhamer/Photo-Club-Hub/blob/main/Photo%20Club%20Hub/Documentation/Level1_creation_EN.md).

- Regarding the most important fields about Clubs:
   - `level1Header` describes the file itself.
      - `level1URL` is the web address of the master version of this document (presumably on GitHub).
      - `level1URLIncludes` can contain a list of [subordinate](https://github.com/vdhamer/Photo-Club-Hub/blob/main/Photo%20Club%20Hub/Documentation/Level1_creation_EN.md#what-about-level1urlincludes) Level 1 files to be read.
      - `maintainerEmail` is the contact person for problems with this file.
   - `clubs` contains a list of photo clubs. This is merged with any clubs found via `level1URLIncludes`. The individual members within a division are treated as an extra club by the app (with `fotobondNumber` 1600 for e.g. division 16).
      - `idPlus` is the identification of a club. `town` and `fullName` together must be unique. `nickName` must also be unique and preferably have a format such as "fcMyClub" (Fotoclub) or "fgMyClub" (Fotogroep) for the Netherlands.
      - `coordinates` are the longitude and latitude of where the club meets or exhibits (format: 51.53557 resp. 5.62722, but less precision is allowed too - more makes no sense).
      - `optional`
         - `website` contains the address of an existing website of the club.
         - `wikipedia` contains a web address in Wikipedia, but will almost never occur for clubs (unlike museums).
         - `level2URL` contains the web address of the level2.json file with member list information for this club.
         - `remark` contains a single sentence (in Dutch and English) with something important or distinctive about the club. Preferably nothing that would apply to many clubs: people can read that themselves via the website.
         - `maintainerEmail` of the Level 2 file. Because the same data is also in the club's Level 2 file, filling it in here is not important.
         - `nlSpecific` contains information that only has meaning for Dutch clubs
            - `fotobondNumber` is the Fotobond number (e.g. 1641) of a club that is affiliated with the Fotobond. For Dutch clubs that are no longer affiliated with the Fotobond, the `fotobondNumber` line should be left out. This allows the app to know whether a club is currently a member of the Fotobond.
   - `museums` contains a list of museums with a notable photography collection.
For the Netherlands, photo clubs and photo museums are stored in separate files,
so you will not find museums in files about Dutch photo clubs.
Museums are further explained in the English [README.me](https://github.com/vdhamer/Photo-Club-Hub/blob/main/.github/README.md) document.

</details></p>

### More about JSON Editor Online
<details><summary>Details (click to expand)</summary></p>

- At the top of the screen there is something about "signing in" and "pricing".
  For our purpose you can ignore that: the free version is more than enough.
  The site does almost everything without registering. That again saves you having to remember an extra password.

- The site shows a left and a right panel. Those two panels can contain different files (e.g. an example file and a new file). There are buttons to copy the content of one panel to the other. You can use this to view the same JSON content in 2 different ways at the same time. Or to make a copy and use that copy to make your changes in.

- In JSON, the __order__ of the elements within a `[ ]` pair (=list) or a `{ }` pair (=composition) is ignored. So when comparing 2 versions of a file in [JSON Editor Online](https://jsoneditoronline.org), a difference in order will __not__ be interpreted as a difference in content.

- It is risky to blindly let JSON Editor Online repair detected errors ("Autorepair"). This often fixes the error message, but often not in the correct way. In due course we will solve this (via JSON Schema).

- Users of the Apple Safari browser (macOS, iPad) who find the available horizontal screen space tight can remove the advertising on the right-hand edge.
This is done via the Safari [Hide distracting items](https://support.apple.com/en-us/guide/safari/ibrwb68cc4bf/mac) function. Users of a large screen will need this less. But laptops, for example, have smaller screens.
</details></p>

### Can it be made simpler?
<details><summary>Details (click to expand)</summary></p>

This is an important point: we want to keep the threshold for a club to participate as low as possible.
But there are 3 complications in this specific case.

First, we currently do not have the manpower. The tax authorities do manage to have ordinary citizens fill in
data that is subsequently processed automatically ("we can't make it any easier for you").
A whole team works at the tax authorities on their Web app.

Second, we are wary of solutions that require an extra password.
A person already needs so many passwords, logging in means extra steps, and those steps often lead to problems.
For example because the password has been lost, or because the password has to be changed, or has to be shared by 2 people.
So there too we want to reuse existing technology that clubs already often use (e.g. a WordPress website).

Third, we want to avoid costs being incurred. Costs cause organizational hassle ("can't it be done cheaper").

We certainly do not rule out future simplifications. But this does require clever ideas, and the expertise and energy to carry them out.
</details></p>
