## Bestandsbeheer bij GitHub

Dit document beschrijft de procedure om jezelf aan te melden bij www.github.com
en om __wijzigingen__ in _Photo Club Hub_ bestanden aan te bieden. 
Het is met name bedoeld om ledenlijsten (zoals `mijnClub.level2.json`) of documentatiebestanden (zoals dit bestand) 
te wijzigen met minimale afhankelijkheid van derden. Maar het recept werkt voor vrijwel alle bestanden.

Het is ook mogelijk om nieuwe bestanden toe te voegen of bestaande bestanden te verwijderen.
Dat gaat op een vergelijkbare manier (en gaan we hier niet verder op in).

In hoofdlijnen komt het erop neer dat men een gewijzigd bestand kan aanmaken, en het aanbieden aan het project ("__Repository__" ofwel "__Repo__").
Tussen aanbieden en daadwerkelijk in gebruik nemen zit nog een __goedkeuringsstap__.
De goedkeuringsstap zorgt dat men zomaar een willekeurige wijziging in een willekeurig bestand kan aanbrengen.
De details van de goedkeuringsprocedure wordt hier overgeslagen omdat een Repository beheerder dat moet doen.

   > Tip: Achterin dit document is een verklarende woordenlijst.  
   > Daar vind je Git-gerelateerde termen zoals __Repository__, __GitHub__ en het beruchte riedetje __Commit__, __Push__, __Pull__

### Alvast een samenvatting

De hoofdstappen zijn dus:

