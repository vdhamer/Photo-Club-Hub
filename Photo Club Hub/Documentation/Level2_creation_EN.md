## Creating a new level2.json file for your club 

1. **Download** the [min](https://raw.githubusercontent.com/vdhamer/Photo-Club-Hub/refs/heads/main/JSON/TemplateMin.level2.json) and the [max](https://raw.githubusercontent.com/vdhamer/Photo-Club-Hub/refs/heads/main/JSON/TemplateMax.level2.json) example files. “Min” is optimized for simplicity. “Max” shows all supported optional data fields.

2. Make a **copy** of the [min](https://raw.githubusercontent.com/vdhamer/Photo-Club-Hub/refs/heads/main/JSON/TemplateMin.level2.json) file.
   - Rename the file to some short name (`nickName`) for the club. So if the club is called "F/8 and Be There" you might choose `f8AndBeThere.level2.json`. If your club is already listed in the Photo Club Hub app, you can just reuse the `nickName` from the file [root.level1.json](https://raw.githubusercontent.com/vdhamer/Photo-Club-Hub/refs/heads/main/JSON/root.level1.json). To make this even simpler, here's what it says for some of the early-adopter clubs:

      | `town`  | `fullName` | `nickName` | `latitude` | `longitude` | Input file | Output page |
      | -----  | ---------| ----- | :-----: | :-----: | :-----: | :-----: |
      | Berlicum | FCC Shot71 | fccShot71 | 51.66306 | 5.41825 | ? |  |
      | Eindhoven | Fotogroep de Gender | fgDeGender | 51.42398 | 5.45010 | [link](https://github.com/vdhamer/Photo-Club-Hub/blob/main/JSON/fgDeGender.level2.json) | [link](http://www.vdhamer.com/fgDeGender) |
      | Eindhoven | Fotoclub Ericamera | fcEricamera | 51.45403 | 5.46288 | [link](https://github.com/vdhamer/Photo-Club-Hub/blob/main/JSON/fcEricamera.level2.json) | [link](http://www.vdhamer.com/fcEricamera) |
      | Eindhoven | Fotoclub 't Karregat | fcKarregat | 51.48048 | 5.42879 | ? |  |
      | Oirschot | Fotogroep Oirschot | fgOirschot | 51.46785 | 5.25568 | [link](https://github.com/vdhamer/Photo-Club-Hub/blob/main/JSON/fgOirschot.level2.json) |[link](http://www.vdhamer.com/fgOirschot) |
      | Sint Michielsgestel | Fotokring Sint-Michielsgestel | fkGestel | 51.64036 | 5.34749 | ? |
      | Veldhoven | Fotoclub Bellus Imago | fcBellusImago | 51.42541 | 5.38756 | [link](https://github.com/vdhamer/Photo-Club-Hub/blob/main/JSON/fcBellusImago.level2.json) | [link](http://www.vdhamer.com/fcBellusImago) |
      | Waalre | Fotogroep Waalre | fgWaalre | 51.39184 | 5.46144 | [link](https://github.com/vdhamer/Photo-Club-Hub/blob/main/JSON/fgWaalre.level2.json) | [link](http://www.vdhamer.com/fgWaalre) |

3. **Edit** the file to contain your club’s `fullName`, `town`, `nickName`, and preferably coordinates.
    - Use a basic [text editor](https://en.wikipedia.org/wiki/Comparison_of_text_editors) to get a "plain text" output format. So don't use Word (although that _can_ work). Note that it is probably easiest to use the online JSON editor called [JSON Editor Online](https://jsoneditoronline.org): because it assumes you are trying to create a JSON file and can thus help simplify the process.
    -  If your club is already visible in the app, you should simply reuse the`fullName` and `town` defined in the file [root.level1.json](https://raw.githubusercontent.com/vdhamer/Photo-Club-Hub/refs/heads/main/JSON/root.level1.json). Again, the early adopters should find all the info they need in the above table.
        - If you are not one of the 64+ Dutch clubs in `root.level1.json`,  provide the club's `fullName` and `town`. Together these 2 fields uniquely identify the club: there better not be two clubs called "f8 and Be There" in Amsterdam. But there could be one that happens to have the same `fullName` in Singapore. Be careful to get the spelling right the first time: it gets messy if you need to fix this later.

4. **Update** the file to show your club’s `members`.
    - If you are using [JSON Editor Online](https://jsoneditoronline.org), you can edit the list of club members simply by switching to "Table" mode. This shows you a table where you can edit cells (double-click) and add rows (in the "__⋮__" menu).
    - Names of club members need to be spelled correctly because they also serve as identification. So "Jan Doede" and "Jan Doedel" are two different persons to the software.
        - Peter van den Hamer is entered as `"givenName": "Peter", "infixName": "van den", "familyName": "Hamer"`.
        - Max Verstappen is entered as `"givenName": "Max", "infixName": "", "familyName": "Verstappen"` (or alternatively as `"givenName": "Max", "familyName": "Verstappen"`).
    - You don't need to provide the complete list of club members in one go. So you could initially provide a few members as a test and add more members in later versions.
 
5. Users of [JSON Editor Online](https://jsoneditoronline.org) can skip this step of **checking** the file.
    - Why? JSON Editor Online generates warnings the moment the file is not a valid JSON file. A warning will tell you what's wrong and where the error is. The site's Tree and Table modes even prevent certain types of errors.
    - But, if you are not using JSON Editor Online, you should **check** your JSON data by copying the JSON content into [www.jsonlint.com](https://www.jsonlint.com). This checks whether it is a valid JSON file.
        - After you **fix** the first error, run JSONlint again until all errors are fixed. The JSON format (see below) is notoriously picky about matching commas, curly brackets, etc.
        - You do _not_ need to worry about “white space” like tabs, indentation, and new lines. They are important for readability but don’t count as errors. The tools typically have a feature to reformat/beautify the JSON.
    - We recommend listing the members in alphabetical order. This helps you detect duplicates. In the JSON convention and in JSON comparison tools, ordering doesn't matter at all. 

6. **Send** us your `level2.json` file for uploading and integration into the app. We will try to respond the same day. Our role is to keep an eye on technical correctness (and not, say, whether you got your member names right). If possible, we will send you a link to a web page you can integrate into your club's website - if you need that.
    - For early adopters, where we initially host the file for you, we will fill the optional `level2URL` field for you. It contains the web address where the `level2.json` file resides online.

7. **Inspect** the results using the Photo Club Hub app, and optionally submit a new version with more data.


## Bonus information

### The `Level2.json` format
<details><summary>Details (click to expand)</summary></p>

- [JSON](https://en.wikipedia.org/wiki/JSON) is a very commonly used international standard, but you often won't see it directly. To learn more, find a [tutorial](https://codebeautify.org/json-cheat-sheet). But it should be enough to simply edit the provided [TemplateMin.level2.json](https://github.com/vdhamer/Photo-Club-Hub/blob/main/JSON/TemplateMin.level2.json) and [TemplateMax.level2.json](https://github.com/vdhamer/Photo-Club-Hub/blob/main/JSON/TemplateMax.level2.json) examples. Especially if you use an editor like [JSON Editor Online](https://jsoneditoronline.org).
- Anything in the `optional: { }` section is not strictly needed and can be left out. This is not a JSON rule. It is a Photo Club Hub choice. See this as “stuff you can add later after your first version works”. In the TemplateMin file, we have reduced the optional fields to a suggested minimum set.
</details></p>

### Data fields about members
<details><summary>Details (click to expand)</summary></p>

- Detailed, and thus somewhat more technical, information about all the fields in a `level2.json` file can be found in [README.md file section](https://github.com/vdhamer/Photo-Club-Hub/blob/main/.github/README.md#level-2-adding-members) (English)
- Recommended data to provide about members
   - you need a `givenName` and `familyName`. `infixName` is for things like "von" in "Ludwig von Beethoven". It is relevant because the app supports European style name sorting conventions: Beethoven would then end up under the B rather than the V.
       - important to get `givenName`, `infixName` and `familyName` exactly right. Including getting the spelling and capitalization and special characters (“François”) right. Otherwise, even after you fix the error, some users may see both versions for some time. Related to a database in the app, and browser caches.
       - American style "middle name" initials as in `Richard M. Nixon` or `Donald J. Trump` can be stored into the `infixName` if you want them displayed. Alternatively store them at the end of the `givenName` so they don't affect sorting on `familyName`.
       - American style suffixes like `Jr.` can be left out. Alternatively, if you prefer them to be visible, you can insert them at the end of the `familyName`. 
       - If in doubt, temporarily leave out a member with a tricky name (like François) until you have decided how to deal with this. This avoids seeing the person twice with a slightly different name. The app is actually supposed to support the full UniCode character set. But not everybody can read Mandarin or modern Greek.
   - For now, you can leave `Level3URL` empty (it is for later: Level 3)
   - You probably want to fill in `featuredImage` soon. It is in the `TemplateMin.level2.json` file. It gives you a nice sample picture next to the club member's name.
   - Later you may want to add
       - a `website` address (a portfolio website managed by the photographer, separately from their club portfolio). This shows up in the app and via Photo Club Hub HTML as a clickable link.
       - any special roles of the member such as `"isChairman": true`. These are displayed in the app and via Photo Club Hub HTML.
       - `membershipStartDate`. This is currently displayed using Photo Club Hub HTML.
       - `expertises` indication the main genres per photographer. It is currently an [unfinished feature](https://github.com/vdhamer/Photo-Club-Hub/issues/465), and will be covered in a separate instruction file. You can already start providing this data. Best to stick to the expertises found in [this file](https://github.com/vdhamer/Photo-Club-Hub/issues/465).
</details></p>


