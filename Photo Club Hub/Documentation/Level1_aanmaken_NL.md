## Een level1.json bestand aanmaken voor een Fotobond afdeling

Dit stappenplan beschrijft hoe men een lijst met clubs aan kan maken, bijvoorbeeld voor een Fotobond Afdeling.
Het resulterende bestand is bedoeld om automatisch ingelezen te worden door [Photo Club Hub](https://github.com/vdhamer/Photo-Club-Hub)
en [Photo Club Hub HTML](https://github.com/vdhamer/Photo-Club-Hub-HTML). Daarom zijn er eisen ten aanzien van het formaat ("Level 1" JSON).
Er bestaan andere instructies om lijsten met _clubleden_ ("Level 2" JSON) toe te voegen. Level 2 kan op een later moment aangeleverd worden.

> 🕚 Het voor de allereerste keer aanmaken van een Level1 bestand met één of twee clubs zal misschien 1 uur kosten.
> Die tijd is nodig om de aanpak te begrijpen en te ontdekken hoe met de vereiste software om te gaan.
> Hierna zal aanvullen en aanpassen van de gegevens slechts minuten per club kosten.

1. Maak desgewenst een lokale kopie van de [TemplateMin.level1.json](https://github.com/vdhamer/Photo-Club-Hub/blob/main/JSON/TemplateMin.level1.json) ("Min") en    [TemplateMax.level1.json](https://github.com/vdhamer/Photo-Club-Hub/blob/main/JSON/TemplateMax.level1.json) ("Max") voorbeeldbestanden.
   _Min_ bevat een zo klein mogelijk voorbeeld. _Max_ is een voorbeeld met alle beschikbare opties. Bij zowel Min als Max is er een "download" icoon rechtsboven.

2. Maak een **kopie** van het [Max](https://github.com/vdhamer/Photo-Club-Hub/blob/main/JSON/TemplateMax.level1.json) bestand en geef het een passende bestandsnaam:
   - Voor Afdeling #3 (Drenthe - Vechtdal) zou je `clubsNL03.level1.json` kunnen kiezen. Gebruikers van de app zien de bestandsnaam overigens niet.

   </br>

   > Tip: Je kunt desgewenst ook uitgaan van het [Min](https://github.com/vdhamer/Photo-Club-Hub/blob/main/JSON/TemplateMin.level1.json) bestand ipv Max.
   > Het [Min](https://github.com/vdhamer/Photo-Club-Hub/blob/main/JSON/TemplateMin.level1.json) bestand 
   > toont hoe het eruit ziet als bijna alle optionele invulvelden ontbreken.
   > Dit betekent dat je extra velden die je wilt vullen moet toevoegen, bijvoorbeeld door die regels vanuit Max te kopiëren. 
   > Dit brengt iets meer risiko met zich mee omdat je bij het kopiëren misschien iets teveel of te weinig overneemt, of het op een verkeerde plek zet.
   > Dat is op zijn beurt niet heel erg: in stap 7 staat hoe je het bestand kunt controleren: het JSON formaat is nu eenmaal kieskeurig over haakjes en komma's.

3. Pas de naamgeving per **club** aan: `town`, `fullName`, en `nickName`:
    > Tip: gebruik voor het aanpassen van het bestand bijvoorbeeld [JSON Editor Online](https://jsoneditoronline.org).
    > Dat programma is speciaal bedoeld om zogenaamde "JSON" tekstbestanden aan te maken en te controlleren.
    > Als alternatief kan je een kale editor gebruiken zoals [Windows NotePad](https://nl.wikipedia.org/wiki/Notepad), [NotePad++](https://nl.wikipedia.org/wiki/Notepad%2B%2B) of [Sublime Text](https://nl.wikipedia.org/wiki/Sublime_Text).
    Microsoft Word is ongeschikt omdat het van nature een `.docx` bestandsformaat gebruikt.

    - Voor de verkorte naam, `nickName`, gebruiken we een soort conventie zoals `fcDenDungen` (voor "Fotoclub Den Dungen") of `fgWaalre` (voor "Fotogroep Waalre"). 
    Deze nickname wordt vooral intern gebruikt (Level 2 bestandsnamen).

4. Pas de locatie van de club aan (`coordinates`):
    - De coördinaten worden gebruikt om de nominale ligging van een club op landkaartjes aan te geven. Dan kan je zien wat in de buurt van wat is. De app werkt _niet_ met een traditioneel adres.
    - De coördinaten zullen er voor Nederland uitzien als b.v. 51.12345 en 5.67890. Dus met een punt ipv een komma. Nederlandse coordinaten zullen rond de 51 graden noorderbreedte en 5 graden oosterbreedte zijn (de grote zendmast/kerstboom onder Utrecht staat op 52.01043 en 5.05285).
    - Je kunt de coordinaten bijvoorbeeld met [maps.google.com](https:/maps.google.com) uitlezen door op het gekozen adres rechts-te-klikken met de muis.
    - We kiezen normaal de locatie waar de club bijeenkomt of exposeert. Als dat ongewenst is, kan je een bekend
    plein, station of monument in de buurt kiezen. Als alternatief kan je minder cijfers achter de comma gebruiken. Hiermee introduceer je een minder nauwkeurige locatie die b.v. een kilometer verderop ligt.
    - Zou je `coordinates` weglaten, dan wordt de club weergeven op coordinaten 0, 0. Dat is midden in zee bij West Africa. Door gebrek aan eilanden zie je in de app een landkaart met alleen blauwe oceaan op de evenaar.
    </br>
    
    > Tip: De lijst met clubs hoeft niet in een keer compleet te zijn:
    > je kan dus eerst 1 of 2 clubs toevoegen om de kijken of alles lukt.
    > En de lijst later completer maken in een volgende versie.
    
6. Voeg bij voorkeur een opmerking (`remark`) toe.
    - Dit benadrukt iets bijzonders over deze club. Het maakt de informatie wat interessanter om door te bladeren. Praktische informatie mag uiteraard ook. Vermijdt een standaard zin die voor vrijwel alle clubs van toepassing is (dus niet "wij steven ernaar om betere foto's te maken, maar zijn ook best gezellig").
    - Probeer de tekst niet langer dan 100 karakters te maken (slechts een richtlijn). Dat is ongeveer de lengte van een Twitter/X "tweet".
    - `Remark` bevat zowel een Nederlandse (NL) als een Engelstalige (EN) vertaling. De iOS app kiest automatisch de juiste taal op basis van de iOS instellingen.
    
7. Voeg voor aangesloten clubs hun Fotobondnummer ("fotobondNumber") toe volgens het voorbeeld in TemplateMax.level1.json.
    - Dit bestaat uit 3 tekstregels. Als een club geen lid is van de Fotobond, dan dient men die 3 regels weg te laten: hiermee weet de app welke clubs lid zijn van de Fotobond.
 
8. Deze controlestap is vooral nuttig als je [JSON Editor Online](https://jsoneditoronline.org) __niet__ gebruikt.
    - Er is bij [JSON Editor Online](https://jsoneditoronline.org) geen aparte JSON controle nodig.
      Het controleert namelijk voortdurend of de tekst voldoet aan de JSON spelregels.
      Hiermee worden bepaalde invoerfouten meteen als rode waarschuwing gesignaleerd, inclusief het regelnummer van de fout.
    - Om handmatig in deze stap een tekstbestand op dit soort fouten te controleren, kan je de volledige inhoud kopiëren naar [JSON Editor Online](https://jsoneditoronline.org).
        - JSON Editor Online vindt de eerste fout. Na correctie (kan binnen JSON Editor Online) gaat het op zoek naar een volgende fout.
        - Het JSON formaat let nogal nauw ten aanzien van komma's, dubbele punten, openen/sluiten van haakjes en aanhalingstekens. 
          Vandaar dat we hier aanraden om uit te gaan van een voorbeeldbestand.
        - Daarentegen is JSON totaal _niet_ kieskeurig wat betreft de hoeveelheid spaties, tabs of nieuwe regels.
          Inspringen van de tekst is heel nuttig voor menselijke lezers, maar de software analyseert de
          inhoud volledig aan de hand van de genoemde leestekens.
    </br>
    
    > Tip: het is handig om de clubs in alfabetische volgorde van __town__ (gemeente) in het Level 1 bestand te zetten:
    > dan valt het op als een club dubbel op de lijst voorkomt of als een club per ongeluk ontbreekt.

9. **Stuur** ons het gemaakte `level1.json` bestand. Dat mag ook een tussentijdse versie zijn. Wij zullen proberen binnen 24 uur te reageren.
    - Onze rol is om een de _technische_ juistheid te bewaken en om hulp te bieden.
      Wij kijken niet of de aangeleverde clubinformatie zelf correct is. Correcties en aanvullingen kunnen altijd naderhand.
    - Wij zetten, na technische controle, het bestand op een webserver en regelen waar nodig de integratie met de app.
      In de toekomst komt er (vroeger of later) de mogelijkheid om een Level 1 bestand op een eigen locatie online te zetten.
      Dan vindt de app het bestand op een vast adres. Maar kan het bestand "lokaal" bijgewerkt worden zonder centrale betrokkenheid.

10. **Controleer** of alles naar wens werkt via de [Photo Club Hub](https://www.fotobond-brabantoost.nl/nieuws/fotoclub-hub-app/) iOS app.
Of via een door ons gegenereerde webpagina die bereikbaar is vanuit [/clubs](https://www.fcDeGender.nl/clubs).

## Hoe werkt `Include`?

Hierboven is beschreven hoe een nieuwe `onzenaam.level1.json` bestand aan te maken.

Maar er zijn nog 2 kanttekeningen:

- de app kan niet zondermeer weten niet dat het `onzenaam.level1.json` zou moet laden.
Dit wordt opgelost doordat er een ander bestand is met een verwijzing naar `onzenaam.level1.json`.
- het bestand `onzenaam.level1.json` kan zelf ook verwijzigingen bevatting naar additionele Level 1 bestanden.

Beide truukjes gebruiken één en hetzelfde truuk: ieder Level 1 bestand kan via `level1URLIncludes` opgeven dat er meer onderliggende Level 1 bestanden geladen dienen te worden.
Alleen het allereerste (hoogste, `root.level1.json`) bestand wordt gevonden via een vaste naam en locatie (URL). We gaat hier nu iets dieper op in: 

### Opknippen van level 1 bestanden

Hier is een voorbeeld van een bestand dat `clubsNL.level1.json` heet. Het dekt alle club in Nederland direct of indirect af:

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

In dit geval bevat het geen losse clubs (wat wel kan), maar bevat alleen verwijzingen naar 2 onderliggende bestanden: `clubNLS03.level1.json` en `clubsNL16.level1.json`.
Bij het inlezen van `clubsNL.level1.json` zullen de apps kijken of er clubs instaan (in dit geval niet) en de beide genoemde lagere Level 1 bestanden inlezen.
Voor de gebruikers van de app is er geen verschil tussen een `clubsNL.level1.json` bestand met 80 clubs en een `clubsNL.level1.json` bestand met 2 verwijzingen 
naar bestanden die samen die 80 bestanden bevatten.

Het voordeel van opsplitsen is vooral organisatisch: door het opkippen van een lange lijst met clubs in meedere kortere deellijsten
kan je duidelijker krijgen wie welk deelbestand onderhoudt (`maintainerEmail`).

### Vinden van alle Level 1 bestanden

In bovenstaand voorbeeld wordt `clubsNL03.level1.json` gevonden vanuit `clubsNL.level1.json` (all clubs in Nederland).
Op een soortgelijke manier kan `clubsNL.level1.json` gevonden worden vanuit een bestand dat `cubs.level1.json` zou kunnen heten (alle clubs ter wereld).
Op zijn beurt wordt `clubs.level1.json` gevonden vanuit een bestand dat `root.level1.json` heet. Dat bestand kan de software vinden en dat bestand dient altijd aanwezig te zijn.

### Samenvattend

Vanuit een vaste naam `root_.level1.json` worden via 0 of meer include verwijzingen alle Level 1 bestand gevonden en ingelezen.
In deze boomstructuur is trouwens een tak van de boom dat over fotomusea gaat. Dus de huidige inhoud van 'root.level1.json' is

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

Op termijn zal de naam `root_.level1.json` veranderen in `root.level1.json`. Dit onderscheid is omdat oudere versies
van de apps nog geen `level1URLIncludes` hadden. Dit leidde tot lange bestanden met alle clubs en alle fotomusea.

## Bonus informatie

### Het `Level1.json` formaat
<details><summary>Details (klik om uit te klappen)</summary></p>

- [JSON](https://en.wikipedia.org/wiki/JSON) is zeer bekende standaard in de IT wereld.
[Hier](https://codebeautify.org/json-cheat-sheet) is een korte uitleg van JSON. In ons geval is zou het voldoende moeten zijn om nauwgezet de beschikbare voorbeelden te volgen:
[TemplateMax.level1.json](https://github.com/vdhamer/Photo-Club-Hub/blob/main/JSON/TemplateMax.level1.json) en [TemplateMin.level1.json](https://github.com/vdhamer/Photo-Club-Hub/blob/main/JSON/TemplateMin.level1.json) te volgen.
Bij gebruikt van [JSON Editor Online](https://jsoneditoronline.org) is de kans op dit soort fouten klein.

- Alle informatie tussen de haakjes in het `optional: { }` gedeelte van het bestand mag weggelaten worden. Dat is geen JSON-conventie, maar een keus binnen deze app. 
Het zijn dus velden die men later kan toevoegen, bijvoorbeeld omdat de vereiste gegevens inmiddels beschikbaar zijn.
</details></p>

### Meer over JSON Editor Online
<details><summary>Details (klik om uit te klappen)</summary></p>

- Bovenaan het scherm staat iets over "inloggen" en "prijzen". Men kan dat voor ons doel negeren: de gratis versie is meer dan genoeg. De site doet vrijwel alles zonder je te registreren. Dat scheelt weer het onthouden van een extra wachtwoord.

- De site toont een linker en een rechter paneel. Die twee panelen kunnen verschillende bestanden (b.v. een voorbeeldbestand en een nieuw bestand) bevatten. Er zijn knopjes om de inhoud van het ene paneel naar het andere te kopiëren. Dat kan je gebruiken om dezelfde JSON inhoud op 2 verschillende manieren tegelijk te bekijken. Of om een kopie te maken en die kopie te gebruiken om de wijzingen in aan te brengen.

- In JSON wordt de __volgorde__ van de elementen binnen een `[ ]` paar (=lijst) of `{ }` paar (=samenstelling) genegeerd. Bij het vergelijken van 2 versies van een bestand in [JSON Editor Online](https://jsoneditoronline.org) zal dus een verschil in volgorde __niet__ als verschil in inhoud opgevat worden.

- Het is riskant om blindelings JSON Editor Online gedetecteerde fouten te laten herstellen ("Autorepair"). Dit lost verhelpt vaak de foutmelding, maar vaak niet op de correcte manier. Op termijn gaan we dit oplossen (JSON Schema).

- Gebruikers van de Apple Safari browser (macOS, iPad) die de beschikbare horizontale schermruimte krap vinden kunnen de reclame aan de rechterrand verwijderen.
Dit gaat via de Safari [Hide distracting items](https://support.apple.com/nl-nl/guide/safari/ibrwb68cc4bf/mac) functie. Gebruikers van een groot scherm zullen hier minder behoefte aan hebben. Maar laptops hebben bijvoorbeeld kleinere schermen.
</details></p>

### Kan het eenvoudiger?
<details><summary>Details (klik om uit te klappen)</summary></p>

Dit is een belangrijk punt: wij willen de drempel voor een club om mee te doen zo laag mogelijk krijgen.
Maar er zijn 3 complicaties in dit specifieke geval.

Ten eerste hebben we momenteel niet de mankracht. De belastingdienst lukt het wel om gewone burgen gegevens
in te laten vullen die vervolgens automatisch verwerkt worden ("makkelijker kunnen wij het niet maken").
Er werkt een heel team bij de belastingdienst aan hun Web app.

Ten tweede, zijn wij huiverig voor oplossingen die een extra wachtwoord vereisen. 
Een mens heeft al zoveel wachtwoorden nodig, inloggen betekent extra stappen, en die stappen leiden vaak tot problemen.
Bijvoorbeeld omdat het wachtwoord zoekgeraakt is, of omdat het wachtwoord gewijzigd moeten worden, of gedeeld moeten worden door 2 mensen. 
Dus ook daar willen we hergebruik maken van bestaande technologie die clubs al vaak gebruiken (b.v. Wordpress website).

Ten derde willen wij voorkomen dat er kosten gemaakt worden. Kosten geven organisatorisch gedoe ("kan het niet goedkoper").

Toekomstige versimpelingen sluiten we zeker niet uit. Maar dit vereist wel slimme ideeën, en de deskundigheid en energie om ze uit te voeren.
</details></p>
