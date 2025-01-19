## Een level2.json bestand aanmaken voor een club

⏱ Het aanmaken van een bestand met enkele testleden kan - zonder te racen - vast binnen de 5 minuten. \
🕰 Maar de allereerste keer zal het wellicht 1 uur duren als men dingen goed bekijkt of wil uitproberen. 

1. **Download** het [xampleMin.level2.json](https://github.com/vdhamer/Photo-Club-Hub/blob/main/Photo%20Club%20Hub/ViewModel/Lists/xampleMin.level2.json) ("Min") en het
   [xampleMax.level2.json](https://github.com/vdhamer/Photo-Club-Hub/blob/main/Photo%20Club%20Hub/ViewModel/Lists/xampleMax.level2.json) ("Max") voorbeeldbestand.
   _Min_ is een zo klein mogelijk voorbeeldbestand. _Max_ benut alle beschikbare toeters en bellen.

2. Maak een **kopie** van het [Min](https://github.com/vdhamer/Photo-Club-Hub/blob/main/Photo%20Club%20Hub/ViewModel/Lists/xampleMin.level2.json) bestand en geef het een andere naam.
   - Gebruik in de naam een korte versie (`nickName`) van de clubnaam.
     Als de club bijvoorbeeld "Fotogroep Scheveningen" heet, zou je het bestand `fgScheveningen.level2.json` kunnen noemen.
   - Onderstaande tabel bevat, voor de verwachte proefkonijnclubs, deze `nickName` plus enkele
     andere velden die straks nodig zijn. Dat scheelt opzoeken in [root.level1.json]([https://raw.githubusercontent.com/vdhamer/Photo-Club-Hub/refs/heads/main/Photo%20Club%20Hub/ViewModel/Lists/root.level1.json](https://github.com/vdhamer/Photo-Club-Hub/blob/main/Photo%20Club%20Hub/ViewModel/Lists/root.level1.json)) of zelf iets verzinnen.

      | `town`  | `fullName` | `nickName` | `latitude` | `longitude` | huidig bestand |
      | -----  | ---------| ----- | :-----: | :-----: | :-----: |
      | Eindhoven | Fotogroep de Gender | fgDeGender | 51.42398 | 5.45010 | [link](https://raw.githubusercontent.com/vdhamer/Photo-Club-Hub/refs/heads/main/Photo%20Club%20Hub/ViewModel/Lists/fgWaalre.level2.json) |
      | Eindhoven | Fotoclub Ericamera | fcEricamera | 51.45403 | 5.46288 |  |
      | Oirschot | Fotogroep Oirschot | fgOirschot | 51.46785 | 5.25568 |  |
      | Sint Michielsgestel | Fotokring Sint-Michielsgestel | fkGestel | 51.64036 | 5.34749 |  |
      | Veldhoven | Fotoclub Bellus Imago | fcBellusImago | 51.42541 | 5.38756 |  |
      | Waalre | Fotogroep Waalre | fgWaalre | 51.39184 | 5.46144 | [link](https://github.com/vdhamer/Photo-Club-Hub/blob/main/Photo%20Club%20Hub/ViewModel/Lists/root.level1.json) |

3. Pas de gegevens over de **club** (`club`) aan: `town`, `fullName`, `nickName`, en ook locatie.
    - Tip: gebruik voor het aanpassen van het nieuwe bestand liefst de online JSON editor [JSON Editor Online](https://jsoneditoronline.org). Dit programma is bedoeld om dit soort ("JSON") textbestanden te maken, bekijken en controlleren.
        - Alternatief: gebruik een kale editor zoals [Windows NotePad](https://nl.wikipedia.org/wiki/Notepad), [NotePad++](https://nl.wikipedia.org/wiki/Notepad%2B%2B) of [Sublime Text](https://nl.wikipedia.org/wiki/Sublime_Text).

    - De 6 proefkonijnclubs kunnen de vereiste `town`, `fullName`, `nickName` velden en `latitude` en `longitude` velden uit bovenstaande tabel overnemen.
      Er zijn gegevens voor vrijwel alle clubs uit de regio te vinden in [root.level1.json](https://github.com/vdhamer/Photo-Club-Hub/blob/main/Photo%20Club%20Hub/ViewModel/Lists/root.level1.json).

5. Pas gegevens over de **clubleden** (`members`) aan: `givenName`, `infixName` en `familyName`.
    - Tip: met de [JSON Editor Online](https://jsoneditoronline.org) kan je de lijst van clubleden als tabel zien en aanpassen via de "Table" view. Dan kan je dubbel-klikken op cellen die je wilt aanpassen, en regels toevoegen of verwijderen via het "__⋮__" menu.
    - De spelling van clubleden let nauw. Ze worden namelijk gebruikt als identificatie - bijvoorbeeld om te bepalen dat dezelfde persoon lid is of was van 2 clubs. Wat de software betreft zijn zelfs "Jan de Vries" en "Jan De Vries" verschillende personen.
        - Peter van den Hamer voer je in als `"givenName": "Peter", "infixName": "van den", "familyName": "Hamer"`.
        - Max Verstappen voer je in als `"givenName": "Max", "infixName": "", "familyName": "Verstappen"` (`"givenName": "Max", "familyName": "Verstappen"` mag ook).
    - Tip: De lijst met leden hoeft niet in een keer compleet te zijn. Ik zou zelf eerst een paar leden toevoegen om de kijken of alles lukt.
      En de lijst completer maken in een 2e versie. En b.v. eventuele moeilijke namen (na ruggespraak met b.v. ons) in een 3e versie.
    - Het `featuredImage` veld mag later aangepast worden.
      Het bevat een webadres (URL) van een foto gemaakt door de fotograaf.
      Dat webadres moet een plaatje zijn, maar mag op een willekeurige plek op het internet staan.
      Als `featuredImage` ontbreekt of het adres niet klopt, wordt er een oranje dummy plaatje getoond.
 
6. Deze controlestap is alleen nodig als je [JSON Editor Online](https://jsoneditoronline.org) __niet__ gebruikt.
    - Hoezo? JSON Editor Online doet al de belangrijkste JSON controles tijdens het aanpassen van het bestand. En voorkomt zelfs bepaalde soorten fouten.
    - Controle kan door de inhoud van het bestand aan te bieden aan [www.jsonlint.com](https://www.jsonlint.com).
      Dit controleert de basis regels voor een JSON bestand, en vermeld bij eventuele fouten dingen zoals regelnummer.
        - JSONlint wijst je op de eerste fout. Na correctie (kan binnen JSONlint) moet blijken of er meer fouten zijn.
        - Het JSON formaat let nogal nauw ten aanzien van comma's en openenen en sluiten van diverse haakjes.
        - Daarentegen is JSON totaala niet geintereseerd in de hoeveelheid spaties, tabs of nieuwe regels. Indentering is dus belangrijk voor menselijke lezers, maar de software analyzeert de inhoud aan de hand van die comma's, `{ }` paren en `[ ]` paren.
    - Tip: het is handig om de leden in alfabetische volgorde te vermelden. Dan zie je meteen als een lid 2x op de lijst staat.

7. **Send** us your `level2.json` file for uploading and integration into the app. We will try to respond the same day. Our role is to keep an eye on technical correctness (and not, say, whether you got your member names right). If possible, we will send you a link to a web page you can integrate into your club's website - if you need that.
    - For early adopters, where we initially host the file for you, we will fill the optional `level2URL` field for you. It contains the web address where the `level2.json` file resides online.

8. **Inspect** the results using the Photo Club Hub app, and optionally submit a new version with more data.


## Bonus information

### The `Level2.json` format
<details><summary>Details (click to expand)</summary></p>

- [JSON](https://en.wikipedia.org/wiki/JSON) is a very commonly used international standard, but you often won't see it directly. To learn more, find a [tutorial](https://codebeautify.org/json-cheat-sheet). But it should be enough to simply edit the provided [xampleMin.level2.json](https://github.com/vdhamer/Photo-Club-Hub/blob/main/Photo%20Club%20Hub/ViewModel/Lists/xampleMin.level2.json) and [xampleMax.level2.json](https://github.com/vdhamer/Photo-Club-Hub/blob/main/Photo%20Club%20Hub/ViewModel/Lists/xampleMax.level2.json) examples. Especially if you use an editor like [JSON Editor Online](https://jsoneditoronline.org).
- Anything in the `optional: { }` section is not strictly needed and can be left out. This is not a JSON rule. It is a Photo Club Hub choice. See this as “stuff you can add later after your first version works”. In the xampleMin file, we have reduced the optional fields to a suggested minimum set.
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
   - You probably want to fill in `featuredImageURL` soon, as found the `xampleMin.level2.json` file. It gives you a nice sample picture next to the club member's name.
   - Later you may want to add
       - a `website` address (a portfolio website managed by the photographer, separately from their club portfolio). This shows up in the app and via Photo Club Hub HTML as a clickable link.
       - any special roles of the member such as `"isChairman": true`. These are displayed in the app and via Photo Club Hub HTML.
       - `membershipStartDate`. This is currently displayed using Photo Club Hub HTML.
       - `keywords` indication the main genres per photographer. It is currently an [unfinished feature](https://github.com/vdhamer/Photo-Club-Hub/issues/465), and will be covered in a separate instruction file. You can already start providing this data. Best to stick to the keywords found in [this file](https://github.com/vdhamer/Photo-Club-Hub/issues/465).
</details></p>

### Meer over JSON Editor Online
<details><summary>Details (click to expand)</summary></p>
<ul>
   <li> De software vindt volgorde binnen een `[ ]` paar (een lijst) of `{ }` paar (een samenstelling) volstrekt irrelevant. Bij het vergelijken van 2 versies van een bestand zal volgorde bij het vergellijke genegeerd worden. Nogal verassend, maar zo is bepaald in de JSON standaard.</li>
</ul>

</details></details>p>