1. De gebruiker maakt (eenmalig) een account aan bij GitHub. Dat account is geldig voor _alle_ GitHub Repositories.
2. De gebruiker maakt (eenmalig, via `GitHub Desktop`) een lokale kopie aan van 
de _complete_ inhoud van het [Photo Club Hub](https://github.com/vdhamer/Photo-Club-Hub) Repository.
3. Een bestand (of bestanden) wordt lokaal (op de eigen computer) naar wens aangepast.
Deze stap vereist geen Internet verbinding, en mag zo lang duren als men wil (minuten … dagen).
4. De gebruiker biedt de aangepaste versie aan (weer via GitHub Desktop) bij de centrale Repository voor goedkeuring door de Repository beheerders.

Als later nog een verandering nodig is (gebeurt vaak) dan herhaal je stappen 3 en 4.
Dus een bestandsaanpassing hoeft niet in een keer af, maar dient ten tijde van verzoek om goedkeuring natuurlijk wel bruikbaar zijn.
Voor eventuele volgende veranderingen hoef je overigens niet te wachten totdat een eerdere versie goedgekeurd is.

   > Tip: GitHub (of het achterliggende `git`) is een zogenaamde versiebeheersystemen (_version control system_).
   > Dat houdt in dat het alle aangeboden bestandswijzigingen nauwlettend bijhoudt. 
   > `git` kan ook teams aan waarbij soms 2 personen vrijwel gelijktijdig hetzelfde bestand aanpassen.
   > In de praktijk betekent dit dat `git` zorgt dat niemand een wijziging in een aangeboden bestand kwijt raakt.

   > Tip: GitHub is een vrij complex systeem. De hele software-industrie is afhankelijk van GitHub en verwante systemen.
   > Mini-cursussen op YouTube over GitHub en `git` zijn vaak bedoeld voor softwareontwikkelaars.
   > Ze beschrijven dan meer toeters en bellen van `git`(Hub) dan wat wij hier nodig hebben.
   > Concentreer je dus op die begrippen en stappen die hier nodig zijn.
   > De rest kan je altijd nog leren nadat de basis duidelijk is.

#### Voordelen van GitHub

<details><summary>Details (klik om uit te klappen)</summary></p>

Voor ons gebruik hier, zijn de voordelen van GitHub:

- VERSIEBEHEER<BR>
Alle aangeboden versies worden bewaard. Je kunt zien wie wat wanneer gewijzigd heeft.

- SAMENWERKING<BR>
Meerdere mensen kunnen wijzigingen aanbrengen, en versies van elkaar overnemen.
Zonder het risico van misverstanden of kwijtraken van een voorgestelde aanpassingen.
`git`(Hub) is als het ware de stoplichten die het dataverkeer tussen de verschillende partijen regelt: soms hinderlijk, maar het heeft zo zijn reden.

- EENVOUDIGE GOEDKEURING<BR>
In het ideale geval kan een ingediende wijziging met 1 druk op de knop goedgekeurd worden.
Dit is essentieel als er continue meerdere wijzigingsvoorstellen per dag binnenstromen.

- ARCHIEF<BR>
GitHub is in feite het werkarchief voor alle bestanden van dit project: code, data, documentatie, "Issues".
GitHub zelf is extreem secuur dat er niets zoekraakt.

- ONLINE<BR>
De Photo Club Hub apps halen de huidige gegevens op vanuit GitHub.
Dit zijn vooral lijsten met clubs ("Level 1") en lijsten met clubleden ("Level 2").
Hierdoor kan de app de huidige meest recente gegevens ophalen.
Portfolio foto's ("Level 3") worden daarentegen op de clubwebsites gehouden:
dit zijn grote aantallen grotere bestanden. Het zorgt er verder voor dat clubwebsites losstaan van GitHub.

- URLs<BR>
Alle bestanden hebben een webadres (URL). 
Dat is nuttig voor bijvoorbeeld verwijzingen zoals voor het downloaden van [de introductie Powerpoint](tinyurl.com/fchPPTnl).

- CENTRALE TO-DO LIJST<BR>
De centrale lijst van uitbreidingsverzoeken of het aanmelden van bugs loopt via GitHub.
Jij kunt zo zelf een wens of klacht ("Issue") toevoegen.
En kijken of de klacht al bekend is. En commentaar en ideeën leveren bij Issues.

- READ-ONLY<BR>
Wie alleen wil kijken, maar niets wil wijzigen, heeft geen wachtwoord of account bij GitHub nodig.
Bijvoorbeeld om even te kijken naar een databestand of naar documentatie. Dus read-only gebruikers hebben dit document niet nodig.

</details></p>

## 1. Account aanmaken ("Sign up") bij GitHub

Een account bij GitHub aanmaken is gratis. Wie zich eerder geregistreed heeft bij GitHub, kan deze Stap 1 overslaan.

Registratie van een nieuwe GitHub gebruiker gebeurt via de "Sign up" knop op de [hoofdpagina van GitHub](https://github.com). 
__Sign up__ is dus om je te registreren (account aanmaken). 
__Sign in__ is daarentegen als je later aanmeldt bij GitHub ("inloggen") onder het account dat je eenmalig aangemaakt hebt met __Sign up__.

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

In deze stap installeren we eerst __GitHub Desktop__. Dit is een lokaal draaiende software applicatie gemaakt door de GitHub organisatie. 

> Tip: vaak wordt (aan softwareontwikkelaars) aangeraden om eerst het pakket `git` te installeren.
> We gaan het hier zonder `git` doen: GitHub Desktop is een gebruikersvriendelijke grafische "schil" om `git`.

Het nut van GitHub Desktop is:

<details><summary>Details (klik om uit te klappen)</summary></p>

- je kunt je lokale wijzigingen desgewenst bijhouden
- je ziet het verschil (op regelbasis) tussen die versie die je aanbied aan GitHub en de vorige versie op GitHub
- tijdens het lokaal werken heb je geen last van wijzigingen gemaakt door anderen
- gelijktijdige wijzigingen van een tekstbestand door iemand worden automatisch gecombineerd met jouw wijzigingen

Waarom is GitHub Desktop eigenlijk nodig, als je een bestand opgeslagen bij GitHub wilt wijzigen?
Dat is ondermeer omdat, bij het wijzingen van softwarebestanden, men de software lokaal wil bouwen en testen.
Ons gebruik hier is een beetje een uitzonderingsgeval.

</details></p>

### 2.1 GitHub Desktop downloaden en installeren

Via deze [link](https://desktop.github.com/download/) kan je GitHub Desktop gratis downloaded voor Mac of voor Windows

<p align="center"><img width="968" height="944" alt="Screenshot 2025-12-13 at 23 02 29" src="https://github.com/user-attachments/assets/e080f792-2d87-4a05-8542-eb8375a417d9" /></p>

Er zijn versies voor oude (Intel) en nieuwe generatie (Apple Silicon: M1 - M5) Macs.
Bij Windows krijg je een installatieprogramma dat je moet uitvoeren om het te installeren.
Bij Mac kan je het `.zip` bestand in de Downloads folder openen. En de resulterende `GitHub Desktop.app` naar de Applications folder slepen.

Bij het openen van GitHub Desktop krijg je (in ieder geval op de Mac) de vraag of je de app wel vertrouwt.
Gerust "Open" kiezen: er zijn miljoenen gebruikers je voorgegaan.
En GitHub (al jaren deel van Microsoft) is fanatieker dan de meesten op veiligheid.

Vervolgens krijg je de keus tussen GitHub.com (👈 deze kiezen) of GitHub Enterprise.

Vervolgens wil het weten onder welke naam/wachtwoord jij bekend bent in GitHub.
Dus moet je de gegevens gebruiken die je hierboven in het "Sign up for GitHub" gekozen hebt.
Je browser of wachtwoord app kan hierbij een handje helpen. Maar dit is vergelijkbaar met
allerlei andere online diensten.

<p align="center"><img width="395" height="647" alt="Screenshot 2025-12-13 at 23 21 24" src="https://github.com/user-attachments/assets/8060a991-a12a-45cd-9c87-4f94cd1c7b6a" /></p>

Je krijgt nog een veiligheidsvraag van je Internet browser (Safari, Chrome, Edge, Firefox). Dat zal er ongeveer zo uitzien:

```
   Do you want to allow this website to open "GitHub Desktop"?
```

Dit is omdat je op dat punt overschakelt van browser naar een lokaal programma. Dat mag niet zomaar.
Maar je kunt de GitHub Desktop applicatie ook zelf opstarten via een icoontje in Applications (Mac) of in het Windows `Start` menu.

Ergens in het verhaal komt dit scherm ook voor. Gewoon op "Authorize desktop" klikken:

<p align="center"><img width="532" height="626" alt="Screenshot 2025-12-13 at 19 13 17" src="https://github.com/user-attachments/assets/1bfde716-75b4-44de-8830-d8161c26bb40" /></p>

### 2.2 Verbinding instellen naar GitHub

Hiermee heb je een werkende GitHub Desktop. Maar bij het opstarten krijg je nog een vraag:

<p align="center"><img width="1028" height="728" alt="Screenshot 2025-12-13 at 23 30 56" src="https://github.com/user-attachments/assets/fb96dc61-83d8-4ec7-b9a6-5d16cd249eee" /></p>

Ook hier moet de invoer kloppen met de gegevens die je hierboven in het "Sign up for GitHub" gekozen hebt.

GitHub Desktop weet (via GitHub) dat jij geen eigen "Repository" (project) heb.
Dus biedt het aan één te maken (misschien iets voor later als je met GitHub zelf wilt oefenen).
Het biedt als alternatief aan dat je mee wilt helpen aan een bestaande Repository. Dat is hier de bedoeling: `vdhamer/Photo-Club-Hub`.

<p align="center"><img width="1072" height="772" alt="Screenshot 2025-12-13 at 23 39 00" src="https://github.com/user-attachments/assets/bf910eab-42d5-4b8a-9202-4257cf1e7d8f" /></p>

Kies hier dus "Clone a Repository from the Internet...". <BR><BR> Waarna je (b.v.) URL kiest:

<p align="center"><img width="518" height="313" alt="Screenshot 2025-12-13 at 19 14 34" src="https://github.com/user-attachments/assets/079eceae-efec-45da-84be-41ef36436365" /></p>

Voordat je Clone klikt: dit gaat __alle__ bestanden van dit project in hun huidige versie kopiëren naar de door jou gekozen directory op jouw computer.
Ik koos voor een directory "Photo-Club-Hub" binnen een nieuwe directory "GitHubDesktopRepos" binnen een directory "Developer".
Maar dit mag je helemaal zelf kiezen. 
Die locatie is achteraf aanpasbaar, maar het is het eenvoudigst als je het meteen goed instelt. 
De vraag hierbij is "waar kan ik honderden Megabytes voor onbepaalde tijdsduur stallen zodat ik terug vind?".
Honderden Megabytes klinkt misschien wel groot, maar dat valt tegenwoordig mee.
Op de Mac is /Users/mijnAccount/Developer gebruikelijk. Dan zie je een speciaal geel icoon verschijnen.

> Tip: Op verjaardagsfeestjes kan je nerds imponeren met het feit dat jij "op GitHub" zit.
> Het is inderdaad iets om trots op te zijn. Heel `git` is bepaald niet simpel.
> Maar wij gebruiken hier maar enkele procent van de totale mogelijkheden.
> GitHub heeft 500 honderd miljoen Repositories en ruim honderd miljoen gereistreerde gebruikers. De meeste gebruikers zitten
> in de software industrie. Maar het is voor bruikbaar voor ieder soort text-achtig document bruikbaar: [GitHub for poets 1.1 tutorial](https://www.youtube.com/watch?v=BCQHnlnPusY).

### 2.3 Wat zien we inmiddels?

<p align="center"><img width="1072" height="772" alt="Screenshot 2025-12-13 at 19 15 51" src="https://github.com/user-attachments/assets/8227d1e7-483e-44b7-aa4f-a36400f34e83" /></p>

Zo ziet GitHub Desktop eruit bij 1 lokale Clone van het GitHub Repository vdhamer/Photo-Club-Hub:

- "Current Repository" zegt dat je nu bezig bent in het Photo-Club-Hub project
- "Main branch" betekent dat je niet bezig bent met een tijdelijk subproject. Voor ons volstaat "Main" omdat we relatief kleine aanpassingen doen.
- "Fetch origin" ververst jou lokale kopie van de Repository zodat het weer helemaal bij is.
Lokale aanpassingen (op eigen computer) worden hierbij _niet_ overschreven.
- Er is een knop om een teksteditor te openen. In mijn geval (Mac) is dat "Sublime Text". Onder Windows wordt "Notepad++" vaak gebruikt.
- Er is een knop om de folder te bekijken (in Finder op Mac, of Explorer onder Windows).
- Je kunt ook de Repository bekijken op GitHub via jouw browser. Hier kan je normaal geen wijzigingen aanbrenge.
- Het gebied linksonder met "Commit to main" is waar je de locale wijzigingen aanbiedt aan GitHub. Dat heet Commit in het jargon. Je moet minstens enkele woorden toelichting geven met wat er veranderd is ("Summary (required").

Ik zou "View file is your Repository in Finder/Explorer" maar kiezen. 
En dan op zoek gaan naar het bestand dat je aan wilt passen. En met een lokale editor (Sublime Text, Notepad++, Notepad, TextEdit) aanpassen.

Dat ziet op een Mac zo uit (onder Windows zie je iets vergelijkbaars):

<p align="center"><img width="1032" height="576" alt="Screenshot 2025-12-14 at 00 27 12" src="https://github.com/user-attachments/assets/1bc3738a-b2ed-4c85-b7c4-0534a8e98744" /></p>

Dit is dus de standaard bestandsbeheer van MacOS of Windows. Met een onzichtbaar maar belangrijk verschil:
GitHub Desktop regelt dat het centrale ("origin") Repository in Github op de hoogte gehouden wordt van jouw aanpassingen.
Hiervoor houdt GitHub/`git` automatisch een hele administratie bij in een verborgen directory.

## 3. Bestand op de eigen computer aanpassen

In de directory `User/Developer/GitHubDesktopRepos/Photo-Club-Hub` (of wat je ook gekozen mocht hebben) vind je
een JSON directory met daarin een bestand genaamd `whiteboard.txt`. Dit kan je naar hartelust aanpassen.
Het bestand dient namelijk alleen dit doel. De software doet er niets mee.

Dus...
- ga naar `User/Developer/GitHubDesktopRepos/Photo-Club-Hub/JSON`
- open het bestand in een editor (Sublime Text, Notepad++, Notepad, TextEdit)
- bekijk even de bestaande inhoud. Het had oorspronkelijk 10 niet-blanko regels, maar dat kan veranderd zijn.
- maak een wijziging (doet er niet toe wat je wijzigd, de inhoud is wel openbaar)
- sla het bestand lokaal op (vaak Ctrl-S of File|Save in het menu)

## 4. Aangepast bestand aanbieden aan repository in GitHub

Nu hebben we een lokale clone van het Photo-Club-Hub repository dat (voor whiteboard.txt) voorloopt ten opzichte van het bestand op GitHub.
We doen nu alsof wij die wijziging willen aanbieden.

In GitHub Desktop zien we (meteen na openen) het volgende:

<p align="center"><img width="1028" height="728" alt="Screenshot 2025-12-14 at 22 27 44" src="https://github.com/user-attachments/assets/9f68f790-3bd7-4947-ba30-b3a279a28a53" /></p>

Hier zijn een paar dingen te zien:
1. Onder JSON/whiteboard.txt zie je de regels die verwijderd zijn (rood, "-") en regels die nieuw zijn (groen, "+").
Er kunnen meerdere verandering per bestand getoond worden. En er kunnen meerdere bestanden veranderd zijn.
2. Er staat in dit geval "1 changed file", met een lijst van veranderde bestanden daar vlak onder.
3. Er staat je alle wijzingen kunt aanbieden via de knop "Commit 1 file to main".
Met een automatisch gegeneerde text over de wijziging. Die text kan je aanpassen.
Belangrijke: de term rondom `git` voor veranderingen aanbieden aan de centrale repository is __Commit__.
5. Er staat deze keer een waarschuwing dat we nog geen rechten hebben om de wijzigingen te Commit'en. 
Dit komt omdat we Clone gedaan hebben hierboven. 
Clone is dus zonder terugschrijf mogelijkheid. De equivalent met terugschrijf mogelijkeheid heet __Fork__.
De term Fork hangt samen met b.v. een splitsing in een landweg: beide wegen gaan los van elkaar verder.
Al kunnen we ze verderop weer gelijktrekken.

We gaan eerst (5) oplossen. Dit is maar _eenmalig_ nodig. Klikken op "create a Fork" levert dit:

<p align="center"><img width="1072" height="772" alt="Screenshot 2025-12-14 at 22 41 18" src="https://github.com/user-attachments/assets/49ae986b-f785-41cd-a685-86b4713edfb5" /></p>

Hier kiezen we "Fork this Repository", en dit levert alweer een vraag:

<p align="center"><img width="1072" height="772" alt="Screenshot 2025-12-14 at 22 41 43" src="https://github.com/user-attachments/assets/e787a577-17b0-4a1f-869f-42eade82c627" /></p>

Kies "To contribute to the parent project" (default) en "Continue". Dit brengt ons naar:

<p align="center"><img width="1072" height="772" alt="Screenshot 2025-12-14 at 22 51 48" src="https://github.com/user-attachments/assets/f9c33883-d845-4e56-a9d6-7a4b38159411" /></p>

Hier waren we indedaad al: het is het hoofdscherm van GitHub Desktop. Maar nu is die vervelende waarschuwing weg.
En kunnen we nu wel __Commit__ doen van met de blauwe knop linksonder. Het is Commit "to main" want we gebruiken hier alleen de Branch genaamd "main".

Ter herinnering, Commit biedt de wijzigingen aan bij GitHub, 
waar de wijzigingen vervolgens door een beheerder van dit Repository goedgekeurd kunnen worden.
Bij dit specifieke bestand zal die beheerder het al gauw goedvinden: het is maar een kliederbestand (vandaar "whiteboard.txt").

Dan zie je dit:

<p align="center"><img width="1072" height="772" alt="Screenshot 2025-12-14 at 23 01 28" src="https://github.com/user-attachments/assets/1aa2f990-73c3-47a1-aeff-def28d874445" /></p>

Hier zie je (in dit geval) dat er 2 Commits in het repository ondertussen door anderen gedaan zijn.
De blauwe "Pull Origin" knop trekt ("pull") die vanuit het centrale repo naar jaar locale repo toe.
Het is het duidelijkste, als er iets te "pull"en valt om dit nu even te doen. 
We gaan nu klikken op "Pull Origin", maar let tegelijk op de getalletjes bovenaan: er zijn 2 Commits klaar voor Pull (door iemand anders veroorzaakt).
En 1 Commit met de aangebrachte wijzigingen. Dus klik nu op "Pull Origin". Dit levert op:

<p align="center"><img width="1028" height="728" alt="Screenshot 2025-12-14 at 23 08 35" src="https://github.com/user-attachments/assets/7a21d995-9428-4fc2-a75f-1a5c2c72181a" /></p>

Hier is het "Pull" verhaal weg (want dat is geregeld). Maar biedt GitHub Desktop aan om "__Push__ [to] Origin" voor je te doen.
Klik op "Push [to] Origin". Dus zien we nu dit:

<p align="center"><img width="1072" height="772" alt="Screenshot 2025-12-14 at 23 23 57" src="https://github.com/user-attachments/assets/1491ad77-b429-47ff-8907-e00b7f2bea7e" /></p>

In GitHub Desktop moeten we nog de beheerders van het Repository melden dat er een pakje voor hun deur ligt om te bekijken en goed te keuren.
Dat heet een "Pull Request" omdat de beheerders het initiatief moeten nemen om de wijziging aan bood te halen ("Pull").
En dit is een verzoek ("Request") om dat bij gelegenheid te doen.

Dit gaat via het menu `Branch` > `Pull Request`. Dat opent de browser:

<p align="center"><img width="1393" height="1522" alt="Screenshot 2025-12-15 at 00 46 50" src="https://github.com/user-attachments/assets/55e08f00-3ed7-4211-9641-b908940aa476" /></p>

Hier kan je opnieuw alle wijzigingen zien. En eventueel de beschrijving toevoegen of aanpassen.
Je verstuurd dit naar de Repository beheerders via de know "Create Pull Request".
Vervolgens zie je:

<p align="center"><img width="1169" height="944" alt="Screenshot 2025-12-15 at 00 47 47" src="https://github.com/user-attachments/assets/3101c08e-7edd-4a3b-b0a1-f35b45375110" /></p>

Dit is slechts ter informatie: je kunt zien (in het rood) dat iemand de wijziging ("Pull Request") mag controleren ("Review"). En bovenaan kan je zien dat er 1 Pull Request in de wachtrij staat. 
Dit zelfde scherm gebruikt de beheerder om de inhoud even te bekijken, en als alles ok is, om de wijziging op te nemen
in het repository.

Hiermee zijn we (eindelijk) klaar en hebben het volgende bereikt:

1) jouw wijziging aan `whiteboard.txt` ligt nu ter goedkeuring bij de repository beheerder.
Dit ging via "Push". Dat brengt jouw Commit (evt meerdere) naar GitHub. Push vaak gebruiken kan geen kwaad.
2) de wijzging ligt ter goedkeuring bij de repo beheerder. Dat is het resultaat van de "Pull Request".
3) in dit geval, hebben we terloops wat recente maar ongerelateerde wijzigingen in de
4) omgekeerde richting ("Pull") naar binnen getrokken.
Vaak is er niets gewijzigd - dat hangt af van hoe actief anderen zijn,
en hoe lang geleden je voor het laatst "Pull" gedaan hebt. Pull vaak gebruiken kan geen kwaad.
5) We hebben bij zowel de finale "Pull Request" als bij de eerder Commit een omschrijving kunnen aanleveren
(zeg maar een etiket) van wat er gewijzigd is.

