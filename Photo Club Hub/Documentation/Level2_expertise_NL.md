## FAQ over `Expertise` in level2.json bestanden

In Level 2 bestanden kan men nul, één of twee expertise tags opgeven voor ieder clublid.
Het aanmaken en het formaat van Level 2 bestanden is beschreven in
[Level2_aanmaken_NL](https://github.com/vdhamer/Photo-Club-Hub/blob/main/Photo%20Club%20Hub/Documentation/Level2_aanmaken_NL.md).
Deze FAQ gaat over het doel en optimale gebruik van het `expertise` begrip.

## Basisvragen

<details><summary>Klik om categorie open of dicht te klappen</summary></p>
<ul>

<li>

### Wat is een `Expertise` tag?

<details><summary>Klik om antwoord open of dicht te klappen</summary></p>
Met `expertise` bedoelen we de soorten fotografie waarin een fotograaf zich heeft bekwaamd.
De app gebruikt `expertise` tags om aan te geven dat b.v. Rob zich toespitsts heeft op "Abstracte" fotografie. 
Hiermee kan je Rob en zijn werk eenvoudig vinden door op "abstract" of "abs" te zoeken
in de zoekbalk van het `Portfolio` scherm.
</details></p>

</li><li>

### Waar ziet een gebruiker de `expertises` van een fotograaf?

<details><summary>Klik om antwoord open of dicht te klappen</summary></p>

1. In de HTML/web versie van de app staat dit vermeld in een kolom "expertise tags" in de tabellen met clubleden.
2. In de iOS versie zie je de beschikbare expertises bij iedere fotograaf op de `Portfolio` pagina.
3. In de iOS versie staan de beschikbare expertise tags helemaal onderaan de `Fotografen` pagina.
   Om snel onderaan te komen, zoek op "expertise" of "zzz". Deze locatie gaat veranderen in een toekomstige versie.
4. In de iOS versie, kan men **zoeken** op expertiseg tag door de eerste paar letters in te tikken in de zoekbalk.
   Dus intypen van "zwart" reduceert de lijst tot fotografen die aan "zwart-wit" gekoppeld zijn.
   Maar dit kan ook namen tonen zoals "Kees de Zwart": deze zoekbalk zoekt gelijktijdig op naam en op expertise tags.
</p>

En op termijn komen er ook zoekfuncties op `expertise` in de HTML versie:

1. In de HTML versie, moeten de getoonde expertises **klikbare links** worden. Dit brengt je naar een lijst met alle fotografen met die expertise.
2. In de HTML versie, is er al een **aparte pagina**  met een (klikbare) lijst met alle beschikbare expertise tags.
Hiermee kan je zien welke expertise tags bestaan, wat de bijbehorende omschrijving is,
en hoeveel fotografen in de app hieraan gekoppeld zijn.
</details></p>

</li><li>

### Wat is de bedoeling eigenlijk?

<details><summary>Klik om antwoord open of dicht te klappen</summary></p>
Stel dat er tien, honderd of zelfs duizend clubs meedoen, met gemiddeld 15 leden per club.
Dan zijn er bijvoorbeeld 150, 1500 of zelfs 15.000 fotografen in de app. 
De app bevat zoekfuncties waarmee je op naam van de fotograaf kunt zoeken. Hier vind je bekenden mee.
Met expertise tags kan je ook fotografen vinden op basis van hun specialisme.
</details></p>

</li><li>

### Hoeveel expertisegebieden per clublid?

<details><summary>Klik om antwoord open of dicht te klappen</summary></p>
Maximaal twee. Bij meer expertises gaat de app bewust een beetje klagen.</p>

De gedachte hierachter is dat een zoekopdracht net als bij Google Search vooral _relevante_ resultaten oplevert. 
In het ideale geval bevestigen de gevonden portfolio's de specialisme waarop gezocht is.
</details></p>

</li><li>

### Kan iemand ook nul Expertises hebben?

<details><summary>Klik om antwoord open of dicht te klappen</summary></p>
Ja, dat mag. Dat kan drie verschillende redenen hebben:

1. Iemand heeft geen duidelijk specialisme ("ik fotografeer wat ik toevallig tegenkom").
2. Iemand wil - om wat voor reden dan ook - die informatie niet delen.
3. De informatie is momenteel nog niet verzameld door de club of is nog niet in de app ingevoerd.

</details></p>

</li><li>

### Hoeveel en welke expertise tags zijn beschikbaar?

<details><summary>Klik om antwoord open of dicht te klappen</summary></p>
In de iOS versie van de app staat alle beschikbare expertise tags helemaal onderaan de `Fotografen` pagina
(zoek op "expertise" of "xyz").
Deze lijst is dynamisch (online opgehaald): het kan dat er volgende week een nieuw gebied bijgekomen is. 
Het zijn er al ruim 20.</p>

De HTML versie heeft een pagina met de [lijst](https://www.fcDeGender.nl/expertises) van expertises.
Verder kan je de actuele lijst (in JSON formaat) [hier](https://github.com/vdhamer/Photo-Club-Hub/blob/main/JSON/root.level0.json) bekijken.
</details></p>

</li></ul>

</details></p>

## Richtlijnen

<details><summary>Klik om categorie open of dicht te klappen</summary></p>
<ul>

<li>

### Kunnen de expertise tags van een fotograaf veranderen?

<details><summary>Klik om antwoord open of dicht te klappen</summary></p>
Zeker. De gekozen gebieden zijn bedoeld als huidige expertise.
Iemand kan dingen bijleren of van focusgebied verschuiven.

</details></p>

</li><li>

### Waarom maximaal twee expertise tags per fotograaf?

<details><summary>Klik om antwoord open of dicht te klappen</summary></p>
De gedachte is dat een zoekopdracht, net als bij Google Search, zo relevant mogelijke resultaten hoort op te leveren.
Mischien niet met precies de soort architectuurfotografie die je zocht, maar wel iets redelijk in de buurt.
We willen voorkomen dat je bij een portfolio lang moet bladeren voordat je een enkele verdwaalde architectuurfoto tegenkomt.</p>

Het is dus _niet_ de bedoeling dat de fotograaf tracht om al zijn werk in een groot aantal bakjes te vangen.
Het hebben van veel "specialismes" impliceert eigenlijk "geen specialismes".

</details></p>

</li><li>

### Hoeveel expertise tags komen er?

<details><summary>Klik om antwoord open of dicht te klappen</summary></p>
Dat moet blijken. We mikken op maximaal honderd. Criteria:</p>

- Wikipedia gebieden t.a.v. fotografieonderwerp ("portret") of techniek ("zwart/wit") zijn meestal geschikt.
- Het moet vrij duidelijk zijn wat de specialisme betekent (dus liever niet een term zoals "ICM").
- Liefst weinig overlap met bestaande tags. "Natuur" is b.v. onhandig als er ook "landschappen" en "wilde dieren" categorieën zijn.
- Er moeten meerdere beoefenaars te verwachten zijn. Maar het hoeven niet persé veel beoefenaars te zijn.
- Die beoefenaars moeten zichzelf als (amateur)fotografen zien. Bij een verzamelaar van foto's van gespotte vliegtuigen
gaat het vaak meer om het vliegtuig dan om de foto. 

Naarmate er meer fotografen aan boord komen, zal de lijst geleidelijk groeien.
We willen proberen onder de 100 te blijven (ook bij veel fotografen) omdat dit anders keuzeproblemen geeft.
</details></p>

</li><li>

### Fijnmazigheid?

<details><summary>Klik om antwoord open of dicht te klappen</summary></p>
Een klein expertisegebied met slechts een handjevol beoefenaars is op zich geen probleem.
Het is namelijk voor die beoefenaars en geïnteresserden vaak extra waardevol. 
  
Dit is net als bij liefhebbers van bijzondere categorieen muziek of boeken.
Maar het is handig als het minimale overlap geeft met andere categorieën.

Het moet echter ook weer niet zo klein is dat er maar één persoon belangstelling in heeft. 
Een te grote expertisegebied ("buitenfotografie") levert minder waarde, en geeft kans op overlap met andere categorieën ("landschap", "street").
</details></p>

</li><li>

### Wie beheert de lijst met expertise tags?

<details><summary>Klik om antwoord open of dicht te klappen</summary></p>
Vooralsnog de maker(s) van de app. Het is echter een dienstverlening, en de lijstbeheerder moet voortdurend contact houden met gebruikers.
</details></p>

</li><li>

### Project versus specialisme?

<details><summary>Klik om antwoord open of dicht te klappen</summary></p>
Een langlopend project kan lijken op een expertise: iemand kan er bekend om zijn.
Maar er zijn verschillen: een project is in principe van _tijdelijke_ aard. 
En een expertise is vaak algemener en kan dus van pas komen bij meerdere projekten.
</details></p>

</li></ul>

</details></p>

## Technische bijkomstigheden

<details><summary>Klik om categorie open of dicht te klappen</summary></p>
<ul>

<li>

### Meertalige weergave

<details><summary>Klik om antwoord open of dicht te klappen</summary></p>
Ondersteunde expertisetags kunnen in de app weergegeven worden in het Nederlands en in het Engels.
Als een fotograaf gekoppeld is aan zwart-wit fotografie, wordt dat afhankelijk van omstandigheden dus automatisch in de juiste taal weergegeven ("Zwart-wit", "Black & White").
Als de app een onbekende expertise tag tegenkomt, wordt er niet vertaald. En is er een waarschuwing te zien - mede omdat het en invoerfout kan zijn.
</details></p>

</li><li>

### Een-talige invoer

<details><summary>Klik om antwoord open of dicht te klappen</summary></p>
Bij het toekennen van expertise tags aan fotografen gebruik je meestal de Engelse term.
Maar die interne identificatie (`idString`) binnenin de app kan afwijken van wat er in het Engels getoond wordt.

Dus strict genomen zijn er 3 benaming voor een expertise tag:
1. een identificatie zoals "Bird", gebruikt on aan te geven welk expertise we bedoelen. Dit zal meestal overeenkomen met (2), maar dat _hoeft_ niet.
2. een Engelstalige weergavetekst zoals "Birds", dat getoond wordt aan Engelstalige gebruikers.
3. een Nederlandsetalige weergavetekst zoals "Vogels", dat getoond wordt aan Nederlandstalige gebruikers.

</details></p>

</li><li>

### Expertisetags en clubs

<details><summary>Klik om antwoord open of dicht te klappen</summary></p>
De app koppelt expertisetags aan personen - dus onafhankelijke van enig clubverband.</p>
  
Maar de expertise tags worden door clubs ingevoerd.
Dus een fijnproever kan zich afvragen: "als Jan lid is van Club 1 en Club 2, 
en de beide clubs vullen wat andere `Expertise` tags in voor Jan. Wat doet de app dan?".

Goede vraag! De beide lijsten van expertises van Jan worden intern automatisch
samengevoegd. Als de lijsten identiek zijn, merkt de gebruiker daar helemaal niets van.
Als er maar één lijst voor Jan betaat, zie je die tags bij beide (lees: alle) clubs van Jan.
Maar als Club 1 "Portret" en "Abstract" vermeldt, terwijl Club 2 "Abstract" en "Landschap" vermeldt, dan worden de 2 lijsten intern samengevoegd tot
"Portret" en "Abstract" en "Landschap".

Als de gecombineerde lijst te lang is, en Jan nog steeds contact heeft met beide groepen,
mag Jan dat verder regelen. Bijvoorbeeld door de bijde lijsten gelijk te trekken of alle lijsten - op één na - leeg te laten maken.
</details></p>

</li><li>

### Teveel expertise tags per fotograaaf?

<details><summary>Klik om antwoord open of dicht te klappen</summary></p>
Bij 3 of meer tags, meldt de app "Teveel Expertises" op de plek van het 3e element.
Dit moet de club aanmoedigen om het te corrigeren.
</details></p>

</li><li>

### Fouten bij invoeren `expertises`?

<details><summary>Klik om antwoord open of dicht te klappen</summary></p>

Wat gebeurt als een Level 2 bestand een onbekende `expertise` tag bevat die niet bekend is in de app?
Voorbeeld: een bestand bevat "Model" terwijl alleen "Portrait" ondersteund wordt.
De app toont dan "Model" - maar met een speciaal groen ikoon.
Het ikoon en bijbehorende 'tooltip' geven aan dat dit op dit moment geen officeel "ondersteunde" ""tag is.
De app meldt expliciet dat daardoor geen vertalingen beschikbaar zijn: die zijn alleen mogelijk voor ondersteunde expertise tags. 
Dit kan ertoe leiden dat de club de eventuele fout corrigeert of het vervangt door naar een verwante, ondersteunde expertise tag.
Maar andere uitkomst is dat "Model" op een gegeven moment gepromoveerd wordt tot een ondersteunde `expertise`.
Dit kan gebeuren als de "tijdelijke" tag welliswaar nieuw is, maar nuttig lijkt voor toekomstig gebruik.
Het groene ikoon en de waarschuwing verdwijnen dan automatisch zodra de app ziet dat "Model" inmiddels een ondersteunde tag geworden is.
</details></p>

</li>
