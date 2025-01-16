## Creating a new level2.json file for a club in 6 steps 

1. **Download** the [min](https://raw.githubusercontent.com/vdhamer/Photo-Club-Hub/refs/heads/main/Photo%20Club%20Hub/ViewModel/Lists/xampleMin.level2.json) and the [max](https://raw.githubusercontent.com/vdhamer/Photo-Club-Hub/refs/heads/main/Photo%20Club%20Hub/ViewModel/Lists/xampleMax.level2.json) example files. “Min” is optimized for simplicity. “Max” shows all supported optional data fields.
2. Make a **copy** of the [min](https://raw.githubusercontent.com/vdhamer/Photo-Club-Hub/refs/heads/main/Photo%20Club%20Hub/ViewModel/Lists/xampleMin.level2.json) file.
   - Name it to match some reasonable nickname (short name) for the club. So if the club is called "F/8 and Be There" you might choose `f8AndBeThere.level2.json`. If your club is already listed in the Photo Club Hub app, you can just reuse the `nickName` from the file [root.level1.json](https://raw.githubusercontent.com/vdhamer/Photo-Club-Hub/refs/heads/main/Photo%20Club%20Hub/ViewModel/Lists/root.level1.json). To make this even simpler, here's what it says for 6 potential early-adopter clubs:

      | town  | fullName | nickName | latitude | longitude | level2URL |
      | -----  | ---------| ----- | :-----: | :-----: | :-----: |
      | Eindhoven | Fotogroep de Gender | fgDeGender | 51.42398 | 5.45010 | [link](https://raw.githubusercontent.com/vdhamer/Photo-Club-Hub/refs/heads/main/Photo%20Club%20Hub/ViewModel/Lists/fgWaalre.level2.json) |
      | Eindhoven | Fotoclub Ericamera | fcEricamera | 51.45403 | 5.46288 |  |
      | Oirschot | Fotogroep Oirschot | fgOirschot | 51.46785 | 5.25568 |  |
      | Sint Michielsgestel | Fotokring Sint-Michielsgestel | fkGestel | 51.64036 | 5.34749 |  |
      | Veldhoven | Fotoclub Bellus Imago | fcBellusImago | 51.42541 | 5.38756 |  |
      | Waalre | Fotogroep Waalre | fgWaalre | 51.39184 | 5.46144 | [link](https://raw.githubusercontent.com/vdhamer/Photo-Club-Hub/refs/heads/main/Photo%20Club%20Hub/ViewModel/Lists/fgDeGender.level2.json) |

3. **Edit** the file to contain your club’s `fullName`, `town` and an initial list of members.
    - Use a very basic [text editor](https://en.wikipedia.org/wiki/Comparison_of_text_editors) to get a "plain text" output format. So don't use Word (although that _can_ work). It is probably easiest to use the online JSON editor called [JSON Editor Online](https://jsoneditoronline.org): it actually simplifies the process without drowning you in features.
    -  If your club is already visible in the app, you should simply reuse the`fullName` and `town` defined in the file [root.level1.json](https://raw.githubusercontent.com/vdhamer/Photo-Club-Hub/refs/heads/main/Photo%20Club%20Hub/ViewModel/Lists/root.level1.json). Again, the early adopters should find all the info they need in the above table. I know - we are spoiling you.
        - If you aren't one of the 64 or so Dutch clubs in `root.level1.json`,  select the club's `fullName` and `town`: together so that they _together_ uniquely identify the club. Normally "Amsterdam" and "f8 And Be There" should be fine on a world scale. But try to get the spelling right immediately: it is an identification.
    - Names of club members are also critical because they also serve as identification. So "Jan Doede" and "Jan Doedel" will be considered two different members. Software tends to take you literally.
        - Peter van den Hamer is entered as `"givenName": "Peter", "infixName": "van den", "familyName": "Hamer"`.
        - Max Verstappen is entered as `"givenName": "Max", "infixName": "", "familyName": "Verstappen"` or as `"givenName": "Max", "familyName": "Verstappen"`.
    - You can provide the list of club members in steps. So you could initially provide just a few members and add more in a later version.
        - The lucky users of [JSON Editor Online](https://jsoneditoronline.org) can edit the list of club `members` simply by switching to "Table" mode, and then editing like you would edit a spreadsheet!
 
4. If you are not using [JSON Editor Online](https://jsoneditoronline.org), please **check** your JSON data using for example [www.jsonlint.com](https://www.jsonlint.com). This finds the most common errors in JSON files.
    - The lucky [JSON Editor Online](https://jsoneditoronline.org) get their JSON checked while they edit it. So you will get warnings the moment things don't look correct. And some of the edit modes prevent these errors from occurring.
    - After you **fix** the first error, run JSONlint again until all errors are fixed. The JSON format (see below) is notoriously picky about matching commas, curly brackets, etc.
    - You do _not_ need to worry about “white space” like tabs, indentation and new lines. They are important for readability, but don’t count as errors. JSONlint has a feature to fix the formatting.
5. **Send** us your `level2.json` file for uploading and integration into the app. We will try to respond the same day. Our role is to keep an eye on technical correctness (and not, say, whether you got your member names right). If possible, we will send you a link to a web page you can integrate into your club's website - if you need that.
6. **Inspect** the results using the Photo Club Hub app, and optionally submit a new version with more data.

### Appendix: The Level2.json format

- [JSON](https://en.wikipedia.org/wiki/JSON) is a very commonly used international standard, but you often won't see it directly. To learn more, find a [tutorial](https://codebeautify.org/json-cheat-sheet). But it should be enough to simply edit the provided [xampleMin.level2.json](https://github.com/vdhamer/Photo-Club-Hub/blob/main/Photo%20Club%20Hub/ViewModel/Lists/xampleMin.level2.json) and [xampleMax.level2.json](https://github.com/vdhamer/Photo-Club-Hub/blob/main/Photo%20Club%20Hub/ViewModel/Lists/xampleMax.level2.json) examples. Especially if you use an editor like [JSON Editor Online](https://jsoneditoronline.org).
- Anything in the `optional: { }` section is not strictly needed and can be left out. This is not a JSON rule. It is a Photo Club Hub choice. See this as “stuff you can add later after your first version works”. In the xampleMin file, we have reduced the optional fields to a suggested minimum set.

### Appendix: Fields in `level2.json` format about members

- Detailed, and thus somewhat more technical, information about all the fields in a `level2.json` file can be found in [README.md file section](https://github.com/vdhamer/Photo-Club-Hub/blob/main/.github/README.md#level-2-adding-members) (English)
- Recommended data to provide about members
   - you need a `givenName` and `familyName`. `infixName` is for things like "von" in "Ludwig von Beethoven". It is relevant because the app supports European style name sorting conventions: Beethoven would then end up under the B rather than the V.
       - important to get `givenName`, `infixName` and `familyName` exactly right. Including getting the spelling and capitalization and special characters (“François”) right. Otherwise, even after you fix the error, some users may see both versions for some time. Related to a database in the app, and browser caches.
       - American style "middle name" initials as in `Richard M. Nixon` or `Donald J. Trump` can be stored into the `infixName` if you want them displayed. Alternatively store them at the end of the `givenName` so they don't affect sorting on `familyName`.
       - American style suffixes like `Jr.` can be left out. Alternatively, if you prefer them to be visible, you can insert them at the end of the `familyName`. 
       - If in doubt, temporarily leave out a member with a tricky name (like François) until you have decided how to deal with this. This avoids seeing the person twice with a slightly different name. The app is actually supposed to support the full UniCode character set. But not everybody can read Mandarin or modern Greek.
   - For now, you can leave `Level3URL` empty (it is for later: Level 3)
   - You probably want to fill in `featuredImageURL` soon, as found the `xampleMin.level2.json` file. It gives you a nice sample picture next to the club member's name.
   - Later you may want to add
       - a `website` address (a portfolio website managed by the photographer, separately from their club portfolio). This shows up in the app and via Photo Club Hub HTML as a clickable link.
       - any special roles of the member such as `"isChairman": true`. These are displayed in the app and via Photo Club Hub HTML.
       - `membershipStartDate`. This is currently displayed using Photo Club Hub HTML.
       - `keywords` indication the main genres per photographer. It is currently an [unfinished feature](https://github.com/vdhamer/Photo-Club-Hub/issues/465), and will be covered in a separate instruction file. You can already start providing this data. Best to stick to the keywords found in [this file](https://github.com/vdhamer/Photo-Club-Hub/issues/465).

