## Bestandsbeheer bij GitHub

Dit document beschrijft de procedure om je aan te melden bij www.github.com
en om __bestandswijzigingen__ aan _Photo Club Hub_ aan te bieden. 
Het is met name bedoeld om ledenlijsten (zoals `fgMijnClub.level2.json`) of documentatiebestanden (zoals dit bestand) 
te beheren met minimale afhankelijkheid van derden. De procedure werkt voor vrijwel alle soorten tekstbestanden.

Het is ook mogelijk om _nieuwe_ bestanden toe te voegen of bestaande bestanden te verwijderen.
Dat gaat vrijwel op een dezelfde manier (we gaan op die details niet verder in).

In hoofdlijnen komt het erop neer dat men een gewijzigd bestand kan aanmaken, en het aanbieden aan het project. Het project wordt meestal een __Repository__" of "__Repo__" genoemd.
Tussen aanbieden en daadwerkelijk benutten zit nog een __goedkeuringsstap__.
Die goedkeuringsstap voorkomt dat iemand zomaar een willekeurige wijziging in een belangrijke bestand kan aanbrengen.
De details van de goedkeuringsprocedure wordt hier ook overgeslagen omdat de Repository beheerder het goedkeuren doet.

   > Tip: Achterin dit document is een verklarende woordenlijst.
   > Daar vind je termen zoals __Repository__, __GitHub__ en de beruchte Git stapjes "__Commit__, __Push__, __Pull__ en __Pull Request__". Deze termen hebben hier een hoofdletter om te benadrukken dat het in dit verband een specifieke betekenis heeft.

### Alvast een samenvatting

Er zijn (althans in hoofdlijnen) 4 stappen:

