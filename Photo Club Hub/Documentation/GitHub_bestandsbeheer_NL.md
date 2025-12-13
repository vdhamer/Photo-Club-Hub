## Bestandsbeheer bij GitHub

Dit stappenplan beschrijft hoe men zich kan aanmelden bij www.github.com
en wijzigingen kan aanbieden zonder dat iemand anders als tussenpersoon moet dienen. 
Het is met name een manier om zelfstandig databestanden (b.v. `mijnClub.level2.json`) of instructies zoals dit document te wijzigen of toe te voegen.

In hoofdlijnen komt het erop neer dat men een gewijzigd bestand kan aanmaken, en deze aanbieden aan het project (__repository__ of __repo__ voor intimi).
Tussen aanbieden en daarwerkelijk opnemen van het gewijzigd bestand zit nog een goedkeuringsstap.
Dit voorkomt dat een willekeurig persoon zomaar een willekeurige wijziging in een willekeurig bestand kan aanbrengen.

De hoofdstappen zijn dus:

1. Gebruiker maakt (eenmalig) een account aan bij GitHub. In principe kan dat account voor meewerken in meerdere GitHub repositories gebruikt worden.
2. Gebruiker maakt (eenmalig) een locale kopie aan van de gewenste repository ([Photo Club Hub](https://github.com/vdhamer/Photo-Club-Hub))
3. Een bestand (eventueel meerdere bestanden) wordt locaal bijgewerkt. Deze stap vereist geen contact met GitHub.com (en vereist dus geen Internet).
3. Gebruiker biedt versie aan bij GitHub voor goedkeuring en opname in het repository. 
4. Ee goedkeuring doet iemand anders, en wordt hier niet beschreven. Hiervoor moet je een soort beheerder zijn van het repository.

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

### 2. Locale "clone" aanmaken via GitHub Desktop

In deze stap installeren we software die hoort bij GitHub: GitHub Desktop.

> Tip: vaak wordt softwareontwikkelaars aangeraden om nog een pakket te installeren: Git.
> We gaan het hier zonder Git te doen: GitHub Desktop is een
> modernere grafische applicatie, terwijl Git hetzelfde (en meer) kan door commando's in te typen.
> Voor professioneel gebruik is `git` handig als iets bijzonders aan de hand is. Maar dat hopen wij te vermijden.

En gebruiken dat om een lokale (op eigen computer) kopie te maken van __alle__ bestanden in het Photo Club Hub repository.