## Hoe complex is dit bij toekomstige wijzigingen?

Dit was een best lang verhaal. Maar stappen (1) en (2) en de omschakeling van "Clone" naar "Fork" waren eenmalig.

Wat je dus overhoud bij iedere wijzigingen zijn:
- de eigenlijke verandering lokaal uitvoeren op het bestand (of bestanden). Daar ging het tenslotte om.
- "Pull": desgevraagd centrale wijzingen overnemen naar je lokale bestanden.
Je wordt aan deze "Pull" actie herinnerd als het nodig is.
- "Push Commit": de locale wijziging via "Push Commit" overbrengen naar GitHub. Hier kan een korte omschrijving helpen.
- "Pull Request": de beheerders verzoeken om de wijzigingen te verwerken via "Pull Request". Hier kan een korte omschrijving ook helpen.

Samenvatting van deze samenvatting zijn de volgende 3 danspasjes: (Pull) --> Push --> Pull Request.
De terminologie is wat troebel (omdat er nog veel meer kan),
maar `git` is desondanks een wereldstandaard geworden.
Gelukkig bewaakt GitHub Desktop dat men de stappen in de juiste volgorde doet.

## Bonus

### Verklarende woordenlijst

- __Repository__  
een verzameling bestanden in git of GitHub die samen als projekt beschouwd worden.
Bijvoorbeeld alls bronprogrammatuur voor een software ontwikkelprojekt.
De Repository (=Repo) kan openbaar of privé zijn.
De bestanden zijn normaal platte tekst bestanden in allerlei talen en formaten die door een computer begrepen kunnen worden (.json, .md, .c, .swift).