1. De gebruiker maakt (eenmalig) een account aan bij GitHub. Dat account is geldig voor _alle_ GitHub Repositories.
2. De gebruiker maakt (eenmalig, via `GitHub Desktop`) een lokale kopie aan van 
de _complete_ inhoud van het [Photo Club Hub](https://github.com/vdhamer/Photo-Club-Hub) Repository.
Die lokale kopie is gewoon een directory (=folder) en kan allerlei subdirectories en ruim 100 bestanden bevatten.
3. Een bestand (of bestanden) wordt lokaal (op de eigen computer) naar wens gewijzigd.
Deze stap mag zo lang duren als men wil (minuten … dagen).
4. De gebruiker biedt (gebruik makend van `GitHub Desktop`) de aangepaste bestanden aan bij de centrale 
Repository op GitHub voor goedkeuring door de Repository beheerders. `GitHub Desktop` weet zelf welke bestanden gewijzigd zijn.

Als bijvoorbeeld een een dag of een jaar later een volgende verandering nodig is dan herhaal je gewoon stappen (3) en (4).
Dus een bestandsaanpassing hoeft niet in een keer af, maar bij het aanbieden voor goedkeuring moet het geheel wel bruikbare inhoud.
Hierbij houden de Repository beheerders een oogje in het zijl.

   > Tip: GitHub (en het achterliggende `git`) is een zogenaamde "versiebeheersysteem" (_version control system_).
   > Dat houdt in dat het alle aangeboden bestandswijzigingen nauwlettend bijhoudt. 
   > `git` kan ook teams van samenwerkende personen en aan, zelfs als 2 teamleden min of meer gelijktijdig hetzelfde bestand aanpassen.
   > Dit houdt in dat `git` zorgt dat aangeboden wijzigingen keurig beheerd bijven en dat er nooit een wijziging verloren raakt.

   > Tip: GitHub is een vrij complex systeem. De hele software-industrie is afhankelijk van GitHub en verwante systemen.
   > Cursussen op YouTube hierover zijn vaak bedoeld voor (aankomende) softwareontwikkelaars.
   > Die videos behandelen meer toeters en bellen van `git` en `GitHub` dan wat wij hier nodig hebben.
   > Concentreer je dus op het lijstje basisbegrippen achterin dit document. De rest kan je ooit nog bij leren zodra de basis soepel gaat.

#### Voordelen van GitHub

<details><summary>Details (klik om uit te klappen)</summary></p>

Voor ons gebruik hier, zijn de voordelen van GitHub:

- VERSIEBEHEER<BR>
Alle aangeboden versies worden bewaard. Je kunt zien wie, wanneer, en waarom een wijziging gemaakt is.

- SAMENWERKING<BR>
Meerdere mensen kunnen wijzigingen aanbrengen, en wijzigingen van elkaar overnemen.
Zonder het risico van misverstanden of kwijtraken van een voorgestelde aanpassingen.
`git` (`GitHub`) is als het ware de stoplichten die het dataverkeer tussen de verschillende partijen regelt: soms irritant, maar het heeft zijn nut.

- EENVOUDIGE GOEDKEURING<BR>
Een ingediende wijziging eenvoudig goedgekeurd worden. Iets van 3 keer klikken.
Dit is essentieel als er iedere dag een handjevol wijzigingsvoorstellen binnenkomen.

- ARCHIEF<BR>
GitHub is in feite het werkarchief voor alle bestanden van dit project: code, data, documentatie, "Issues".
GitHub leidt alle procedures in goede banen.

- ONLINE<BR>
De Photo Club Hub apps halen hun gegevens op vanuit GitHub.
Dit zijn vooral lijsten met clubs ("Level 1") en lijsten met clubleden ("Level 2").
Hierdoor krijgt de app de meest recente gegevens ophalen ("club fgMijnClub heeft een nieuw lid").
Portfolio foto's ("Level 3") worden daarentegen op de clubwebsites bewaard:
dit zijn grotere aantallen bestanden (ieder grofweg 1 Megabyte groot). Dus 20 leden x 20 foto's is grofwel 400 Megabyte opslag.
Verder zorgt deze scheiding dat clubwebsites totaal onafhankelijk zijn van GitHub.

- URLs<BR>
Alle bestanden hebben een webadres (URL). 
Dat is nuttig voor bijvoorbeeld verwijzingen zoals voor het downloaden van [de introductie Powerpoint](tinyurl.com/fchPPTnl).

- CENTRALE TO-DO LIJST<BR>
De centrale lijst per Repository op GitHub bevat uitbreidingsverzoeken en op te lossen bugs of problemen.
Jij kunt dus als GitHub gebruiker kijken of een klacht ("Issue") al bekend is, 
melding maken van een klacht, status zien van de afhandeling en lezen wat anderen ervan zeggen ("Heb ik ook, heel storend!").

- READ-ONLY<BR>
Wie alleen wil kijken, maar niets wil wijzigen, heeft geen account bij GitHub nodig.
Bijvoorbeeld om even te kijken naar een databestand of naar documentatie.
Dus read-only gebruikers kunnen alles zien wat er in een openbaar GitHub Repository staat.

</details></p>

## 1. Account aanmaken ("Sign up") bij GitHub

Een account bij GitHub aanmaken is gratis. Wie zich eerder geregistreerd heeft bij GitHub, kan doorgaan naar Stap 2.

Registratie van een nieuwe GitHub gebruiker gebeurt via de "Sign up" knop op de [hoofdpagina van GitHub](https://github.com). 
__Sign up__ is dus om je te registreren (account aanmaken). 
__Sign in__ is iedere keer nodig dat je je aanmeldt bij GitHub ("inloggen").<BR>
Dit is dus vergelijkbaar met allerlei webdiensten zoals Facebook of Instagram.

<p align="center"><img width="532" height="889" alt="Screenshot 2025-12-11 at 22 19 03" src="https://github.com/user-attachments/assets/da795207-821c-4a14-bdce-4f156e796d61" /></p>

<details><summary>Details (klik om uit te klappen)</summary></p>

- Wie een Apple account gebruikt, kan "Continue with Apple" (of "Continue with Google") kiezen. Als je dit gebruikt, ben je snel klaar.
- Voor toekomstige "Sign in" heb jij de combinatie Email/Password straks nodig. Of Username/Password. Je moet alle 3 velden invullen en goed bewaren.
   - Email moet uniek zijn binnen GitHub.
Voor de meeste mensen is deze stap geen probleem: die hebben bijvoorbeeld een primair en misschien een secondair Email account. 
Je kunt eventueel een apart Email account hiervoor aanmaken bij Gmail 
(een "nep" iCloud account dat doorstuurt naar een primair account zal waarschijnlijk hier zoals gezegd problemen geven).
Gebruik geen "hide my Email" Apple iCloud account: dit wordt geweigerd met een (verkeerde) foutmelding.
   - Wachtwoord moet uiteraard bewaard worden bij al je andere wachtwoorden.
   - Username moet ook uniek zijn en is een beetje misleidend:
   In de kleine lettertjes staat dat er bijvoorbeeld geen spaties in mogen.
   Het is dus Username in de IT zin, en niet de gewone naam van de gebruiker.
   Je mag dus wel Jan-Pietersen kiezen maar niet Jan Pietersen. 
   Maar stroopwafelfrisbee mag ook. Ik gebruik zelf "vdhamer" en "vdhamer-for-testing".
- Country is een makkelijke vraag: gewoon Netherlands kiezen uit de lijst. Het antwoord is onbelangrijk volgens de kleine lettertjes.
- Op "Create account" klikken resulteert in het standaard ritueel van code ontvangen per Email,
en code terugmelden aan GitHub om te controleren dat het Email adres ok is.
Je krijgt minstens 1 vraag (op basis van plaatjes of geluid) om te bewijzen dat jij een mens bent. Deze tests zijn best lastig bij GitHub.
- GitHub heeft ook alternatieve inlogopties bedoeld voor softwareontwikkelaars (SSH, passkeys). Die zijn moderner, maar vereisen wat meer kennis.

</details></p>

## 2. Lokale "Clone" aanmaken via GitHub Desktop

In deze stap installeren we eerst __GitHub Desktop__. Dit is lokaal draaiende software gemaakt door GitHub (tegenwoordig een deel van Microsoft). 

Het nut van GitHub Desktop is:

<details><summary>Details (klik om uit te klappen)</summary></p>

- je kunt je desgewenst lokale wijzigingen bijhouden
- je ziet het verschil (op regelbasis) tussen die versie die je aanbied aan GitHub en de bestaande versie op GitHub
- tijdens het lokaal werken heb je geen last van wijzigingen gemaakt door anderen
- gelijktijdige wijzigingen van een tekstbestand door iemand worden automatisch gecombineerd met jouw wijzigingen

Waarom is GitHub Desktop eigenlijk nodig, als je een bestand opgeslagen bij GitHub wilt wijzigen?
Dat is ondermeer omdat, bij het wijzingen van softwarebestanden, men de software graag lokaal wil bouwen en testen.
Het is namelijk zelden in één keer goed. Ons geval is een beetje een uitzondering: we passen slechts de gegevensbestanden aan.

   > Tip: vaak wordt (aan softwareontwikkelaars) aangeraden om eerst het pakket `git` te installeren.
   > We gaan het hier niet doen omdat Git installatie indien nodig onderwater gebeurt. Citaat uit de documentatie:
   > "Installing GitHub Desktop will also install the latest version of Git if you don't already have it.
   > With GitHub Desktop, you get a command-line version of Git with a robust GUI (_Graphical User Interface_)."

</details></p>

### 2.1 GitHub Desktop downloaden en installeren

Via deze [link](https://desktop.github.com/download/) kan je GitHub Desktop gratis downloaded voor Mac of voor Windows

<p align="center"><img width="968" height="944" alt="Screenshot 2025-12-13 at 23 02 29" src="https://github.com/user-attachments/assets/e080f792-2d87-4a05-8542-eb8375a417d9" /></p>

Er zijn versies Macs met Intel chips en met nieuwere "Apple Silicon" (M1, M2...) chips. Maar één van beiden zal werken.
Bij Mac kan je het `.zip` bestand in de Downloads folder openen. En dan de resulterende `GitHub Desktop.app` naar de Applications folder slepen.

Bij Windows krijg je een installatieprogramma dat je moet uitvoeren om `GitHub Desktop` te installeren.

Bij het openen van GitHub Desktop krijg je (in ieder geval op de Mac) de vraag of je de app wel vertrouwt.
Gerust "Open" kiezen: er zijn miljoenen gebruikers je voorgegaan.
En GitHub is fanatiek over veiligheid (ze moeten wel: de halve software wereld hangt ervan af).

Vervolgens krijg je de keus tussen GitHub.com (👈 deze kiezen) of GitHub Enterprise.

Vervolgens wil `GitHub Desktop` weten onder welke naam/wachtwoord jij bekend bent op GitHub.
Gebruik de gegevens die je eerder in het "Sign up for GitHub" gekozen hebt.

<p align="center"><img width="395" height="647" alt="Screenshot 2025-12-13 at 23 21 24" src="https://github.com/user-attachments/assets/8060a991-a12a-45cd-9c87-4f94cd1c7b6a" /></p>

Je krijgt nog een veiligheidsvraag van je Internet browser (Safari, Chrome, Edge, Firefox). Dat ziet er ongeveer zo uit:

```
   Do you want to allow this website to open "GitHub Desktop"?
```

Dit komt omdat je op dat punt overschakelt van jouw browser naar een lokaal programma.
Dat mag niet zomaar, maar is hier OK.
Als alternatief kan je de `GitHub Desktop` applicatie zelf opstarten via een icoontje in Applications (Mac) of `Start` menu (Windows).

Rond deze tijd komt je dit scherm ook tegen. Gewoon op "Authorize desktop" klikken:

<p align="center"><img width="532" height="626" alt="Screenshot 2025-12-13 at 19 13 17" src="https://github.com/user-attachments/assets/1bfde716-75b4-44de-8830-d8161c26bb40" /></p>

### 2.2 Verbinding maken met GitHub account

Hiermee heb je een werkende GitHub Desktop. Maar bij het opstarten krijg je nog een vraag:

<p align="center"><img width="1028" height="728" alt="Screenshot 2025-12-13 at 23 30 56" src="https://github.com/user-attachments/assets/fb96dc61-83d8-4ec7-b9a6-5d16cd249eee" /></p>

Ook hier moet de invoer kloppen met de gegevens die je eerder in het "Sign up for GitHub" gekozen hebt.

GitHub Desktop weet (via GitHub) dat jij geen eigen "Repository" (project) heb.
Dus biedt het aan één te maken (misschien iets voor later als je verder met GitHub wilt oefenen).
Het biedt ook een optie aan waarbij je mee gaat helpen aan een bestaande Repository. Dat is hier de bedoeling:

<p align="center"><img width="1072" height="772" alt="Screenshot 2025-12-13 at 23 39 00" src="https://github.com/user-attachments/assets/bf910eab-42d5-4b8a-9202-4257cf1e7d8f" /></p>

Kies hier "Clone a Repository from the Internet...". <BR><BR> Waarna je (b.v.) URL kiest:

<p align="center"><img width="518" height="313" alt="Screenshot 2025-12-13 at 19 14 34" src="https://github.com/user-attachments/assets/079eceae-efec-45da-84be-41ef36436365" /></p>

Voordat je op Clone klikt: dit gaat __alle__ bestanden van het project in hun huidige versie kopiëren naar de door jou gekozen directory op jouw computer.
Ik koos voor een directory "Photo-Club-Hub" binnen een nieuwe directory "GitHubDesktopRepos" binnen een directory "Developer".
Maar dit mag je helemaal zelf weten. 
Die locatie is achteraf aanpasbaar, maar het is het eenvoudigst als je het in één keer goed instelt. 
De vraag hierbij is "waar kan ik honderden Megabytes voor onbepaalde tijdsduur stallen zodat ik terug vind?".
Honderden Megabytes klinkt misschien groot, maar dat valt tegenwoordig mee: het is grofweg gelijk aan 5 uur MP3 audio.
Op de Mac is /Users/mijnAccount/Developer gebruikelijk. Dan zie je een speciaal geel icoon verschijnen.

> Tip: Op verjaardagsfeestjes kan je familie en bekenden imponeren met het feit dat jij "op GitHub" zit.
> Het is eigenlijk best iets om trots op te zijn. Heel `git` is bepaald niet simpel.
> Maar wij gebruiken hier maar een paar procent van de totale mogelijkheden.
> GitHub heeft 500 miljoen Repositories en ruim 100 miljoen geregistreerde gebruikers. De meeste gebruikers zitten
> in de software industrie. Maar het is ook bruikbaar voor willekeurige text-achtig document bruikbaar: [GitHub for Poets, tutorial deel 1.1](https://www.youtube.com/watch?v=BCQHnlnPusY).

### 2.3 Wat zien we inmiddels?

<p align="center"><img width="1072" height="772" alt="Screenshot 2025-12-13 at 19 15 51" src="https://github.com/user-attachments/assets/8227d1e7-483e-44b7-aa4f-a36400f34e83" /></p>

Zo ziet GitHub Desktop eruit bij een lokale Clone van het GitHub Repository `vdhamer/Photo-Club-Hub`:

- "Current Repository" meldt dat het gaat om het Photo-Club-Hub project
- "Main Branch" betekent dat je niet bezig bent met een tijdelijk subproject. Voor ons volstaat "Main" omdat we relatief kleine aanpassingen doen.
- "Fetch Origin" ververst jou lokale kopie van de Repository zodat het weer helemaal bij is.
Lokale aanpassingen (op je eigen computer) worden hierbij _niet_ overschreven.
- Er is een knop om een teksteditor te openen. In mijn geval (Mac) is dat `Sublime Text`. Onder Windows wordt `Notepad++` vaak gebruikt.
- Er is een knop om de folder te bekijken (in `Finder` op Mac, of `Explorer` onder Windows).
- Je kunt ook de Repository op GitHub bekijken via jouw browser. Hier kan je normaal geen wijzigingen in aanbrengen.
- Het gebied linksonder met "Commit to Main" is waar je de locale wijzigingen aanbiedt aan GitHub. Dat heet "Commit" in het jargon.
-  Je moet minstens enkele woorden omschrijving geven met wat er veranderd is ("Summary (required").

Ik zou "View file is your Repository in Finder/Explorer" maar kiezen. 
En dan het bestand dat je wilt aanpassen openen. En met een lokale editor (Sublime Text, Notepad++, Notepad, TextEdit) aanpassen.

Dat ziet op een Mac zo uit (onder Windows zie je iets vergelijkbaars):

<p align="center"><img width="1032" height="576" alt="Screenshot 2025-12-14 at 00 27 12" src="https://github.com/user-attachments/assets/1bc3738a-b2ed-4c85-b7c4-0534a8e98744" /></p>

Dit is dus de standaard bestandsapplicatie ("file manager") van MacOS of Windows. Met een onzichtbaar maar belangrijk verschil:
GitHub Desktop regelt dat het centrale ("Origin") Repository op Github en jouw projektdirectory in sync blijven.

## 3. Bestand op de eigen computer aanpassen

In de directory `User/Developer/GitHubDesktopRepos/Photo-Club-Hub` (of wat je ook gekozen hebt) vind je
een JSON subdirectory met daarin een bestand genaamd `whiteboard.txt`. 
Dit bestand kan je naar hartelust aanpassen: het bestand dient namelijk alleen als testbestand hiervoor.

Dus...
- ga naar `User/Developer/GitHubDesktopRepos/Photo-Club-Hub/JSON`
- open het bestand in een editor (`Sublime Text`, `Notepad++`...)
- bekijk even de bestaande inhoud. Het had oorspronkelijk 10 niet-blanco regels, maar dat kan ondertussen veranderd zijn.
- maak een wijziging (doet er niet toe wat je wijzigt, de inhoud is wel openbaar)
- sla het bestand lokaal op (vaak Ctrl-S of Menu > File > Save)

## 4. Aangepast bestand aanbieden aan repository in GitHub

Nu hebben we een lokale clone van het Photo-Club-Hub repository dat (bijvoorbeeld wat betreft `whiteboard.txt`)
voorloopt op het bestand van de centrale GitHub Repository. We gaan nu die wijziging aanbieden aan GitHub.

In GitHub Desktop zien we:

<p align="center"><img width="1028" height="728" alt="Screenshot 2025-12-14 at 22 27 44" src="https://github.com/user-attachments/assets/9f68f790-3bd7-4947-ba30-b3a279a28a53" /></p>

Hier zijn een paar nuttige dingen te zien:
1. Onder `JSON/whiteboard.txt` zie je de regels die verwijderd zijn (in het rood, "-") en regels die nieuw zijn (in het groen, "+").
Er kunnen meerdere verandering per bestand getoond worden. En er kunnen meerdere bestanden veranderd zijn.
2. Er staat in dit geval "1 changed file", met een lijst van veranderde bestanden.
3. Er staat dat je alle wijzingen kunt aanbieden via de knop "Commit 1 file to Main".
Met een automatisch gegeneerde text over de wijziging. Die text kan je aanpassen.
Belangrijke: de term in `git` voor veranderingen aanbieden is __Commit__.
Een beeld: je stopt all wijzigingen in een envelop en schrijft op de envelop wat de bedoeling van de wijzigingen is.
4. Er staat in bovenstaand plaatje (deze keer) een waarschuwingsdriehoek dat we nog geen rechten hebben om de wijzigingen te Commit'en. 
Dit komt omdat we eerder Clone gedaan hebben. En Clone is niet voldoende om de "envelop" op te mogen sturen.
Om de "envelop" te mogen versturen hebben we iets nodig dat __Fork__ heet.
Dat levert een lokale directory op die wel wijzigingen naar terugsturen naar GitHub/Origin.
De term Fork is zoiets als een splitsing in een bospad: beide paden gaan los van elkaar verder.
Al kunnen we ze verderop misschien weer samenkomen.

We moeten eerst de waarschuwing van (4) oplossen. Dit is slechts _eenmalig_ nodig. Klikken op de "create a Fork" link levert:

<p align="center"><img width="1072" height="772" alt="Screenshot 2025-12-14 at 22 41 18" src="https://github.com/user-attachments/assets/49ae986b-f785-41cd-a685-86b4713edfb5" /></p>

Hier kiezen we "Fork this Repository", en dit levert nog een vraag:

<p align="center"><img width="1072" height="772" alt="Screenshot 2025-12-14 at 22 41 43" src="https://github.com/user-attachments/assets/e787a577-17b0-4a1f-869f-42eade82c627" /></p>

Kies "To contribute to the parent project" (default) en "Continue". Dit brengt ons bij:

<p align="center"><img width="1072" height="772" alt="Screenshot 2025-12-14 at 22 51 48" src="https://github.com/user-attachments/assets/f9c33883-d845-4e56-a9d6-7a4b38159411" /></p>

Hier waren we inderdaad al eerder. Het is het hoofdscherm van `GitHub Desktop`. Maar nu is die vervelende waarschuwing weg.
En kunnen we nu wel __Commit file(s) to Main__ doen van met de blauwe knop linksonder.
Het is Commit "to Main" want we gebruiken hier alleen de Branch genaamd Main.

Ter herinnering, Commit stopt de wijzigingen in een envelop met etiket.
Die envelop is nog niet aangemaakt en dus ook niet verstuurd naar GitHub.

We klikken dus op "Commit to Main" en zien:

<p align="center"><img width="1072" height="772" alt="Screenshot 2025-12-14 at 23 01 28" src="https://github.com/user-attachments/assets/1aa2f990-73c3-47a1-aeff-def28d874445" /></p>

Op het `GitHub Desktop` hoofdscherm
zie je (in dit geval) dat er 2 Commits ondertussen in de centrale Repository (Origin) door anderen gedaan zijn.
De blauwe "Pull (from) Origin" knop trekt ("pull") die wijzigingen vanuit het centrale repo naar jouw locale kopie.
We gaan nu klikken op "Pull (from) Origin", maar let tegelijk op de getalletjes bovenaan: 
er zijn 2 Commits klaar voor Pull (wijzigingen door iemand anders).
En 1 Commit met de aangebrachte wijzigingen. Klikken op "Pull (from) Origin" geeft:

<p align="center"><img width="1028" height="728" alt="Screenshot 2025-12-14 at 23 08 35" src="https://github.com/user-attachments/assets/7a21d995-9428-4fc2-a75f-1a5c2c72181a" /></p>

Nu is het "Pull (from) Origin" verhaal weg. Want dat is geregeld.
Maar biedt `GitHub Desktop` aan om "__Push__ [to] Origin" voor je te doen.
Klikken op "Push [to] Origin" (envelop verzenden) geeft:

<p align="center"><img width="1072" height="772" alt="Screenshot 2025-12-14 at 23 23 57" src="https://github.com/user-attachments/assets/1491ad77-b429-47ff-8907-e00b7f2bea7e" /></p>

Met `GitHub Desktop` moeten we nog de beheerders van het Repository melden dat er een envelop voor hun deur ligt om te bekijken en goed te keuren.
Dat heet een "Pull Request" omdat de beheerders initiatief moeten nemen om de wijziging aan bood te halen. Ze moeten hiervoor het initiatief nemen
("Pull") ipv dat zij de wijziging opgedrongen ("Push") krijgen.
Dus een Pull Request is een verzoek om bij gelegenheid naar de envelop (soms nu ook Pull Request genaamd) te kijken.

Nu hebben we (een beetje vreemd) geen knopje om een Pull Request naar de beheerders te verzenden.
In plaats van een knopje, loopt dit via Menu > `Branch` > `Pull Request`. Dat opent de browser:

<p align="center"><img width="1393" height="1522" alt="Screenshot 2025-12-15 at 00 46 50" src="https://github.com/user-attachments/assets/55e08f00-3ed7-4211-9641-b908940aa476" /></p>

   > Tip: jouw browser kan er net iets anders uitzien. Vooral aan de bovenkant van het scherm.

Hier kan je opnieuw alle wijzigingen zien. En hoort je een beschrijving (Title) toe te voegen, en eventueel meer details.
GitHub Desktop zal echter een poging doen om te verzinnen wat je in de Title in zou kunnen vullen.
Je verstuurd dit naar de Repository beheerders via de "Create Pull Request" knop. Dan zie je:

<p align="center"><img width="1169" height="944" alt="Screenshot 2025-12-15 at 00 47 47" src="https://github.com/user-attachments/assets/3101c08e-7edd-4a3b-b0a1-f35b45375110" /></p>

Dit is een hele plens informatie, maar je hoeft hier niets meer te doen!
Zo kan je zien (in het rood) dat iemand anders de wijziging ("Pull Request") mag controleren ("Review"). 
En bovenaan kan je zien dat er 1 Pull Request in de wachtrij staat voor de beheerders. 
Eenzelfde scherm gebruikt de beheerder om de inhoud van de Pull Request te bekijken, en als alles ok is, om de Pull Request te integreren
in het Repository.

Hiermee zijn we (eindelijk) KLAAR en hebben het volgende bereikt:

1) jouw wijziging aan `whiteboard.txt` ligt nu ter goedkeuring bij de Repository beheerder.
Dit ging via "Push". Dat brengt jouw Commit (evt meerdere) naar GitHub.
2) de wijziging ligt ter goedkeuring bij de repo beheerder. Dat is het resultaat van de "Pull Request".
3) in dit geval, hebben we terloops wat recente maar ongerelateerde wijzigingen in de
omgekeerde richting ("Pull") naar binnen getrokken.
Vaak is er niets gewijzigd - dat hangt af van hoe actief anderen zijn,
en hoe lang geleden je voor het laatst "Pull (from) Origin" gedaan hebt.
4) We hebben bij zowel de finale "Pull Request" als bij de eerder Commit een omschrijving kunnen aanleveren
(etiket) van wat de bedoeling van de wijziging is.

