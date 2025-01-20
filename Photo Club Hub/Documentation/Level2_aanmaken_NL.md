## Een level2.json bestand aanmaken voor een club

> 🕚 Het de allereerste keer aanmaken van een Level2 bestand (gevuld met enkele testleden) kost misschien 1 uur kost. \
> Die eenmalige investering is nodig om te ontdekken hoe met het gereedschap om te gaan.
> Vervolgaanpassingen en uitbreidingen van de gegevens zullen ongetwijfeld veel sneller (minuten?) gaan. 

1. Maak desgewenst een locale kopie van het [xampleMin.level2.json](https://github.com/vdhamer/Photo-Club-Hub/blob/main/Photo%20Club%20Hub/ViewModel/Lists/xampleMin.level2.json) ("Min") en het
   [xampleMax.level2.json](https://github.com/vdhamer/Photo-Club-Hub/blob/main/Photo%20Club%20Hub/ViewModel/Lists/xampleMax.level2.json) ("Max") voorbeeldbestand.
   _Min_ is een zo klein mogelijk voorbeeldbestand. _Max_ benut daarentegen alle beschikbare toeters en bellen.

2. Maak een **kopie** van het [Min](https://github.com/vdhamer/Photo-Club-Hub/blob/main/Photo%20Club%20Hub/ViewModel/Lists/xampleMin.level2.json) bestand en verander de naam van het bestand:
   - Gebruik in de naam een korte versie (`nickName`) van de clubnaam.
     Als de club bijvoorbeeld "Fotogroep Scheveningen" heet, zou je het bestand `fgScheveningen.level2.json` kunnen noemen.
   - Onderstaande tabel bevat, voor de verwachte proefkonijnclubs, deze `nickName` plus enkele andere velden die straks nodig zijn.
     Dan hoef je die velden niet zelf op te zoeken in de [lijst](https://github.com/vdhamer/Photo-Club-Hub/blob/main/Photo%20Club%20Hub/ViewModel/Lists/root.level1.json) met clubs in Brabant Oost.

      | `town`  | `fullName` | `nickName` | `latitude` | `longitude` | huidig bestand |
      | -----  | ---------| ----- | :-----: | :-----: | :-----: |
      | Eindhoven | Fotogroep de Gender | fgDeGender | 51.42398 | 5.45010 | [link](https://raw.githubusercontent.com/vdhamer/Photo-Club-Hub/refs/heads/main/Photo%20Club%20Hub/ViewModel/Lists/fgWaalre.level2.json) |
      | Eindhoven | Fotoclub Ericamera | fcEricamera | 51.45403 | 5.46288 |  |
      | Oirschot | Fotogroep Oirschot | fgOirschot | 51.46785 | 5.25568 |  |
      | Sint Michielsgestel | Fotokring Sint-Michielsgestel | fkGestel | 51.64036 | 5.34749 |  |
      | Veldhoven | Fotoclub Bellus Imago | fcBellusImago | 51.42541 | 5.38756 |  |
      | Waalre | Fotogroep Waalre | fgWaalre | 51.39184 | 5.46144 | [link](https://github.com/vdhamer/Photo-Club-Hub/blob/main/Photo%20Club%20Hub/ViewModel/Lists/root.level1.json) |

3. Pas de gegevens over de **club** (`club`) aan: `town`, `fullName`, `nickName`, en ook de locatie:
    - Tip: gebruik voor het aanpassen van het nieuwe bestand liefst [JSON Editor Online](https://jsoneditoronline.org). Dat programma is bedoeld om zogenaamde "JSON" textbestanden aan te maken, te openen en meer.
        - Als alternatief kan je een kale editor gebruiken zoals [Windows NotePad](https://nl.wikipedia.org/wiki/Notepad), [NotePad++](https://nl.wikipedia.org/wiki/Notepad%2B%2B) of [Sublime Text](https://nl.wikipedia.org/wiki/Sublime_Text).

    - De 6 proefkonijnclubs kunnen de vereiste `town`, `fullName`, `nickName`,`latitude` en `longitude` velden uit de bovenstaande tabel overnemen.
      Er zijn gegevens voor vrijwel alle clubs uit de regio te vinden in [root.level1.json](https://github.com/vdhamer/Photo-Club-Hub/blob/main/Photo%20Club%20Hub/ViewModel/Lists/root.level1.json).

4. Pas gegevens over de **clubleden** (`members`) aan: `givenName`, `infixName` en `familyName`.
    - Tip: met de [JSON Editor Online](https://jsoneditoronline.org) kan je de lijst van clubleden als tabel zien en aanpassen via de "Table" view. Dan kan je dubbel-klikken op cellen die je wilt aanpassen, en regels toevoegen of verwijderen via het "__⋮__" menu.
    - De spelling van de namen van clubleden let nauw.
      De namen worden namelijk gebruikt als identificatie - bijvoorbeeld om te bepalen of een bepaald lid ook voorkomt als (ex)lid van een andere club.
      Wat de software betreft zijn zelfs "Jan de Vries" en "Jan De Vries" verschillende personen.
        - Jan de Vries voer je in als `"givenName": "Jan", "infixName": "de", "familyName": "Vries"`.
        - Max Verstappen voer je in als `"givenName": "Max", "infixName": "", "familyName": "Verstappen"` (het mag ook als `"givenName": "Max", "familyName": "Verstappen"`).
    - Tip: De lijst met leden hoeft niet in een keer compleet te zijn: je kan eerst enkele leden toevoegen om de kijken of alles lukt.
      En de lijst completer maken in een 2e versie. En b.v. eventuele moeilijke namen (b.v. na ruggespraak met ons) in een 3e versie.
    - Het `featuredImage` veld mag later aangepast worden.
      Het bevat een webadres (URL) van een foto gemaakt door de fotograaf.
      Dat webadres moet een plaatje zijn, maar mag op een willekeurige plek op het internet staan.
      Als `featuredImage` ontbreekt of het adres niet klopt, wordt er een oranje dummy plaatje getoond.
 
5. Deze controlestap is alleen nodig als je [JSON Editor Online](https://jsoneditoronline.org) __niet__ gebruikt.
    - Er is bij [JSON Editor Online](https://jsoneditoronline.org) geen aparte JSON controle nodig.
      Het controleert namelijk voordurend of de tekst voldoet aan de JSON regels en sommige sommige fouten worden zelfs compleet voorkomen.
    - Controle van de inhoud van het bestand kan ook door de inhoud te kopiëren naar [www.jsonlint.com](https://www.jsonlint.com).
      Dit controleert de diverse JSON basisregels, en benoemt de eventuele fouten met bijbehorend regelnummer.
        - JSONlint wijst je op de eerste fout. Na correctie (kan binnen JSONlint) moet blijken of er meer fouten zijn.
        - Het JSON formaat let nogal nauw ten aanzien van comma's en openenen en sluiten van haakjes en aanhalingstekens. Vandaar dat we begonnen met een voorbeeldbestand.
        - Daarentegen is JSON totaal niet kieskeurig wat betreft de hoeveelheid spaties, tabs of nieuwe regels.
          Indentering is dus belangrijk voor menselijke lezers, maar de software analyzeert de inhoud aan de hand van de leestekens.
    - Tip: het is handig om de leden in alfabetische volgorde te vermelden: dan valt het op als een lid dubbel op de lijst voorkomt.

6. **Stuur** ons het gemaakte `level2.json` bestand. Dat mag ook bij tussenversies. Wij zullen proberen binnen 24 uur te reageren (nodig voor de volgende stap).
    - Onze rol is om een de technische juistheid te bewaken en om hulp te bieden. Wij kunnen niet zien of de aangeleverde ledenlijst accuraat is of zien of alles juist gespeld is.
    - Voor de proefkonijnclubs zullen we het bestand op onze eigen webserver zetten en het bijbehorende adres (URL) terugmelden.
      Op termijn komen er extra instructies hoe een club _zelf_ zijn Level2 ledenbestand op een eigen (b.v. Wordpress) website kan zetten.
      Dan kan een club zijn Level2 bestand aanpassen zonder via ons te gaan.

7. **Controlleer** of alles naar wens werkt via de [Photo Club Hub](https://www.fotobond-brabantoost.nl/nieuws/fotoclub-hub-app/) iOS app.
Of via een door ons [gegenereerde](https://github.com/vdhamer/Photo-Club-Hub-HTML/blob/main/.github/README.md) HTML pagina als geen iPhone of iPad voorhanden is.

## Bonus informatie

### Het `Level2.json` formaat
<details><summary>Details (klik om uit te klappen)</summary></p>

- [JSON](https://en.wikipedia.org/wiki/JSON) is zeer bekende internationale standaard in de IT wereld.
[Hier](https://codebeautify.org/json-cheat-sheet) is een korte uitleg van JSON. In ons geval is zou het voldoende moeten zijn om nauwgezet de voorbeelden in
[xampleMin.level2.json](https://github.com/vdhamer/Photo-Club-Hub/blob/main/Photo%20Club%20Hub/ViewModel/Lists/xampleMin.level2.json) en [xampleMax.level2.json](https://github.com/vdhamer/Photo-Club-Hub/blob/main/Photo%20Club%20Hub/ViewModel/Lists/xampleMax.level2.json) te volgen.
Bij gebruikt van [JSON Editor Online](https://jsoneditoronline.org) is de kans op fouten klein.

- Alle informatie tussen de haakjes in het `optional: { }` gedeelte van het bestand mag eventueel weggelaten worden. Dat is geen JSON conventie, maar een keus voor bestanden waar het hier om gaat. 
Het zijn dus velden die je alsnog bij een tekstaanpassing kan toevoegen, bijvoorbeeld omdat de voordelen van de gegevens leveren inmiddels duidelijk zijn, of omdat de gegevens ondertussen beschikbaar kwamen.
</details></p>

### Invoervelden over clubleden
<details><summary>Details (klik om uit te klappen)</summary></p>

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
<details><summary>Details (klik om uit te klappen)</summary></p>
- De software vindt volgorde binnen een `[ ]` paar (een lijst) of `{ }` paar (een samenstelling) volstrekt irrelevant. Bij het vergelijken van 2 versies van een bestand zal volgorde bij het vergellijke genegeerd worden. Nogal verassend, maar zo is bepaald in de JSON standaard.</li>

</details></details></details</details></details>
</p>



