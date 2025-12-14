## Bestandsbeheer bij GitHub

Deze procedure beschrijft hoe men zich kan aanmelden bij www.github.com
en wijzigingen in Photo Club Hub gegevensbestanden kan aanbieden zonder dat hiervoor een tussenpersoon nodig is. 
Het is met name een manier om ledenlijsten (zoals `mijnClub.level2.json`) of documentatiebestanden te wijzigen met minimale hulp van derden.
Bestanden toevoegen kan ook, maar krijgt hier minder aandacht.

In hoofdlijnen komt het erop neer dat men een gewijzigd bestand kan aanmaken, en deze aanbieden aan het project ("__Repository__" ofwel "__Repo__").
Tussen aanbieden en daarwerkelijk opnemen van het gewijzigd bestand zit nog een goedkeuringsstap.
Dit voorkomt dat een willekeurig iemand zomaar een willekeurige wijziging in een willekeurig bestand kan aanbrengen.
De goedkeuringsdetails worden hier moet beschrevem omdat iemand anders dat voor je doet.

De hoofdstappen zijn dus:

1. Gebruiker maakt (eenmalig) een account aan bij GitHub. Dat account geldt voor _alle_ GitHub Repositories.
2. Gebruiker maakt (eenmalig) een locale kopie aan van de gewenste Repository ([Photo Club Hub](https://github.com/vdhamer/Photo-Club-Hub))
3. Een bestand (eventueel meerdere bestanden) wordt locaal bijgewerkt. Deze stap vereist geen contact met GitHub.com (en vereist dus geen Internet).
3. Gebruiker biedt de aangepaste versie aan bij GitHub voor goedkeuring en opname in het Repository. 
4. Ee goedkeuring doet iemand anders, en wordt hier niet beschreven. Hiervoor moet je een soort beheerder zijn van het Repository.

Bij een volgende verandering ga je verder met stap 3. Dus een bstand kan desgewenst in kleine stapjes aangepast worden.

   > Tip: GitHub (of het achterliggende Git) is een zogenaamde versiebeheersystemen ("version control system").
   > Dat houdt in dat het alle bestandswijzigingen nauwlettend bijhoudt. 
   > Git kan ook teams van meerdere personen aan die soms dezelfde bestanden aanpassen.
   > In de praktijk betekent dit dat niemand een wijziging in een bestand kwijt kan raken, 
   > en dat er strict onderscheid gemaakt wordt tussen gedeelde versies en eigen versies.

   > Tip: GitHub is een vrij zwaar systeem. De halve software wereld is afhankelijk van GitHub of verwante systemen.
   > Mini-kursusen op b.v. YouTube over GitHub en Git zijn vaak gericht op softwareontwikkelaars.
   > Ze omvatten meer toeters en bellen van Git(Hub) dan wat wij hier nodig hebben.
   > En de meeste softwareontwikkelaars gebruiken vaak maar een fractie van alle mogelijkheden. 
   > Pas dus op voor afleidingen: concentreer dus alleen op de stappen en begrippen die je hier nodig hebt.
   > Zodra je dat beheerst, kan je altijd nog meer leren.

#### Voordelen van GitHub

<details><summary>Details (klik om uit te klappen)</summary></p>

Voor ons gebruik hier, zijn de voordelen van GitHub:

- VERSIEBEHEER<BR>
Alle versies worden bewaard. Je kunt zien wie wat wanneer gewijzigd heeft.
- SAMENWERKING<BR>
Meerdere mensen kunnen wijzigingen aanbrengen, en versies van elkaar overnemen.
Zonder het risiko van misverstanden of het kwijtraken van een voorgestelde aanpassingen wanneer je dit allemaal handmatig wilt regelen.
- EENVOUDIGE GOEDKEURING<BR>
In het ideale geval kan een ingediende wijziging met 1 druk op de knop goedgekeurd worden. Dit is belangrijk als er b.v.  meerdere voorstellen per dag binnenkomen.
- CENTRALE TO-DO LIJST<BR>
De centrale lijst van uitbreidingsverzoeken of melding van bugs loopt via GitHub. Jij kunt hier zelf een wens of klacht ("issue") toevoegen. En bestaande wensen van jezelf en anderen zien.
- ARCHIEF<BR>
GitHub is in feite het archief voor alle bestanden van dit projekt: code, data, documentatie, "issues". GitHub zelf is extreem secuur dat er niets zoek raakt.
- ONLINE<BR>
De app haalt de huidige gegevens op vanuit GitHub. Hier valt b.v. lijsten met clubs ("Level 1") en lijsten met clubleden ("Level 2"). Hierdoor kan de app de huidige gegevens vinden zodra die aangepast worden. Portfolio inhoud wordt op clubwebsites gehouden en lopen dus niet via GitHub.
- URLs<BR>
Alle bestanden zijn bereikbaar via een webadres (URL). Dat is nuttig voor bijvoorbeeld verwijzingen zoals voor het downloaden van deze [Powerpoint](tinyurl.com/fchPPTnl).
- READ-ONLY<BR>
Wie alleen wil kijken, maar niets wil wijzigen, heeft geen wachtwoord of account bij GitHub nodig.
Bijvoorbeeld om even te kijken naar een databestand of naar documentatie.

</details></p>

## 1. Account aanmaken ("Sign up") bij GitHub

Wie dit ooit eerder gedaan heeft bij GitHub, kan deze stap overslaan.

Een account bij GitHub aanmaken is gratis.

Registratie van een nieuwe GitHub gebruiker gebeurt via de "__Sign up__" knop op de [hoofdpagina van GitHub](https://github.com). 
"Sign up" is dus om je te registreren (account aanmaken). 
"Sign in" is daarentegen als je later aanmeldt bij GitHub ("inloggen") onder het account aangemaakt met "Sign up".

<img width="532" height="889" alt="Screenshot 2025-12-11 at 22 19 03" src="https://github.com/user-attachments/assets/da795207-821c-4a14-bdce-4f156e796d61" />

<details><summary>Details (klik om uit te klappen)</summary></p>

- Wie een Apple account gebruikt, kan "Continue wie Apple" kiezen. Als je dit (of de Google equivalent) gebruikt, ben je snel klaar. Anders...
- Voor toekomstige "sign in" heb jij de combinatie Email/Password straks nodig. Of Username/Password. Je moet alle 3 velden invullen. En alle 3 goed bewaren (desnoods in het "comment" veld van een password app).
   - Email moet uniek zijn. Gebruik geen "hide my Email" Apple iCloud account: dit wordt geweigerd met een slechte foutmelding. Voor de meeste mensen is deze stap geen probleem: hebben bijvoorbeeld een hoofdaccount en een minder gelezen Email account. Desnoods een extra Email account hiervoor aanmaken bij Gmail (een iCloud account dat automatisch doorverwijst kan zoals gezegd problemen geven).
   - Wachtwoord moet uiteraard bewaard worden bij al je andere wachtwoorden.
   - Username moet ook uniek zijn en is een beetje misleidend:
   In de kleine lettertjes staat dat er bijvoorbeeld geen spaties in mogen.
   Het is dus Username in de IT zin, en niet de gewone naam van de gebruiker. Je mag dus wel Jan-Pietersen kiezen maar niet Jan Pietersen. Maar stroopwafelfrisbee mag ook. Ik gebruik zelf "vdhamer" en "vdhamer-for-testing".
- Country is een makkelijke vraag: kan gewoon Netherlands kiezen uit de lijst. Het antwoord is onbelangrijk volgens de kleine lettertjes.
- Op "Create account" klikken resulteert in het standaard ritueel van code ontvangen per Email, en code terugmelden aan GitHub om te controlleren dat het Email adres ok is. En krijg je minstens 1 vraag (op basis van plaatjes of geluid) om aan te tonen dat jij een mens bent. Die "Captcha" tests zijn best lastig bij GitHub.
- GitHub heeft ook alternatieve inlogopties bedoeld voor beroeps ontwikkelaars (SSH, passkeys). Die zijn moderner, maar vereisene meer kennis.

</details></p>

## 2. Locale "clone" aanmaken via GitHub Desktop

In deze stap installeren we eerst locaal software die hoort bij GitHub: GitHub Desktop.

> Tip: vaak wordt (aan softwareontwikkelaars) aangeraden om eerst het prakket Git te installeren.
> We gaan het hier zonder Git doen: GitHub Desktop is een gebruikersvriendelijke
> grafische "schil" om `git`. Git wordt daarentegen (zelfs door de bedenker) als minder gebruiksvriendelijk gezien.

Het nut van GitHub Desktop is:

<details><summary>Details (klik om uit te klappen)</summary></p>

- je kunt je lokale wijziging bijhouden
- je ziet het verschil (op regelbasis) tussen die versie die je aanbied aan GitHub en de vorige versie op GitHub
- tijdens het lokaal werken heb je geen last van wijzigingen gemaakt door anderen
- gelijktijdige wijzigingen van een tekstbestand door iemand worden automatisch gecombineerd met jouw wijzigingen

Waarom is GitHub Desktop eigenlijk nodig, als je een bestand opgeslagen bij GitHub wilt wijzigen?
Dat is ondeermeer omdat, bij het wijzingen van softwarebestanden, men de software lokaal wil bouwen en testen.
Ons gebruik hier is een beetje een uitzonderingsgeval.

</details></p>

### 2.1 GitHub Desktop downloaden en installeren

Via deze [link](https://desktop.github.com/download/) kan je GitHub Desktop gratis downloaded voor Mac of Windows

<img width="968" height="944" alt="Screenshot 2025-12-13 at 23 02 29" src="https://github.com/user-attachments/assets/e080f792-2d87-4a05-8542-eb8375a417d9" />

Er zijn versies voor oude (Intel) en nieuwe generatie (Apple Silicon: M1 - M5) Macs.
Bij Windows krijg je een installatieprogramma dat je moet uitvoeren om het te installeren.
Bij Mac kan je het .zip bestand in de Downloads folder openen. Er de resulterende `GitHub Desktop.app` naar de Applications folder slepen.

Bij het openen van GitHub Desktop krijg je (in ieder geval op de Mac) de vraag of je de app wel vertrouwt.
Gerust "Open" kiezen: er zijn miljoenen gebruikers je voorgegaan.
En GitHub (al jaren deel van Microsoft) is fanatieker dan de meesten op veiligheid.

Vervolgs de keus tussen GitHub.com (👈 deze kiezen) of GitHub Enterprise.

Vervolgens wil het weten wie onder welke naam/wachtwoord jij bekend bent op GitHub.
Dus moet je de gegevens gebruiken die je hierboven in het "Sign up for GitHub" gekozen hebt.
Je browser of wachtwoord app kan hierbij een handje helpen. Maar dit is vergelijkbaar met
allerlei andere online diensten.

<img width="395" height="647" alt="Screenshot 2025-12-13 at 23 21 24" src="https://github.com/user-attachments/assets/8060a991-a12a-45cd-9c87-4f94cd1c7b6a" />

Je krijgt nog een veiligheidsvraag van je Internet browser (Safari, Chrome, Edge, Firefox). Dat zal er ongeveer zo uitzien:

```
   Do you want to allow this website to open "GitHub Desktop"?
```

Dit is omdat je op dat punt overschakelt van browser naar een lokaal programma. Dat mag niet zomaar.
Maar je kunt de GitHub Desktop applicatie ook zelf opstarten via een ikoontje in Applications of in een Start menu (Windows).

### 2.2 Verbinding instellen naar GitHub

Hiermee heb je een werkende GitHub Desktop. Maar bij opstarten krijg je nog een vraag:
Het wachtwoord is al bekend van stap 2.1. Maar het wil eigenlijk nog de gekopen e-mail adres hebben:

<img width="1028" height="728" alt="Screenshot 2025-12-13 at 23 30 56" src="https://github.com/user-attachments/assets/fb96dc61-83d8-4ec7-b9a6-5d16cd249eee" />

Ook hier de invoer kloppen met de gegevens die je hierboven in het "Sign up for GitHub" gekozen hebt.

GitHub Desktop weet (via GitHub) dat jij geen eigen "Repository" (project) heb.
Dus biedt het aan een te maken (mag van mij, maar misschien iets om later mee te spelen: ).
En biedt het aan om mee te helpen aan een bestaande Repository. Dat is de bedoeling: vdhamer/Photo-Club-Hub.

<img width="1072" height="772" alt="Screenshot 2025-12-13 at 23 39 00" src="https://github.com/user-attachments/assets/bf910eab-42d5-4b8a-9202-4257cf1e7d8f" />

Kies hier dus "Clone a Repository from the Internet...". <BR><BR> Waarna je (b.v.) URL kiest:

<img width="497" height="292" alt="Screenshot 2025-12-13 at 23 51 23" src="https://github.com/user-attachments/assets/7914ae4c-d2e2-491e-afa4-aa1f62e19749" />

Voordat je Clone klikt: dit gaat alle bestanden van dit projekt (in hun huidige versie) copieren naar de opgegeven locatie.
Ik koos voor een directory "Photo-Club-Hub" binnen een nieuwe directory "GitHub" binnen nieuwe/bestaande directory "Developer".
Maar dit mag je zelf weten: bij documenten, losse drive, in peter/Developer. 
Het is ongetwijfeld daarna aanpasbaar, maar het is het simpelst als je nu even goed nadenkt:
"waar kan ik honderden MegaBytes voor onbepaalde tijdsduur stallen zodat ik terug vind?".
Op de Mac is /Users/mijnAccount/Developer gebruikelijk. Dan krijg je een mooi geel ikoon.

> Tip: Op verjaardagsfeestjes kan je nerds imponeren met het feit dat jij "op GitHub" zit.
> Het is tenslotte best iets om trots op te zijn. Heel Git is bepaald niet simpel.
> Maar wij gebruiken hier maar enkele procent van de totale mogelijkheden.
> GitHub heeft 500 honderd miljoen Repositories en meer dan honderd miljoen gereistreerde gebruikers. De meeste gebruikers zitten
> in de software industrie. Maar het is voor meerdere soorten documentbeheer bruikbaar: [GitHub for poets 1.1 tutorial](https://www.youtube.com/watch?v=BCQHnlnPusY).

### 2.3 Wat zien we inmiddels?

<img width="1072" height="772" alt="Screenshot 2025-12-14 at 00 09 29" src="https://github.com/user-attachments/assets/645261ec-7836-4931-80e5-86e60bb0e5a3" />

Zo ziet GitHub Desktop eruit bij 1 locale clone van het GitHub Repository vdhamer/Photo-Club-Hub:

- "Current Repository" zegt dat je nu bezig bent in het Photo-Club-Hub projekt
- "Main branch" betekent dat je niet bezig bent met een tijdelijk subprojekt. Voor ons volstaat "Main" omdat we relatief kleine aanpassingen doen.
- "Fetch origin" ververst jou locale copie van de Repository vanuit GitHub. Lokale aanpassingen (op eigen computer) worden hierbij niet overschreven. Als het bestand waaraan je werkt op GitHub inmiddels aangepast is, dan 
- Er is een knop om een teksteditor te openen. In mijn geval (Mac) is dat "Sublime Text". "Notepad++" wordt veel gebruikt voor dit soort bestanden onder Windows.
- Er is een knop om de folder te bekijken (in Finder op Mac, of Explorer onder Windows).
- Je kunt ook de Repository bekijken op GitHub via jouw browser. Ik denk dat dat (behalve voor de "owner") alleen bekijken en niet wijzigen betreft.

Ik zou "View file is your Repository in Finder/Explorer" maar kiezen. 
En dan op zoek gaan naar het bestand dat je aan wilt passen. En met een locale editor (Sublimte Text, Notepad++, etc) aanpassen.

Dat ziet op een Mac zo uit (Windows iets soortgelijks).

<img width="1032" height="576" alt="Screenshot 2025-12-14 at 00 27 12" src="https://github.com/user-attachments/assets/1bc3738a-b2ed-4c85-b7c4-0534a8e98744" />

Dit is dus de standaard bestandsbeheer van MacOS of Windows. Met een onzichtbaar maar belangrijk verschil:
GitHub Desktop regelt het op de hoogte houden van het centrale ("origin") Repository in Github van jouw wijzigingen.
GitHub/Git kan je ook lokaal vertellen (en tonen) wat er in welke versie gewijzigd is.
Hiervoor houdt GitHub/Git automatisch een hele administratie bij in een verborgen directory.


