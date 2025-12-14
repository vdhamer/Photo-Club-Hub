## Bestandsbeheer bij GitHub

Dit document beschrijft de procedures nodig om zich aan te melden bij www.github.com
en om wijzigingen in _Photo Club Hub_ bestanden aan te bieden zonder dat hiervoor een tussenpersoon nodig is. 
Het is met name bedoeld om ledenlijsten (zoals `mijnClub.level2.json`) of documentatiebestanden (zoals dit bestand) 
te wijzigen met minimale afhankelijkheid van derden.

Het is ook mogelijk om nieuwe bestanden toe te voegen of bestaande bestanden te verwijderen.
Maar dat krijgt hier geen aandacht omdat dit ongeveer op vrijwel dezelfde manier gaat.

In hoofdlijnen komt het erop neer dat men een gewijzigd bestand kan aanmaken, en deze aanbieden aan het project ("__Repository__" ofwel "__Repo__").
Tussen aanbieden en daadwerkelijk in gebruik nemen zit nog een __goedkeuringsstap__.
De goedkeuringsstap voorkomt dat men zomaar een willekeurige wijziging in een willekeurig bestand kan aanbrengen.
De goedkeuringsprocedure wordt hier moet beschreven omdat een Repository beheerder dat moet doen.

### Alvast een samenvatting

De hoofdstappen zijn dus:

1. De gebruiker maakt (eenmalig) een account aan bij GitHub. Dat account is geldig voor _alle_ GitHub Repositories.
2. De gebruiker maakt (eenmalig, via GitHub Desktop) een lokale kopie aan van de _complete_ [Photo Club Hub](https://github.com/vdhamer/Photo-Club-Hub) Repository.
3. Een bestand (of bestanden) wordt lokaal (op de eigen computer) aangepast. Deze stap kan zonder Internet verbindingen. De stap mag zo lang duren als nodig (minuten … dagen).
4. De gebruiker biedt de aangepaste versie aan (weer via GitHub Desktop) bij de centrale Repository voor goedkeuring door de Repo beheerder(s).

Bij een eventuele volgende verandering herhaal je stappen 3 en 4.
Dus een bestand hoeft niet in een keer af, maar dient ten tijde van de goedkeuring wel bruikbaar zijn.
Voor eventuele volgende veranderingen hoef je overigens niet te wachten totdat eerdere versies goedgekeurd zijn.

   > Tip: GitHub (of het achterliggende Git) is een zogenaamde versiebeheersystemen (_version control system_).
   > Dat houdt in dat het alle aangeboden bestandswijzigingen nauwlettend bijhoudt. 
   > Git kan ook teams aan waarbij soms 2 personen vrijwel gelijktijdig hetzelfde bestand aanpassen.
   > In de praktijk betekent dit dat Git zorgt dat niemand een wijziging in een aangeboden bestand kwijt raakt.

   > Tip: GitHub is een vrij complex systeem. De hele software-industrie is afhankelijk van GitHub en verwante systemen.
   > Mini-cursussen op YouTube over GitHub en Git zijn vaak bedoeld voor softwareontwikkelaars.
   > Ze beschrijven dan meer toeters en bellen van Git(Hub) dan wat wij hier nodig hebben.
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
Git(Hub) is als het ware de stoplichten die het dataverkeer tussen de verschillende partijen regelt: soms hinderlijk, maar het heeft zo zijn reden.

- EENVOUDIGE GOEDKEURING<BR>
In het ideale geval kan een ingediende wijziging met 1 druk op de knop goedgekeurd worden. Dit is essentieel als er continue meerdere wijzigingsvoorstellen per dag binnenstromen.

- ARCHIEF<BR>
GitHub is in feite het werkarchief voor alle bestanden van dit project: code, data, documentatie, "Issues". GitHub zelf is extreem secuur dat er niets zoekraakt.

- ONLINE<BR>
De Photo Club Hub apps halen de huidige gegevens op vanuit GitHub.
Dit zijn vooral lijsten met clubs ("Level 1") en lijsten met clubleden ("Level 2").
Hierdoor kan de app de huidige meest recente gegevens ophalen.
Portfolio foto's ("Level 3") worden daarentegen op de clubwebsites gehouden:
dit zijn grote aantallen grotere bestanden. Het zorgt er verder voor dat clubwebsites losstaan van GitHub.

- URLs<BR>
Alle bestanden hebben een webadres (URL). Dat is nuttig voor bijvoorbeeld verwijzingen zoals voor het downloaden van [de introductie Powerpoint](tinyurl.com/fchPPTnl).

- CENTRALE TO-DO LIJST<BR>
De centrale lijst van uitbreidingsverzoeken of het aanmelden van bugs loopt via GitHub.
Jij kunt zo zelf een wens of klacht ("Issue") toevoegen.
En kijken of de klacht al bekend is. En commentaar en ideeën leveren bij Issues.

- READ-ONLY<BR>
Wie alleen wil kijken, maar niets wil wijzigen, heeft geen wachtwoord of account bij GitHub nodig.
Bijvoorbeeld om even te kijken naar een databestand of naar documentatie. Dus read-only gebruikers hebben dit document niet nodig.

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
- Op "Create account" klikken resulteert in het standaard ritueel van code ontvangen per Email, en code terugmelden aan GitHub om te controleren dat het Email adres ok is. En krijg je minstens 1 vraag (op basis van plaatjes of geluid) om aan te tonen dat jij een mens bent. Die "Captcha" tests zijn best lastig bij GitHub.
- GitHub heeft ook alternatieve inlogopties bedoeld voor beroeps ontwikkelaars (SSH, passkeys). Die zijn moderner, maar vereisen meer kennis.

</details></p>

## 2. Lokale "clone" aanmaken via GitHub Desktop

In deze stap installeren we eerst lokaal software die hoort bij GitHub: GitHub Desktop.

> Tip: vaak wordt (aan softwareontwikkelaars) aangeraden om eerst het pakket Git te installeren.
> We gaan het hier zonder Git doen: GitHub Desktop is een gebruikersvriendelijke
> grafische "schil" om `git`. Git wordt daarentegen (zelfs door de bedenker) als minder gebruiksvriendelijk gezien.

Het nut van GitHub Desktop is:

<details><summary>Details (klik om uit te klappen)</summary></p>

- je kunt je lokale wijziging bijhouden
- je ziet het verschil (op regelbasis) tussen die versie die je aanbied aan GitHub en de vorige versie op GitHub
- tijdens het lokaal werken heb je geen last van wijzigingen gemaakt door anderen
- gelijktijdige wijzigingen van een tekstbestand door iemand worden automatisch gecombineerd met jouw wijzigingen

Waarom is GitHub Desktop eigenlijk nodig, als je een bestand opgeslagen bij GitHub wilt wijzigen?
Dat is ondermeer omdat, bij het wijzingen van softwarebestanden, men de software lokaal wil bouwen en testen.
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

Vervolgens de keus tussen GitHub.com (👈 deze kiezen) of GitHub Enterprise.

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
Maar je kunt de GitHub Desktop applicatie ook zelf opstarten via een icoontje in Applications of in een Start menu (Windows).

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

<img width="518" height="313" alt="Screenshot 2025-12-13 at 19 14 34" src="https://github.com/user-attachments/assets/079eceae-efec-45da-84be-41ef36436365" />

Voordat je Clone klikt: dit gaat alle bestanden van dit project (in hun huidige versie) kopiëren naar de opgegeven locatie.
Ik koos voor een directory "Photo-Club-Hub" binnen een nieuwe directory "GitHub" binnen nieuwe/bestaande directory "Developer".
Maar dit mag je zelf weten: bij documenten, losse drive, in peter/Developer. 
Het is ongetwijfeld daarna aanpasbaar, maar het is het simpelst als je nu even goed nadenkt:
"waar kan ik honderden Megabytes voor onbepaalde tijdsduur stallen zodat ik terug vind?".
Op de Mac is /Users/mijnAccount/Developer gebruikelijk. Dan krijg je een mooi geel icoon.

> Tip: Op verjaardagsfeestjes kan je nerds imponeren met het feit dat jij "op GitHub" zit.
> Het is tenslotte best iets om trots op te zijn. Heel Git is bepaald niet simpel.
> Maar wij gebruiken hier maar enkele procent van de totale mogelijkheden.
> GitHub heeft 500 honderd miljoen Repositories en meer dan honderd miljoen gereistreerde gebruikers. De meeste gebruikers zitten
> in de software industrie. Maar het is voor meerdere soorten documentbeheer bruikbaar: [GitHub for poets 1.1 tutorial](https://www.youtube.com/watch?v=BCQHnlnPusY).

### 2.3 Wat zien we inmiddels?

<img width="1072" height="772" alt="Screenshot 2025-12-14 at 00 09 29" src="https://github.com/user-attachments/assets/645261ec-7836-4931-80e5-86e60bb0e5a3" />

Zo ziet GitHub Desktop eruit bij 1 lokale clone van het GitHub Repository vdhamer/Photo-Club-Hub:

- "Current Repository" zegt dat je nu bezig bent in het Photo-Club-Hub project
- "Main branch" betekent dat je niet bezig bent met een tijdelijk subproject. Voor ons volstaat "Main" omdat we relatief kleine aanpassingen doen.
- "Fetch origin" ververst jou lokale kopie van de Repository vanuit GitHub. Lokale aanpassingen (op eigen computer) worden hierbij niet overschreven. Als het bestand waaraan je werkt op GitHub inmiddels aangepast is, dan 
- Er is een knop om een teksteditor te openen. In mijn geval (Mac) is dat "Sublime Text". "Notepad++" wordt veel gebruikt voor dit soort bestanden onder Windows.
- Er is een knop om de folder te bekijken (in Finder op Mac, of Explorer onder Windows).
- Je kunt ook de Repository bekijken op GitHub via jouw browser. Ik denk dat dat (behalve voor de "owner") alleen bekijken en niet wijzigen betreft.

Ik zou "View file is your Repository in Finder/Explorer" maar kiezen. 
En dan op zoek gaan naar het bestand dat je aan wilt passen. En met een lokale editor (Sublimte Text, Notepad++, etc) aanpassen.

Dat ziet op een Mac zo uit (Windows iets soortgelijks).

<img width="1032" height="576" alt="Screenshot 2025-12-14 at 00 27 12" src="https://github.com/user-attachments/assets/1bc3738a-b2ed-4c85-b7c4-0534a8e98744" />

Dit is dus de standaard bestandsbeheer van MacOS of Windows. Met een onzichtbaar maar belangrijk verschil:
GitHub Desktop regelt het op de hoogte houden van het centrale ("origin") Repository in Github van jouw wijzigingen.
GitHub/Git kan je ook lokaal vertellen (en tonen) wat er in welke versie gewijzigd is.
Hiervoor houdt GitHub/Git automatisch een hele administratie bij in een verborgen directory.