## Hoe complex is dit bij toekomstige wijzigingen?

Dit was een best lang verhaal. Maar stappen (1) en (2) en de omschakeling van "Clone" naar "Fork" waren eenmalig.

Wat je dus aan handelingen overhoudt bij iedere nieuwe wijziging:
- de eigenlijke verandering lokaal uitvoeren op het bestand (of bestanden). Dat is uiteraard waar het om draait.
- "Pull (from) Origin": desgevraagd centrale wijzingen overnemen naar je lokale bestanden.
Je wordt door `GitHub Desktop` aan deze "Pull" actie herinnerd als het nodig is.
En ik denk dat je niet door kunt gaan naar "Push Commit" voordat "Pull"
- "Push Commit": de locale wijziging via "Push Commit" overbrengen naar GitHub. Hier hoort een korte omschrijving bij.
- "Pull Request": de beheerders verzoeken om de wijzigingen te verwerken via "Pull Request". Hier hoort een korte omschrijving ook bij.

Samenvatting van deze samenvatting zijn de volgende 3 danspasjes: (Pull) --> Push --> Pull Request.
De terminologie is wat troebel (omdat er heel veel kan, en omdat de oorspronkelijke maker een beetje haast had),
maar `git` is desondanks de wereldstandaard voor versiebeheer.
Gelukkig bewaakt `GitHub Desktop` dat men de danspasjes in de juiste volgorde doet.