- __git__  
een versiebeheer technologie die het mogelijk maakt om met 1 of meerdere personen aana een Repository te werken.
Git kan je bedienen door commando's in een terminal venster te typen.
Maar wordt vaak vanuit een grafische schil zoals GitHub Desktop aangestuurd.

- __GitHub__  
Een grote website waar miljoenen Repositories (met gehulp van git) beheerd worden. Gratis voor openbare projekten.\
GitHub is sedert 2018 een dochteronderneming van Microsoft, maar daar merk je normaal niets van.

- __Origin__  
Een locatie waar de bron van een bepaald Repository staat. Hier dus een ander wooord voor GitHub.
Het woord Origin wordt gebruikt omdat er allelei andere bronnen dan GitHub bestaan, zowel openbaar als binnen bedrijven.

- __Clone__  
Clone is slechts tijdelijk nodig in deze procedure (en dus hier onbelangrijk).
Een Clone is een lokale kopie van een Repo op je eigen computer.
De bestanden in een Clone kan je lokaal (gewijzigd of ongewijzigd) testen: het is slechts een copie.
Maar een Clone staat __niet__ (normaal) toe dat men wijzgingen terug kan sturen richting GitHub.

- __Fork__:  
Een Fork is een lokale kopie van een Repo op je eigen computer.
Wijzigingen aan een Fork kan je aanbieden aan GitHub (ter controle en integratie).
GitHub houdt bij iedere Repository, ter info, bij welke Forks ervan bestaan.

