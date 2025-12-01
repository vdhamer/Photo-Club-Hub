## Een level1.json bestand aanmaken voor een afdeling

Dit stappenplan beschrijft hoe men een lijst met clubs aan kan maken, bijvoorbeeld voor een Fotobond Afdeling.
Het resulterende bestand moet automatisch ingelezen kunnen worden door [Photo Club Hub](https://github.com/vdhamer/Photo-Club-Hub)
en [Photo Club Hub HTML](https://github.com/vdhamer/Photo-Club-Hub-HTML). Daarom zijn er eisen ten aanzien van het formaat ("Level 1" JSON).
Er zijn aparte instructies om lijsten met _clubleden_ ("Level 2") toe te voegen. Maar dat kan op een later moment gebeuren.

> 🕚 Het voor de allereerste keer aanmaken van een Level1 bestand met één of twee clubs zal misschien 1 uur kosten. \
> Die tijd is nodig om de aanpak te begrijpen en te ontdekken hoe met de vereiste software om te gaan. \
> Hierna zal aanvullen en aanpassen van de gegevens slechts minuten per club kosten.

1. Maak desgewenst een lokale kopie van de [XampleMin.level1.json](https://github.com/vdhamer/Photo-Club-Hub/blob/main/JSON/XampleMin.level1.json) ("Min") en    [XampleMax.level1.json](https://github.com/vdhamer/Photo-Club-Hub/blob/main/JSON/XampleMax.level1.json) ("Max") voorbeeldbestanden.
   _Min_ bevat een zo klein mogelijk voorbeeld. _Max_ is een voorbeeld met alle beschikbare opties. Bij zowel Min als Max is er een "download" icoon rechtsboven.

2. Maak een **kopie** van het [Max](https://github.com/vdhamer/Photo-Club-Hub/blob/main/JSON/XampleMax.level1.json) bestand en geef het een passende bestandsnaam:
   - Voor Afdeling #3 (Drenthe en Vechtstreek) zou je Afdeling03.level1.json kunnen kiezen. Gebruikers van de app zien de bestandsnaam niet.

   </br>

   > Tip: Je kunt desgewenst ook uitgaan van het [Min](https://github.com/vdhamer/Photo-Club-Hub/blob/main/JSON/XampleMin.level1.json) bestand ipv Max.
   > Het [Min](https://github.com/vdhamer/Photo-Club-Hub/blob/main/JSON/XampleMin.level1.json) bestand 
   > toont hoe het eruit ziet als bijna alle optionele velden ontbreken.
   > Dit betekent dat je extra velden die je wilt vullen moet toevoegen, bijvoorbeeld door die regels vanuit Max te kopiëren. 
   > Dit brengt iets meer risiko met zich mee omdat je bij het kopiëren misschien iets teveel of te weinig overneemt, of het op een verkeerde plek zet.
   > Dat is op zijn beurt niet heel erg: in stap 7 staat hoe je het bestand kunt controleren: het JSON formaat is nu eenmaal kieskeurig over haakjes en komma's.

3. Pas de naamgeving per **club** aan: `town`, `fullName`, en `nickName`:
    > Tip: gebruik voor het aanpassen van het bestand bijvoorbeeld [JSON Editor Online](https://jsoneditoronline.org).
    > Dat programma is speciaal bedoeld om zogenaamde "JSON" tekstbestanden aan te maken en te controlleren.
    > Als alternatief kan je een kale editor gebruiken zoals [Windows NotePad](https://nl.wikipedia.org/wiki/Notepad), [NotePad++](https://nl.wikipedia.org/wiki/Notepad%2B%2B) of [Sublime Text](https://nl.wikipedia.org/wiki/Sublime_Text).
    Microsoft Word is ongeschikt omdat het van nature een `.docx` bestandsformaat gebruikt.

4. Pas de lengtegraad/breedtegraad **club (`members`) aan: `givenName`, `infixName` en `familyName`.
    > Tip: met de [JSON Editor Online](https://jsoneditoronline.org) kan je de lijst van clubleden als tabel
    > bekijken en aanpassen. Dan kan je dubbelklikken op cellen die je wilt aanpassen,
    > en regels toevoegen of verwijderen via het een menu ("__⋮__").
  
    - De coördinaten zullen er voor Nederland uitzien als b.v. 51.12345 en 5.67890. Dus met een punt (Internationaal) ipv een comma. Nederlandse coordinaten zullen ongeveer 51 (graden noorderbreedte) en 5 graden (oosterbreedte) zijn (de grote zendmast bij IJselsteijn zit op 52.01043 en 5.05285).
    - Je kunt de coordinaten in maps.google.com uitlezen door op de juiste locatie rechts te klikken op de muis.
    - We kiezen normaal de locatie waar de club bijeenkomt of exposeert. Als dat ongewenst is, kan je een bekend
    plein of station kiezen in de desbetreffende locatie. Als alternatief kan je minder cijfers achter de comma gebruiken. Hiermee introduceer je bewust een minder nauwkeurige locatie die b.v. een paar kilometer verderop ligt.
    </br>
    
    > Tip: De lijst met clubs hoeft niet in een keer compleet te zijn:
    > je kan dus eerst 1 of 2 clubs toevoegen om de kijken of alles lukt.
    > En de lijst vervolgens completer maken in een uitgebreidere versie.

    </br>
    
5. Voeg indien mogelijk een opmerking (remark) toe. Gebruikt XampleMax.level1.json als voorbeeld.
    - Dit bevat iets bijzonders over de club. Het maakt de club minder anoniem en maakt de lezer nieuwsgierig.
    - Probeer het niet langer dan zeg 100 karakters te maken. Ongeveer de lengte van een Twitter/X berichtje.
    - Het voorbeeld bestand laat zien dat je die tekst in het Nederlands (NL) en Engels (EN) aanlevert. De Apple app kiest automatisch welke taal van toepassing is voor de gebruiker.
    
6. Voeg indien mogelijk het Fotobondnummer ("fotobondNumber") toe volgens het voorbeeld in XampleMax.level1.json.
    - dit bestaat uit 3 regel. Als een club geen lid is van de Fotobond, dan kan alles tussen "nlSpecific" en "}" verwijderd worden.
 
7. Deze controlestap is alleen nodig als je [JSON Editor Online](https://jsoneditoronline.org) __niet__ gebruikt.
    - Er is bij [JSON Editor Online](https://jsoneditoronline.org) geen aparte JSON controle nodig.
      Het controleert namelijk voortdurend of de tekst voldoet aan de JSON regels. Hiermee worden sommige fouten in het bestand voorkomen door in het rood te waarschuwen als er is mis is en in welke regel.
    - Om handmatig in deze stap een tekst bestand op technische fouten te controleren, kan je de volledige inhoud kopiëren naar [JSON Editor Online](https://jsoneditoronline.org).
      Dit controleert de diverse JSON basisregels, en benoemt de eventuele fouten met het regelnummer waar de fout gevonden is.
        - JSONlint wijst je op de eerste fout. Na correctie (kan binnen JSON Editor Online) zal blijken of er verderop nog fouten zijn.
        - Het JSON formaat let nogal nauw ten aanzien van komma's en openen en sluiten van haakjes en aanhalingstekens. Vandaar dat we hier nadruk leggen op uitgaan van een voorbeeldbestand.
        - Daarentegen is JSON totaal _niet_ kieskeurig wat betreft de hoeveelheid spaties, tabs of nieuwe regels.
          Inspringen van de tekst is heel nuttig voor menselijke lezers, maar de software analyseert de
          inhoud volledig aan de hand van de genoemde leestekens.
    </br>
    
    > Tip: het is handig om de clubs in alfabetische volgorde van __town__ (gemeente) te zetten:
    > dan valt het makkelijker op als een club dubbel op de lijst voorkomt. Of als een club onbedoeld ontbreekt. 

8. **Stuur** ons het gemaakte `level1.json` bestand. Dat mag ook bij tussenversies. Wij zullen proberen binnen 24 uur te reageren.
    - Onze rol is om een de _technische_ juistheid te bewaken en om hulp te bieden.
      Wij kijken niet of de aangeleverde clubinformatie zelf klopt. Correcties naderhand kunnen altijd nog.
      In ieder geval kan je clubs toevoegen.
    - Dan zetten wij het bestand op een webserver zetten en regelen de integratie met beide versies van de app.
      In de toekomst komt er wellicht ondersteuning om het bestand op een eigen locatie online te zetten.
      Dan vindt de app dit via een vast adres. Maar kan het bestand bijgewerkt worden zonder centrale ondersteuning.

9. **Controleer** of alles naar wens werkt via de [Photo Club Hub](https://www.fotobond-brabantoost.nl/nieuws/fotoclub-hub-app/) iOS app.
Of via een door ons [gegenereerde](https://github.com/vdhamer/Photo-Club-Hub-HTML/blob/main/.github/README.md) HTML pagina die bereikbaar is onder [clubs](https://www.fcDeGender.nl/clubs).

## Bonus informatie

### Het `Level2.json` formaat
<details><summary>Details (klik om uit te klappen)</summary></p>

- [JSON](https://en.wikipedia.org/wiki/JSON) is heel bekende standaard in de IT wereld.
[Hier](https://codebeautify.org/json-cheat-sheet) is een korte uitleg van JSON. In ons geval is zou het voldoende moeten zijn om nauwgezet de voorbeelden in
[XampleMin.level2.json](https://github.com/vdhamer/Photo-Club-Hub/blob/main/JSON/XampleMin.level2.json) en [XampleMax.level2.json](https://github.com/vdhamer/Photo-Club-Hub/blob/main/JSON/XampleMax.level2.json) te volgen.
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
   - Men zal vaak het `featuredImage` veld vrij snel willen invullen. Een voorbeeld is daarom te vinden in de [XampleMin.level2.json](https://github.com/vdhamer/Photo-Club-Hub/blob/main/JSON/XampleMin.level2.json) bestand.
Het levert een voorbeeldplaatje op van het werk van een clublid.
   - Op termijn is het vast de moeite waard om nog enkele velden in te vullen:
       - `website` is het webadres van een portfolio website van de fotograaf. Voorbeeld: een site op [Glass.photo](http://glass.photo/vdhamer) dat geen direct verband heeft met een specifieke club.
         De iOS app en HTML generator maken met dit veld een klikbare link naar deze website.
       - `roles` bevat eventuele bestuursfuncties van het lid binnen de club. Een lid kan meerdere bestuurfuncties hebben.
           - Men hoeft niet te vermelden dat een lid een bestuursfunctie _niet_ heeft.
             Invoer zoals '"isSecretary": false` kan nodig zijn om te expliciet aan te geven dat iemand die vroeger secretaris was dat niet meer is.
       - `membershipStartDate`. Dit veld wordt momenteel alleen gebruikt in _Photo Club Hub HTML_ en niet in de iOS app.
       - `expertises` geven één of twee opvallendste expertisegebieden van de fotograaf aan. Er zijn [aparte instructies](https://github.com/vdhamer/Photo-Club-Hub/blob/main/Photo%20Club%20Hub/Documentation/Level2_expertise_NL.md) over hoe het `expertises` veld het beste te gebruiken.
- Het `contactEmail` veld is diegene die benaderd kan worden als er iets aan de hand is met dit JSON bestand.
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