## Bonus

### Verklarende woordenlijst

<details><summary>Details (klik om uit te klappen)</summary></p>

- __Repository__

Een verzameling bestanden in Git/GitHub die samen als projekt behandeld worden.
Bijvoorbeeld het complete ontwerp van een computer spel.
Een Repository (=Repo) kan openbaar of privé zijn.
De bestanden zijn meestal platte tekst in diverse formaten die door een computer begrepen worden (.json, .md, .swift, …).

- __Git__

Een versiebeheer technologie die het mogelijk maakt om met 1 of meerdere personen aan een Repository te werken.
Experts kunnen Git, in zijn oervorm, bedienen door commando's in een "terminal" venster te tikken.
Maar Git wordt ook vaak vanuit een grafische schil zoals `GitHub Desktop` aangestuurd.

- __GitHub__ en __Origin__

Een grote website waar miljoenen Repositories (met gehulp van git) beheerd worden. Gratis voor openbare projekten.\
GitHub is sedert 2018 een dochteronderneming van Microsoft, maar daar merk je normaal niets van.

Origin is de plek waar de bron van een bepaald Repository staat. Hier dus een ander wooord voor GitHub.
Het woord Origin wordt gebruikt omdat er allelei andere bronnen dan GitHub bestaan, zowel openbaar als binnen bedrijven.

