## Een level1.json bestand aanmaken voor een Fotobond afdeling

Dit stappenplan beschrijft hoe men een lijst met clubs aan kan maken, bijvoorbeeld voor een Fotobond Afdeling.
Het resulterende bestand is bedoeld om automatisch ingelezen te worden door [Photo Club Hub](https://github.com/vdhamer/Photo-Club-Hub)
en [Photo Club Hub HTML](https://github.com/vdhamer/Photo-Club-Hub-HTML). Daarom zijn er eisen ten aanzien van het formaat ("Level 1" JSON).
Er bestaan andere instructies om lijsten met _clubleden_ ("Level 2" JSON) toe te voegen. Level 2 kan op een later moment aangeleverd worden.

> 🕚 Het voor de allereerste keer aanmaken van een Level1 bestand met één of twee clubs zal misschien 1 uur kosten.
> Die tijd is nodig om de aanpak te begrijpen en te ontdekken hoe met de vereiste software om te gaan.
> Hierna zal aanvullen en aanpassen van de gegevens slechts minuten per club kosten.

1. Maak desgewenst een lokale kopie van de [TemplateMin.level1.json](https://github.com/vdhamer/Photo-Club-Hub/blob/main/JSON/TemplateMin.level1.json) ("Min") en    [TemplateMax.level1.json](https://github.com/vdhamer/Photo-Club-Hub/blob/main/JSON/TemplateMax.level1.json) ("Max") voorbeeldbestanden.
   _Min_ bevat een zo klein mogelijk voorbeeld. _Max_ is een voorbeeld met vrijwel alle beschikbare opties. Het volgen van de Min en de  Max links geeft een "download" icoon rechtsboven.

2. Maak een **kopie** van het [Max](https://github.com/vdhamer/Photo-Club-Hub/blob/main/JSON/TemplateMax.level1.json) bestand en geef het een passende bestandsnaam:
   - Voor Afdeling #3 (Drenthe - Vechtdal) zou je `clubsNL03.level1.json` kunnen kiezen.

   </br>

   > Tip: Je kunt desgewenst ook uitgaan van het [Min](https://github.com/vdhamer/Photo-Club-Hub/blob/main/JSON/TemplateMin.level1.json) bestand ipv Max.
   > Het [Min](https://github.com/vdhamer/Photo-Club-Hub/blob/main/JSON/TemplateMin.level1.json) bestand 
   > toont hoe het eruit ziet als bijna alle optionele invulvelden ontbreken.
   > Dit betekent dat je extra velden die je wilt vullen zelf moet toevoegen, bijvoorbeeld door die regels vanuit Max te kopiëren. 
   > In principe kunnen bij dit kopieren fouten gemaakt worden, door iets teveel of iets te weinig over te nemen. Of door de extra gegevens op een verkeerde plek toe te voegen.
   > Dat is echter niet heel erg: in stap 7 staat hoe je het bestand kunt controleren. Het JSON formaat is nu eenmaal kieskeurig over haakjes en komma's.

3. Pas de naamgeving per **club** aan: `town`, `fullName`, en `nickName`:
    > Tip: gebruik voor het aanpassen van het bestand bijvoorbeeld [JSON Editor Online](https://jsoneditoronline.org).
    > Dat programma is speciaal bedoeld om zogenaamde "JSON" tekstbestanden aan te maken en te controlleren.
    > Als alternatief kan je een kale editor gebruiken zoals [Windows NotePad](https://nl.wikipedia.org/wiki/Notepad), [NotePad++](https://nl.wikipedia.org/wiki/Notepad%2B%2B) of [Sublime Text](https://nl.wikipedia.org/wiki/Sublime_Text).
    Microsoft Word of Apple Pages zijn ongeschikt omdat het van nature een eigen bestandsformaat gebruiken (.docx en .pages).

    - Voor de verkorte naam, `nickName`, gebruiken we een soort conventie zoals `fcDenDungen` (voor "Fotoclub Den Dungen") of `fgWaalre` (voor "Fotogroep Waalre"). 
    Deze nickname wordt vooral gebruikt voor Level 2 bestandsnamen en voor webadressen.

4. Pas de locatie van de club aan (`coordinates`):
    - De coördinaten worden gebruikt om de nominale ligging van een club op landkaartjes aan te geven. Dan kan je clubs in de buurt ontdekken. De app werkt _niet_ met een traditioneel adres.
    - De coördinaten zullen er voor Nederland uitzien als b.v. 51.12345 en 5.67890. Dus met een punt ipv een komma. En waarden hebben rond de 52 en 5.
    - Je kunt de coordinaten met [maps.google.com](https:/maps.google.com) uitlezen door op het gekozen adres rechts-te-klikken met de muis.
    - We kiezen normaal de locatie waar de club bijeenkomt of exposeert. Als dat ongewenst is, kan je een bekend
    plein, station of monument in de buurt kiezen. Als alternatief kan je minder cijfers achter de comma gebruiken. Hiermee introduceer je een minder nauwkeurige locatie die b.v. een kilometer verderop ligt.
    - Zou je per ongeluk `coordinates` weglaten, dan wordt de club weergeven op coordinaten 0, 0. Dat is midden in zee bij West Africa. Dan zie je in de app een landkaart met alleen blauwe oceaan op de evenaar ten westen van Africa.
    </br>
    
    > Tip: De lijst met clubs hoeft niet in een keer compleet te zijn:
    > je kan dus eerst 1 of 2 clubs toevoegen om de kijken of alles goed gaat.
    > En de lijst vervolgens completer maken in een volgende versie.
    
6. Voeg bij voorkeur een opmerking (`remark`) toe.
    - Dit benadrukt iets bijzonders over deze club. Het maakt de informatie wat interessanter om door te bladeren. Praktische informatie mag uiteraard ook.
      Vermijdt een standaard zin die voor vrijwel alle clubs van toepassing is (dus niet "wij steven ernaar om betere foto's te maken" of "wij vinden onzelf best gezellig").
    - Probeer de tekst niet langer dan 100 karakters te maken (slechts een richtlijn). Dat is ongeveer de lengte van een Twitter/X "tweet".
    - `Remark` bevat minimaal een Nederlandse (NL) en een Engelstalige (EN) vertaling. De iOS app kiest automatisch de weer te geven taal op basis van de iOS instellingen.
    
7. Voeg voor aangesloten clubs hun vier-cijferig Fotobondnummer ("fotobondNumber") toe. Zie TemplateMax.level1.json voor voorbeelden.
    - Dit bestaat uit 3 tekstregels. Als een club geen lid is van de Fotobond, dan dient men die 3 regels weg te laten: hiermee weet de app of een club aangesloten is bij de Fotobond.
 
8. Deze controlestap is vooral nuttig als je [JSON Editor Online](https://jsoneditoronline.org) __niet__ gebruikt.
    - Er is bij [JSON Editor Online](https://jsoneditoronline.org) geen aparte JSON controle nodig.
      Het controleert namelijk tijdens invoer continue of de tekst voldoet aan de JSON spelregels.
      Hiermee worden bepaalde invoerfouten meteen als rode waarschuwing gesignaleerd, inclusief het regelnummer waar de fout gevonden is.
    - Om handmatig in deze stap een tekstbestand op dit soort fouten te controleren, kan je de volledige inhoud kopiëren naar [JSON Editor Online](https://jsoneditoronline.org).
        - JSON Editor Online vindt de eerste fout. Na correctie (kan binnen JSON Editor Online) gaat het op zoek naar een volgende fout.
        - Het JSON formaat let nogal nauw ten aanzien van komma's, dubbele punten, openen/sluiten van haakjes en aanhalingstekens. 
          Vandaar dat we hier aanraden om uit te gaan van een voorbeeldbestand.
        - Daarentegen is JSON totaal _niet_ kieskeurig wat betreft de hoeveelheid spaties, tabs of nieuwe regels.
          Inspringen van de tekst is heel nuttig voor menselijke lezers, maar de software analyseert de
          inhoud volledig aan de hand van de genoemde leestekens. Voorbeeld: het fragment
          ``` json
          "coordinates": {"latitude": 51.39184, "longitude": 5.46144}
          ```
          en
          ``` json
          "coordinates": {
             "latitude": 51.39184,
             "longitude": 5.46144
          }
          ```
          zijn wat de software (en de JSON standaard) betreft gelijkwaardig.
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

## Hoe zit het met `level1URLIncludes`?

Hierboven is beschreven hoe met bijvoorbeeld een nieuwe bestand gemaamd `naam.level1.json` bestand aan te maken.

Maar er zijn nog 2 kanttekeningen:

1. de app weet niet zondermeer dat het het bestand `naam.level1.json` zou moet laden.
De app kan dit ontdekken als er een _ander_ bestand is met een verwijzing naar het `naam.level1.json` bestand.
2. het bestand `naam.level1.json` kan zelf ook verwijzigingen bevatting naar andere Level 1 bestanden.
Deze andere bestandene kunnen beschouwd worden als integraal deel ("include") van `naam.level1.json`.

Beide kanttekeningen gebruiken dus één en hetzelfde mechanisme:
ieder Level 1 bestand kan via `level1URLIncludes` opgeven dat er extra onderliggende Level 1 bestanden geladen moeten worden.
Alleen het allereerste (hoogste, `root.level1.json`) bestand wordt gevonden via een vaste naam en locatie (URL).
We gaat hier nu iets dieper op in: 

### Opknippen van Level 1 bestanden

Hier is een voorbeeld van een bestand dat `clubsNL.level1.json` heet. Het bevat direct of indirect de club in Nederland af:

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

In dit geval bevat het geen losse clubs,
maar bevat alleen verwijzingen naar 2 onderliggende bestanden: `clubNLS03.level1.json` en `clubsNL16.level1.json`.
Het kan uitgebreid worden met meer verwijzingen.
Bij het inlezen van `clubsNL.level1.json` zullen de apps kijken of er clubs direct in het bestand staan
(in dit geval niet) en bovendien de beide genoemde lagere Level 1 bestanden inlezen.

Voor de gebruikers van de app is er geen verschil tussen een `clubsNL.level1.json` bestand met 80 clubs
en een `clubsNL.level1.json` bestand met 2 verwijzingen  naar bestanden die samen die 80 clubs bevatten.

Het voordeel van opsplitsen is vooral organisatisch:
door het opkippen van een lange lijst met clubs in kortere deellijsten
kan je duidelijk afspreken (en via `maintainerEmail` zien) wie welk deelbestand onderhoudt.

### Vinden van alle Level 1 bestanden

In bovenstaand voorbeeld wordt `clubsNL03.level1.json` gevonden via een verwijzing vanuit `clubsNL.level1.json` (clubs in Nederland).
Op een soortgelijke manier kan `clubsNL.level1.json` gevonden worden vanuit een bestand dat `clubs.level1.json` heet (clubs in alle landen).
Op zijn beurt wordt `clubs.level1.json` gevonden vanuit een bestand dat `root_.level1.json` of `root.level1.json` heet. 
Dat bestand is het enige level1.json dat de software vindt via een vaste naam en locatie.
Alle andere level1.json bestanden worden via verwijzingen gevonden.

### Samenvatting Include mechanisme

De apps lezen vanuit een vaste naam zoals `root.level1.json` via verwijzingen alle relevante Level 1 bestanden in.
In deze boomstructuur van bestanden vindt men naast een tak (`clubsNL.level1.json`) met Nederlandse clubs
ook de tak (`museums.level1.json`) met internationale fotomusea. Dat ziet er momenteel zo uit:

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

Hierbij verwijst `clubsNL.level1.json` op zijn beurt door naar de regionale afdelingen van de Nederlandse Fotobond.
De afdelingen bevatten de lijsten met `clubs` per afdeling.

Opgelet: deze boomstructuur dient vooral om de invoergegevens beheersbaar te houden. 
Momenteel wordt de boomstructuur tijdens het inlezen niet bewaard of aan de gebruiker getoond.

Er zijn overigens tijdelijk twee versies van het start bestand:
`root_.level1.json` (voor nieuwe versies van de software) en `root.level1.json` voor oude versies van de software.

## Bonusinformatie

### Het `Level1.json` formaat
<details><summary>Details (klik om uit te klappen)</summary></p>

- [JSON](https://en.wikipedia.org/wiki/JSON) is zeer bekende standaard in de IT wereld.
[Hier](https://codebeautify.org/json-cheat-sheet) is een korte uitleg van JSON.
Voor ons doel is het waarschijnlijk voldoende om nauwgezet de beschikbare voorbeeldbestanden te volgen:
[TemplateMax.level1.json](https://github.com/vdhamer/Photo-Club-Hub/blob/main/JSON/TemplateMax.level1.json) en
[TemplateMin.level1.json](https://github.com/vdhamer/Photo-Club-Hub/blob/main/JSON/TemplateMin.level1.json).

- Alle informatie tussen de haakjes in het `optional: { }` gedeelte van het bestand mag weggelaten worden.
Dat is geen JSON-conventie, maar een keus binnen deze app. 
Het zijn dus velden die men later kan toevoegen, bijvoorbeeld omdat zodra de vereiste gegevens inmiddels verzameld zijn.
</details></p>


### Invoervelden over clubs
<details><summary>Details (klik om uit te klappen)</summary></p>

- Een gedetailleerde Engeltalige omschrijven van alle ondersteunde velden in een 'level1.json' bestand is te vinden in het [README.md bestand](https://github.com/vdhamer/Photo-Club-Hub/blob/main/.github/README.md#level-1-adding-clubs).

- Alle velden die onder `clubs:` een individuele fotoclub omschrijven in een Level 1 bestand, komen terug in de `club:` gedeelte bovenaan een Level 2 bestand. De velden worden in [die documentatie](https://github.com/vdhamer/Photo-Club-Hub/blob/main/Photo%20Club%20Hub/Documentation/Level1_aanmaken_NL.md) wat uitvoeriger in het Nederlands beschreven.

- Wat betreft de belangrijkste velden over Clubs:
   - `level1Header` omschrijft het bestand zelf.
      - `level1URL` is het webadres van de meesterversie van dit document (vermoedelijk op GitHub).
      - `level1URLIncludes` kan een lijst van in te lezen [ondergeschikte](https://github.com/vdhamer/Photo-Club-Hub/edit/main/Photo%20Club%20Hub/Documentation/Level1_aanmaken_NL.md#hoe-zit-het-met-level1urlincludes) Level 1 bestanden bevatten.
      - `maintainerEmail` is de contactpersoon voor problemen met dit bestand.
   - `clubs` bevat een lijst met fotoclubs. Deze wordt samengevoegd met eventuele clubs gevonden via `level1URLIncludes`.
      - `idPlus` is de unieke identificatie van een club. `nickName` moet uniek zijn. En `town` en `fullName` moeten samen uniek zijn.
      - `coordinates` zijn lengtegraad en breedtegraad van waar de club bijeekomt of exposeert (formaat: 51.53557 resp 5.62722).
      - `optional`
         - `website` bevat het adres van een bestaande website van de club.
         - `wikipedia` bevat een webadres in Wikipedia, maar zal bij clubs (itt musea) vrijwel nooit voorkomen.
         - `level2URL` bevat het webadres van het level2.json bestand met ledenlijst informatie voor deze club.
         - `remark` bevat een enkele zin (in Nederlands en Engels) met iets belangrijks of onderscheidends over de club. Liever niets dat voor vele clubs zou gelden: dat leest men zelf maar via de website.
         - `maintainerEmail` van de Level 2 bestand. Zal hier zelden ingevuld worden (zelfde gegevens staan namelijk ook in Level 2 bestand zelf).
         - `nlSpecific` bevat informatie die alleen betekenis heeft voor Nederlandse clubs
               - `fotobondNumber` is het Fotobond nummer (b.v. 1641) voor de clubs aangesloten bij de Fotobond. Bij andere Nederlandse clubs dient men de `fotobondNumber` regel weg te laten. Hierdoor kan de app zien of een club lid is van de Fotobond. 
   - `museums` bevat een lijst met musea met een opmerkelijke fotografie collectie.
Voor Nederland worden fotoclubs en fotomusea gescheiden opgeslagen, en zal men dus geen musea aantreffen in bestanden over Nederlandse fotoclubs.
Musea worden uitgelegd in het Engelstalige [README.me](https://github.com/vdhamer/Photo-Club-Hub/blob/main/.github/README.md) document. 

</details></p>

### Meer over JSON Editor Online
<details><summary>Details (klik om uit te klappen)</summary></p>

- Bovenaan het scherm staat iets over "inloggen" en "prijzen".
  Men kan dat voor ons doel negeren: de gratis versie is meer dan genoeg.
  De site doet vrijwel alles zonder je te registreren. Dat scheelt weer het onthouden van een extra wachtwoord.

- De site toont een linker en een rechter paneel. Die twee panelen kunnen verschillende bestanden (b.v. een voorbeeldbestand en een nieuw bestand) bevatten. Er zijn knopjes om de inhoud van het ene paneel naar het andere te kopiëren. Dat kan je gebruiken om dezelfde JSON inhoud op 2 verschillende manieren tegelijk te bekijken. Of om een kopie te maken en die kopie te gebruiken om de wijzingen in aan te brengen.

- In JSON wordt de __volgorde__ van de elementen binnen een `[ ]` paar (=lijst) of een `{ }` paar (=samenstelling) genegeerd. Bij het vergelijken van 2 versies van een bestand in [JSON Editor Online](https://jsoneditoronline.org) zal dus een verschil in volgorde __niet__ als verschil in inhoud opgevat worden.

- Het is riskant om blindelings JSON Editor Online gedetecteerde fouten te laten herstellen ("Autorepair"). Dit verhelpt vaak de foutmelding, maar vaak niet op de correcte manier. Op termijn gaan we dit oplossen (via JSON Schema).

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
