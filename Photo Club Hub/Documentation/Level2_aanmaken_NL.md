## Een level2.json bestand aanmaken voor een club

Dit stappenplan beschrijft hoe men een lijst met de leden van een club aanmaakt.
Het resulterende bestand wordt straks automatisch ingelezen door de [Photo Club Hub](https://github.com/vdhamer/Photo-Club-Hub)
en [Photo Club Hub HTML](https://github.com/vdhamer/Photo-Club-Hub-HTML) apps.
Om dit automatisch inlezen mogelijk te maken zijn er stricte eisen ten aanzien het bestandsformaat ("Level 2" JSON).
Er zijn [aparte instructies](https://github.com/vdhamer/Photo-Club-Hub/blob/main/Photo%20Club%20Hub/Documentation/GitHub_bestandsbeheer_NL.md) hoe bestanden aan te bieden via GitHub.
En er komen aparte instructies hoe _portfolio's_ met foto's ("Level 3") toe te voegen.

> 🕚 Het kost pakweg 1 uur om de allereerste keer een Level2 bestand met enkele testleden aan te maken. \
> Die eenmalige investering is nodig om aan de aanpak te wennen en te ontdekken hoe met de vereiste software om te gaan. \
> Hierna kosten uitbreiding en aanpassingen van de gegevens slechts minuten per clublid.

1. Maak een lokale kopie van de [TemplateMin.level2.json](https://github.com/vdhamer/Photo-Club-Hub/blob/main/JSON/TemplateMin.level2.json) ("Min") en het
   [TemplateMax.level2.json](https://github.com/vdhamer/Photo-Club-Hub/blob/main/JSON/TemplateMax.level2.json) ("Max") voorbeeldbestanden.
   _Min_ is een zo klein mogelijk voorbeeldbestand. _Max_ bevat juist alle beschikbare opties.

2. Maak een **kopie** van het [Min](https://github.com/vdhamer/Photo-Club-Hub/blob/main/JSON/TemplateMin.level2.json) of [Max](https://github.com/vdhamer/Photo-Club-Hub/blob/main/JSON/TemplateMax.level2.json) bestand met een passende bestandsnaam:
   - Gebruik in de naam een korte versie (`nickName`) van de clubnaam.
     Als de club bijvoorbeeld "Fotogroep Scheveningen" heet, zou het bestand bij voorkeur `fgScheveningen.level2.json` moeten heten:
     Scheveningen is essentieel voor de herkenbaarheid, en Fotogroep en Fotoclub korten we hier af tot tot een voorvoegsel "fg" en "fc" omdat ze vaak voorkomen.
   - Onderstaande tabel bevat, voor enkele clubs in Brabant Oost, deze `nickName` plus enkele andere velden die het invullen vergemakkelijken.
     Dan hoef je die velden niet zelf op te zoeken (in lijsten zoals [deze](https://github.com/vdhamer/Photo-Club-Hub/blob/main/JSON/clubsNL16.level1.json)).

      | `town`  | `fullName` | `nickName` | `latitude` | `longitude` | Input bestand | Output pagina |
      | -----  | ---------| ----- | :-----: | :-----: | :-----: | :-----: |
      | Berlicum | FCC Shot71 | fccShot71 | 51.66306 | 5.41825 | ⌛ |  |
      | Brabant Oost | Persoonlijk | Persoonlijk16 | 51.44327 | 5.47990 | [link](https://github.com/vdhamer/Photo-Club-Hub/blob/main/JSON/Persoonlijk16.level2.json) | [link](http://www.vdhamer.com/Persoonlijk16) |
      | Den Dungen | Fotoclub Den Dungen | fcDenDungen | 51.66214 | 5.37097 | [link](https://github.com/vdhamer/Photo-Club-Hub/blob/main/JSON/fcDenDungen.level2.json) ⌛ | [link](http://www.vdhamer.com/fcDenDungen) |
      | Eindhoven | Fotogroep de Gender | fgDeGender | 51.42398 | 5.45010 | [link](https://github.com/vdhamer/Photo-Club-Hub/blob/main/JSON/fgDeGender.level2.json) | [link](http://www.vdhamer.com/fgDeGender) |
      | Eindhoven | Fotoclub Ericamera | fcEricamera | 51.45403 | 5.46288 | [link](https://github.com/vdhamer/Photo-Club-Hub/blob/main/JSON/fcEricamera.level2.json) ⌛ | [link](http://www.vdhamer.com/fcEricamera) |
      | Eindhoven | Fotoclub 't Karregat | fcKarregat | 51.48048 | 5.42879 | ? |  |
      | Gemert | Foto Expressie Groep Gemert | fegGemert | 51.56025 | 5.68508 | ⌛ |  |
      | Oirschot | Fotogroep Oirschot | fgOirschot | 51.46785 | 5.25568 | [link](https://github.com/vdhamer/Photo-Club-Hub/blob/main/JSON/fgOirschot.level2.json) ⌛ | [link](http://www.vdhamer.com/fgOirschot) |
      | Schijndel | Fotoclub Schijndel | fcSchijndel | 51.61402 | 5.44888 | ? |  |
      | Sint Michielsgestel | Fotokring Sint-Michielsgestel | fkGestel | 51.64036 | 5.34749 | [link](https://github.com/vdhamer/Photo-Club-Hub/blob/main/JSON/fkGestel.level2.json) ⌛ | [link](http://www.vdhamer.com/fkGestel) |
      | Veldhoven | Fotoclub Bellus Imago | fcBellusImago | 51.42541 | 5.38756 | [link](https://github.com/vdhamer/Photo-Club-Hub/blob/main/JSON/fcBellusImago.level2.json) | [link](http://www.vdhamer.com/fcBellusImago) |
      | Veghel | Fotoclub Veghel | fcVeghel | 51.62441 | 5.55930 | [link](https://github.com/vdhamer/Photo-Club-Hub/blob/main/JSON/fcVeghel.level2.json) | [link](http://www.vdhamer.com/fcVeghel) |
      | Veghel | Fotoclub Zzzoom | fcVeghel | 51.35712 | 5.31062 | ? |  |
      | Waalre | Fotogroep Waalre | fgWaalre | 51.39184 | 5.46144 | [link](https://github.com/vdhamer/Photo-Club-Hub/blob/main/JSON/fgWaalre.level2.json) | [link](http://www.vdhamer.com/fgWaalre) |

   > Tip: Hoe kies je tussen het [Min](https://github.com/vdhamer/Photo-Club-Hub/blob/main/JSON/TemplateMin.level2.json) of [Max](https://github.com/vdhamer/Photo-Club-Hub/blob/main/JSON/TemplateMax.level2.json) bestand?
   > Het Min voorbeeldbestand toont hoe het eruit ziet als alle weglaatbare velden ontbreken.
   > Het is wel erg minimaal, dus je zult daarna enkele opties willen toevoegen.
   > Het Max voorbeeldbestand bevat juist alle beschikbare optionele velden.
   > Het is wel erg maximaal, dus je zult vervolgens enkele velden die je nog niet wilt of kunt invullen willen verwijderen.
   > Suggestie: start met een kopie van Min. En haal alle extra velden die je wilt toevoegen over vanuit Max.
   > Wees hierbij voorzichting, want de kans is groot dat je net een comma of haakje teveel meeneemt.
   > Het JSON formaat is daar (in tegenstelling tot HTML) heel kieskeurig over.
   > Gelukkig zijn foutjes straks snel opgespoord omdat JSON bestanden automatisch gecontrolleerd kunnen worden. Hier komen we zo op terug.

3. Pas de gegevens over de **club** (`club`) aan: `town`, `fullName`, `nickName`, en ook de locatie:
    > Tip: gebruik voor het aanpassen van het bestand [JSON Editor Online](https://jsoneditoronline.org).
    > Dat programma is bedoeld om zogenaamde "JSON" tekstbestanden aan te maken en controleert de basis JSON regels tijdens invoer.
    > Als alternatief kan je een algemene editor gebruiken zoals [Windows NotePad](https://nl.wikipedia.org/wiki/Notepad), [NotePad++](https://nl.wikipedia.org/wiki/Notepad%2B%2B) of [Sublime Text](https://nl.wikipedia.org/wiki/Sublime_Text).
    > NotePad controlleert de JSON conventiies niet. NotePad++ of Sublime Text wel (mits de bestandsnaam op .json eindigt).

    - Neem, indien beschikbaar, de vereiste `town`, `fullName`, `nickName`,`latitude` en `longitude`
      uit de bovenstaande tabel over. De gegevens zijn voor alle clubs in Brabant Oost (afdeling 16) en Drenthe Vechtdal (afdeling 03) te vinden in
      [clubsNL16.level1.json](https://.com/vdhamer/Photo-Club-Hub/blob/main/JSON/clubsNL16.level1.json) respectievelijk
      [clubsNL03.level1.json](https://.com/vdhamer/Photo-Club-Hub/blob/main/JSON/clubsNL03.level1.json).

4. Pas gegevens over de **clubleden** (`members`) aan: `givenName`, `infixName` en `familyName`.
    > Tip: met de [JSON Editor Online](https://jsoneditoronline.org) kan je de lijst van clubleden als tabel
    > bekijken en aanpassen. Dan kan je dubbelklikken op cellen die je wilt aanpassen,
    > en regels toevoegen of verwijderen via een menu (te vinden als "__⋮__").
  
    - De spelling van de namen van clubleden is belangrijk.
      Die namen worden namelijk gebruikt om te bepalen of twee personen in verschillende bestanden (clubs) wel of niet dezelfde persoon zijn.
      Wat de software betreft zijn zelfs "Jan de Vries" en "Jan De Vries" verschillende personen.
        - Jan de Vries voer je in als `"givenName": "Jan", "infixName": "de", "familyName": "Vries"`.
        - Max Verstappen voer je in als `"givenName": "Max", "infixName": "", "familyName": "Verstappen"`. Maar het kan ook als `"givenName": "Max", "familyName": "Verstappen"`.
    </br>
    
    > Tip: De lijst met leden hoeft niet in een keer compleet te zijn:
    > je kan dus eerst enkele leden toevoegen om de kijken of alles lukt.
    > En de lijst vervolgens completer maken in een volgende versie.

    - Het `featuredImage` veld mag later aangepast worden.
      Het bevat een webadres (URL) van een foto gemaakt door de fotograaf.
      Dat webadres moet een plaatje zijn, maar mag op een willekeurige locatie op het internet staan.
      Als `featuredImage` ontbreekt of het adres niet klopt, wordt er een oranje plaatje met een gestileerde "?" door de app getoond.
    - Het `photographerImage` veld kan later ingevuld worden.
      Het bevat het webadres (URL) van een foto met het gezicht van de fotograaf.
    </br>
    
    > Tip: Speciale lettertekens in namen (en elders) zijn toegestaan.
    > Bijvoorbeeld "Juriën" of "Saša". Je kunt ze bijvoorbeeld m.b.v. Google ergens vinden en vervolgens inkopiëeren.
 
5. Deze controlestap is alleen nodig als je [JSON Editor Online](https://jsoneditoronline.org) __niet__ gebruikt.
    - Er is bij [JSON Editor Online](https://jsoneditoronline.org) geen aparte JSON controle nodig.
      Het controleert namelijk voortdurend of de tekst voldoet aan de JSON basisregels en sommige fouten worden zelfs helemaal voorkomen.
    - Controle van de inhoud van een bestaand bestand kan ook door de text te kopiëren naar [JSON Editor Online](https://jsoneditoronline.org).
      Dit controleert de diverse JSON basisregels, en benoemt de eventuele fouten met het regelnummer waar de fout gevonden is.
        - JSON Editor Online wijst je op de eerste fout. Na correctie blijkt meteen of er meer fouten zijn.
        - Het JSON formaat let nogal nauw ten aanzien van komma's en openen en sluiten van haakjes en aanhalingstekens. Vandaar dat we hier uitgaan van een kloppend voorbeeldbestand.
        - Daarentegen is JSON totaal _niet_ kieskeurig wat betreft de hoeveelheid spaties, tabs of nieuwe regels.
          Inspringen van de tekst is wel heel handig voor menselijke lezers, maar de software analyseert de
          inhoud volledig aan de hand van de genoemde leestekens.
    </br>
    
    > Tip: het is handig om de leden op alfabetische volgorde (voornaam of achternaam) te zetten:
    > dan valt het makkelijke op als een lid dubbel op de lijst staat of juist ontbreekt.

6. **Stuur** ons het gemaakte `level2.json` bestand. Dat mag ook bij tussenversies. Wij reageren vaak binnen 24 uur.
    - Onze rol is om een de technische juistheid te bewaken en om hulp te bieden.
      Wij kijken niet of de aangeleverde gegevens fouten (zoals spelfouten) bevatten.
    - Voor de proefkonijnclubs zullen we het bestand op GitHub zetten en het bijbehorende adres (URL) terugmelden.
      Er zijn ook [instructies](https://github.com/vdhamer/Photo-Club-Hub/blob/main/Photo%20Club%20Hub/Documentation/GitHub_bestandsbeheer_NL.md)
      hoe een club _zelf_ zijn Level2 ledenbestand op [GitHub](https://github.com/vdhamer/Photo-Club-Hub) kan bijhouden.
      Dan kan een club zijn Level2 bestand aanpassen met minimale afhankelijkheid van derden.

7. **Controleer** of alles naar wens werkt via de [Photo Club Hub](https://www.fotobond-brabantoost.nl/nieuws/fotoclub-hub-app/) iOS app.
Of via een door ons [gegenereerde](https://github.com/vdhamer/Photo-Club-Hub-HTML/blob/main/.github/README.md) HTML pagina
als men niet zelf over een iPhone of iPad beschikt.

## Bonus informatie

### Het `Level2.json` formaat
<details><summary>Details (klik om uit te klappen)</summary></p>

- [JSON](https://en.wikipedia.org/wiki/JSON) is bekende standaard in de IT wereld.
[Hier](https://codebeautify.org/json-cheat-sheet) is een korte uitleg van JSON. In ons geval is zou het voldoende moeten zijn om nauwgezet de voorbeelden in
[TemplateMin.level2.json](https://github.com/vdhamer/Photo-Club-Hub/blob/main/JSON/TemplateMin.level2.json) en [TemplateMax.level2.json](https://github.com/vdhamer/Photo-Club-Hub/blob/main/JSON/TemplateMax.level2.json) te volgen.
Bij gebruikt van [JSON Editor Online](https://jsoneditoronline.org) is de kans op fouten klein.

- Alle informatie tussen de haakjes in het `optional: { }` gedeelte van het bestand mag eventueel weggelaten worden. Dat is geen JSON-conventie, maar een keus alleen voor deze app. 
Het zijn dus velden die je bij een tekstaanpassing alsnog kan toevoegen, bijvoorbeeld zodra de voordelen van de gegevens inmiddels duidelijk is, of omdat de vereiste gegevens inmiddels beschikbaar zijn.
</details></p>

### Invoervelden over clubleden
<details><summary>Details (klik om uit te klappen)</summary></p>

- Een gedetailleerde engeltalige omschrijven van alle ondersteunde velden in een 'level2.json' bestand is te vinden in [README.md file section](https://github.com/vdhamer/Photo-Club-Hub/blob/main/.github/README.md#level-2-adding-members).
- Wat betreft de belangrijkste velden over clubleden:
   - De velden `givenName` en `familyName` zijn verplicht. `infixName` is voor namen met tussenvoegsel zoals "Jaap van Zweden". Het onderscheid tussen tussenvoegsel en achternaam is relevant om op achternaam te sorteren (althans op zijn Nederlands, Duits, enz). Jaap is dan te vinden onder de Z in plaats van onder de "V".
       - Het is belangrijk om `givenName`, `infixName` en `familyName` juist in te vullen. Dit inclusief spelling, hoofdletters en eventuele speciale letters (“François”). Dit zorgt voor consistentie: als de naam voorkomt in een `level2.json` van een andere club, moet de software beslissen of het om dezelfde persoon gaat. Ander voorbeeld: de software bewaart wat de inhoud van een ingelezen `level2.json` bestand. Bij het opnieuw inlezen van dat bestand (al dan niet na aanpassingen), gaat het om dezelfde persoon? 
       - Bij moeilijke namen (like "François Smit", of zelfs "François Beelaerts van Blokland") zou je invoeren even kunnen uitstellen om te voorkomen dat de naam soms op de ene manier en soms op een andere manier gebeurt.
         Als je de persoon zelf vraagt ("de familienaam is Beelaerts van Blokland") voorkom je dit probleem. 
       - In principe kan de app met de volledige [Unicode](https://nl.wikipedia.org/wiki/Unicode) karakterset uit de voeten. Voor een enkele letter is dat vaak ok, maar voor volledige namen zoals Вікторія Кобленко wordt dat onhandig.
   - Voorlopig kan het `Level3URL` veld weggelaten worden (het dient voor verwijzingen naar Level 3 bestanden).
   - Men zal vaak het `featuredImage` veld vrij snel willen invullen. Een voorbeeld is daarom te vinden in de [TemplateMin.level2.json](https://github.com/vdhamer/Photo-Club-Hub/blob/main/JSON/TemplateMin.level2.json) bestand.
Het levert een voorbeeldplaatje op van het werk van een clublid.
   - Op termijn is het vast de moeite waard om nog enkele velden in te vullen:
       - `website` is het webadres van een portfolio website van de fotograaf. Voorbeeld: een site op [Glass.photo](http://glass.photo/vdhamer) dat geen direct verband heeft met een specifieke club.
         De iOS app en HTML generator maken met dit veld een klikbare link naar deze website.
       - `roles` bevat eventuele bestuursfuncties van het lid binnen de club. Een lid kan meerdere bestuurfuncties hebben.
           - Men hoeft niet te vermelden dat een lid een bestuursfunctie _niet_ heeft.
             Invoer zoals '"isSecretary": false` kan nodig zijn om te expliciet aan te geven dat iemand die vroeger secretaris was dat niet meer is.
       - `membershipStartDate`. Dit veld wordt momenteel alleen gebruikt in _Photo Club Hub HTML_ en niet in de iOS app.
       - `expertises` geven één of twee opvallendste expertisegebieden van de fotograaf aan. Er zijn [aparte instructies](https://github.com/vdhamer/Photo-Club-Hub/blob/main/Photo%20Club%20Hub/Documentation/Level2_expertise_NL.md) over hoe het `expertises` veld het beste te gebruiken.
- Het `maintainerEmail` veld is diegene die benaderd kan worden als er iets aan de hand is met dit JSON bestand.
  Vaak ik dat de website beheerder (b.v. admin@clubnaam.nl mits dat werkt), maar het zou een direct gmail account van een clublid kunnen zijn.
</details></p>

### Meer over JSON Editor Online
<details><summary>Details (klik om uit te klappen)</summary></p>

- Bovenaan het scherm staat iets over "inloggen" en "prijzen". Men kan die regel voor ons doel negeren: de gratis versie is voldoende. En de site doet vrijwel alles zonder je te registreren. Dat scheelt weer het onthouden van een extra wachtwoord.

- De site toont een linker en een rechter paneel. Die twee panelen kunnen verschillende bestanden (b.v. een voorbeeldbestand en een nieuw bestand) bevatten. Er zijn knopjes om de inhoud van het ene paneel naar het andere te copiëren. Dat kan je gebruiken om dezelfde JSON inhoud op 2 verschillende manieren tegelijk te bekijken. Of om een copie te maken en en de copie te gebruiken om de wijzingen in aan te brengen.

- In JSON wordt de volgorde van de elementen binnen een `[ ]` paar (=lijst) of `{ }` paar (=samenstelling) genegeerd. Bij het vergelijken van 2 versies van een bestand in [JSON Editor Online](https://jsoneditoronline.org) zal dus een verschil in volgorde niet als verschil in inhoud opgevat worden.

- Het is riskant om blindelings JSON Editor Online gedetecteerde fouten te laten herstellen ("Autorepair"). Dit lost welliswaar vaak de foutmelding op, maar vaak niet op de correcte manier. Op termijn gaan we dit oplossen via JSON Schema.

- Gebruikers van de Apple Safari browser (macOS, iPad) die de beschikbare horizontale schermruimte krap vinden kunnen de reclame aan de rechterkant verwijderen.
Dit gaat via de Safari [Hide distracting items](https://support.apple.com/nl-nl/guide/safari/ibrwb68cc4bf/mac) functie. Gebruikers van een groot scherm zullen hier minder behoefte aan hebben, maar het werkt ook op een groot scherm.
</details></p>

### Kan het eenvoudiger?
<details><summary>Details (klik om uit te klappen)</summary></p>

Dit is een cruciale vraag: wij willen de drempel voor een club om mee te doen zo laag mogelijk houden.
Maar er zijn 3 complicaties in dit specifieke geval.

Ten eerste hebben we niet de mankracht van b.v. een belangstingdienst: tenslotte laten zij gewone burgen ook gegevens
invullen die voornamelijk automatisch verwerkt worden ("makkelijker kunnen wij het niet maken").
Beperkte mankracht leidt richting hergebruik van bestaande softwaretechnologie (b.v. JSON en bijbehorende code).

Ten tweede, zijn wij huiverig voor oplossingen die een extra wachtwoord vereisen. 
Een mens heeft al zoveel wachtwoorden nodig, inloggen betekent extra stappen, en inlogpogingen leiden vaak tot problemen.
Bijvoorbeeld omdat het wachtwoord zoekgeraakt is, of omdat het wachtwoord gewijzigd moeten worden, of gedeeld moeten worden door 2 mensen. 
Dus ook daar willen we hergebruik maken van bestaande technologie die clubs al vaak gebruiken (b.v. Wordpress website).

Ten slotte willen wij voorkomen dat er kosten gemaakt worden. Vooral omdat dat veel organisatorisch gedoe geeft.
Dat sluit min of meer een centrale server uit.

Toekomstige versimpelingen sluiten we zeker niet uit. Maar dit vereist wel slimme ideeën, en de deskundigheid en energie om ze uit te voeren.
</details></p>