- __Commit__  
Een wijziging aan 1 of meer bestanden, met korte beschrijving, registreren in de lokale Git administratie.
Commit is een soort voorportaat van wijzigingen die straks met Push naar GitHub kunnen gaan.

- __Push__  
Lokaal initiatief nemen om een of meerdere Commits naar GitHub (Origin) te sturen.
Hiermee kunnen anderen het desgewenst bekijken, maar dit is hier een tussenstap richting Pull Request.

- __Pull Request__  
Een verzoek richting een Repository beheerder op GitHub (Origin) om wijzigingen te integreren. Centraal gaat men dan vaak
controleren of de wijziging ok is. En, als het ok is (Accept), verder verwerkt en opgenomen.

- __Main__  
De Main Branch is zeg maar "latest en greatest" versie van een Repository. In grote projekten, kan er in meerdere Branches
tegelijk gewerkt worden (subteams). Hier hebben we aan Main voldoende.

### Meerdere GitHub accounts

<details><summary>Details (klik om uit te klappen)</summary></p>

In speciale gevallen waarbij men meer dan één GitHub account gebruikt, en meerdere manieren om commando's te sturen naar
GitHub, moet je uiteraard voorzichtig zijn. Dit hoort niet te gebeuren voor mensen die alleen GitHub Desktop gebruiken.
En het hoort niet te gebeuren bij ontwikkelaars die speciaal gereedschap gebruiken rondom versiebeheer (b.v. Xcode of Visual Studio of IntelliJ).
Zou men toch (net als ik) in de problemen komen, dan kan dit helpen: [configuratie van `git`](https://github.com/orgs/community/discussions/69218)

</details></p>