- __Clone__ en __Fork__

Clone is slechts tijdelijk nodig in deze procedure (en dus hier onbelangrijk).
Een Clone is een lokale kopie van een Repo op je eigen computer.
De bestanden in een Clone kan je lokaal (gewijzigd of ongewijzigd) testen: het is slechts een copie.
Maar een Clone staat __niet__ (normaal) toe dat men wijzgingen terug kan sturen richting GitHub.

Een Fork is een lokale kopie van een Repo op je eigen computer.
Wijzigingen aan een Fork kan je aanbieden aan GitHub (ter controle en integratie).
GitHub houdt bij iedere Repository, ter info, bij welke Forks ervan bestaan.

- __Commit__

Een wijziging aan 1 of meer bestanden, met korte beschrijving, registreren in de lokale Git administratie.
Commit is een soort voorportaat van wijzigingen die straks met Push naar GitHub kunnen gaan.

- __Push__

Lokaal initiatief nemen om een of meerdere Commits naar GitHub (Origin) te sturen.
GitHub krijgt die informatie binnen zonder erom te vragen (vandaar de naam Push).
Hiermee kunnen anderen de concept veranderingen zien, maar zijn de verandering nog niet definitief geaccepteerd.

- __Pull__

Lokaal initiatief nemen om de lokale bestanden bij te werken met mogelijke centrale wijzigingen in het GitHub Repository.
Pull is verwant aan een locaal E-mail programma dat nieuwe berichten ophaalt van een centrale server.
Alleen by E-mail kan het geen kwaad om geregeld nieuwe berichten binnen te halen, en hier moet je op een knop drukken om te zeggen wanneer het je uitkomt.
GitHub Desktop waarschuwt je als er iets veranderd is, en dan kan je beslissen of je het nu wilt ophalen.

- __Pull Request__

Een verzoek richting een Repository beheerder op GitHub (Origin) om wijzigingen te integreren. Centraal gaat men dan vaak
controleren of de wijziging ok is. En, als het ok is (Accept), verder verwerkt en opgenomen.

- __Main__

De Main Branch is zeg maar "latest en greatest" versie van een Repository. In grote projekten, kan er in meerdere Branches
tegelijk gewerkt worden (subteams). Hier hebben we aan Main voldoende.

</details></p>

### Meerdere GitHub accounts

<details><summary>Details (klik om uit te klappen)</summary></p>

In speciale gevallen waarbij men meer dan één GitHub account gebruikt, en meerdere manieren om commando's te sturen naar
GitHub, moet je uiteraard voorzichtig zijn. Dit hoort niet te gebeuren voor mensen die alleen GitHub Desktop gebruiken.
En het hoort niet te gebeuren bij ontwikkelaars die speciaal gereedschap gebruiken rondom versiebeheer (b.v. Xcode of Visual Studio of IntelliJ).
Zou men toch (net als ik) in de problemen komen, dan kan dit helpen: [configuratie van `git`](https://github.com/orgs/community/discussions/69218)

</details></p>
