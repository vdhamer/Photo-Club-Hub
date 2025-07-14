## FAQ over `Expertise` in level2.json bestanden

In Level 2 bestanden kan men nul, één of twee expertise tags opgeven voor ieder clublid.
Het aanmaken en het formaat van Level 2 bestanden is omschreven in
[Level2_aanmaken_NL](https://github.com/vdhamer/Photo-Club-Hub/blob/main/Photo%20Club%20Hub/Documentation/Level2_aanmaken_NL.md).
Deze FAQ gaat over het doel en optimale gebruik van `expertise`.

## Basisvragen

<details><summary>Klik om categorie open of dicht te klappen</summary></p>
<ul>

<li>

### Wat is een `Expertise` tag?

<details><summary>Klik om antwoord open of dicht te klappen</summary></p>
Met `expertise` bedoelen we de soorten fotografie waar een fotograaf zichzelf in bekwaamd heeft.
De app gebruikt `expertise` tags om aan te geven dat b.v. Rob zich toespitsts op "Abstracte" fotografie. 
Hiermee kan je Rob en zijn werk eenvoudig vinden door op "abstract" of "abs" te zoeken
in de zoekbank van het `Portfolio` scherm.
</details></p>

</li><li>

### Waar ziet een gebruiker de gemelde `expertises`?

<details><summary>Klik om antwoord open of dicht te klappen</summary></p>

1. In de HTML/web versie van de app, staan ze vermeld in een kolom "expertise tags" in de diverse tabellen met clubleden.
2. In de iOS versie zie je de beschikbare expertises bij iedere fotograaf op de `Portfolio` pagina.
3. In de iOS versie staan de beschikbare expertise tags helemaal onderaan de `Namenlijst` pagina.
   Om snel onderaan te komen, zoek op "expertise" of "zzz".
4. In de iOS versie, kan men **zoeken** op expertiseg tag door de eerste paar letters in te tikken in de zoekbalk.
   Dus intypen van "zwart" reduceert de lijst tot fotografen die aan "zwart-wit" gekoppeld zijn.
   Maar dit kan ook namen tonen zoals "Kees de Zwart": deze zoekbalk zoekt gelijktijdig op naam en op expertise tags.
</p>

En op termijn komen er ook zoekfuncties op `expertise` in de HTML versie:

1. In de HTML versie, moeten de getoonde expertises **klikbare links** worden. Dit brengt je naar een lijst met alle fotografen met die expertise.
2. In de HTML versie, moet er nog een **aparte pagina** komen met een (klikbare) lijst met alle beschikbare expertise tags.
Hiermee kan je zien welke expertise tags er zijn, wat de bijbehorende toelichting is,
en hoeveel fotografen in de app hieraan gekoppeld zijn. Verder is het dan ook mogelijk om te klikken op een expertise
tag om alle bijbehorende leden in alle beschikbare clubs te vinden.
</details></p>

</li><li>

### Wat is de bedoeling eigenlijk?

<details><summary>Klik om antwoord open of dicht te klappen</summary></p>
Stel dat er tien, honderd of zelfs duizend clubs meedoen, met gemiddeld 15 leden per club.
Dan zijn er 150, 1500 of zelfs 15.000 fotografen bekend in de app. 
De app bevat zoekfuncties waarmee je op naam van de fotograaf kunt zoeken. Hier vind je bekenden mee.
Met expertise tags kan je ook fotografen vinden op basis van hun specialismes.
</details></p>

</li><li>

### Hoeveel expertisegebieden per clublid?

<details><summary>Klik om antwoord open of dicht te klappen</summary></p>
Maximaal twee. Bij meer expertises gaat de app bewust een beetje moeilijk doen.</p>

De gedachte hierachter is dat een zoekopdracht net als bij Google Search vooral relevante resultaten oplevert. 
We willen liefs hebben dat de gevonden portfolio's duidelijk de opgegeven specialismes bevestigen.
</details></p>

</li><li>

### Kan iemand ook geen Expertises hebben?

<details><summary>Klik om antwoord open of dicht te klappen</summary></p>
Ja. Dat kan drie verschillende redenen hebben:

1. Iemand heeft dus geen duidelijk specialisme ("ik fotografeer wat ik toevallig tegenkom").
2. Iemand wil - om wat voor reden dan ook - die informatie niet delen.
3. De informatie moet door de club nog verzameld en ingevoerd worden.

</details></p>

</li><li>

### Hoeveel en welke expertise tags zijn beschikbaar?

<details><summary>Klik om antwoord open of dicht te klappen</summary></p>
In de iOS versie van de app staat alle beschikbare expertise tags helemaal onderaan de `Namenlijst` pagina (zoek op "expertise" of "xyz").
Deze lijst is dynamisch (online opgehaald): het kan dat er volgende week een nieuw gebied bijgekomen is. Het zijn er al ruim 20.</p>

De HTML versie krijgt wellicht een extra pagina met diezelfde lijst. 
Verder kan je de actuele lijst (in JSON formaat) [hier](https://github.com/vdhamer/Photo-Club-Hub/blob/main/JSON/root.level0.json) inzien.
</details></p>

</li></ul>

</details></p>

## Richtlijnen

<details><summary>Klik om categorie open of dicht te klappen</summary></p>
<ul>

<li>

### Kunnen de expertise tags veranderen over de jaren?

<details><summary>Klik om antwoord open of dicht te klappen</summary></p>
Zeker. De gekozen gebieden zijn bedoeld als huidige expertise.
Iemand kan dingen bijleren of van focusgebied verschuiven.

</details></p>

</li><li>

### Waarom hooguit twee expertise tags per fotograaf?

<details><summary>Klik om antwoord open of dicht te klappen</summary></p>
De gedachte is dat een zoekopdracht, net als bij Google Search, zo relevant mogelijke resultaten vindt.
Mischien niet met precies de soort architectuurfotografie die je zocht, maar wel redelijk in de buurt.
We willen voorkomen dat je bij een portfolio lang moet bladeren voordat je een enkele verdwaalde architectuurfoto tegenkomt.</p>

Het is dus _niet_ de bedoeling dat de fotograaf tracht om al zijn werk in een groot aantal bakjes te vangen.
Het hebben van veel "specialismes" neigt eigenlijk naar "geen specialismes".
De app vereist niet dat iedereen specialismes heeft; sommige fotografen hebben nu eenmaal (nog) geen herkenbaar specialisme.

</details></p>

</li><li>

### Hoeveel expertise tags komen er?

<details><summary>Klik om antwoord open of dicht te klappen</summary></p>
Dat moet blijken. We mikken op maximaal honderd. Criteria:</p>

- Wikipedia gebieden t.a.v. fotografieonderwerp ("portret") of techniek ("zwart/wit") zijn meestal prima.
- Het moet vrij duidelijk zijn wat eronder valt.
- Liefst weinig overlap met bestaande gebieden. "Natuur" is b.v. onhandig als er ook "landschappen" en "wilde dieren" categorieën zijn.
- Er moeten meerdere beoefenaars te verwachten zijn. Maar het hoeven niet veel te zijn.
- Die beoefenaars moeten zichzelf als (amateur)fotografen zien. Bij een verzamelaar van foto's van vliegtuig spotter
gaat het vaak meer over het vliegtuig danwel de belevenis, maar nauwelijks over de fotografische kant. 

Naarmate er meer fotografen aan boord komen, zal de lijst geleidelijk groeien.
We willen proberen onder de 100 te blijven (ook bij veel fotografen) omdat dit anders keuzeproblemen geeft.
</details></p>

</li><li>

### Fijnmazigheid?

<details><summary>Klik om antwoord open of dicht te klappen</summary></p>
Een klein expertisegebied met slechts een handjevol beoefenaars hoeft geen probleem te zijn.
Het is namelijk voor die beoefenaars en geinteresseerden vaak extra waardevol. 
  
Dit is net als bij liefhebbers van bijzondere categorieen muziek of boeken.
Maar het is handig als het minimale overlap geeft met andere categorieën.
Het moet echter ook weer niet zo klein is dat er maar 1 persoon belangstelling in heeft. 

Een te grote expertisegebied ("buitenfotografie") levert minder waarde, en geeft kans op oplap met andere categorieën ("landschap", "street").
</details></p>

</li><li>

### Wie beheert de lijst met expertise tags?

<details><summary>Klik om antwoord open of dicht te klappen</summary></p>
Vooralsnog de maker(s) van de app. Het is echter een dienstverlening, en men moet voortdurend contact houden met gebruikers.
</details></p>

</li><li>

### Project versus specialisme?

<details><summary>Klik om antwoord open of dicht te klappen</summary></p>
Een langlopend project kan lijken op een expertise: iemand kan er bekend om zijn.
Maar er zijn verschillen: Het project is in principe van tijdelijke aard. 
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
Erkende expertisetags kunnen in de app weergegeven worden in het Nederlands en in het Engels.
Als een fotograaf gekoppeld is aan zwart-wit fotografie, wordt dat afhankelijk van omstandigheden dus automatisch in de juiste taal weergegeven ("Zwart-wit", "Black & White").
Als de app een onbekend expertise tag tegenkomt, wordt er niet vertaald. En is er een waarschuwing te zien - mede omdat het en invoerfout kan zijn.
</details></p>

</li><li>

### Eentalige invoer

<details><summary>Klik om antwoord open of dicht te klappen</summary></p>
Bij het toekennen van expertise tags aan fotografen gebruik je meestal de Engelse term.
Maar die identificatie (`idString`) kan in principe afwijken van wat er in het Engels getoond wordt.

Dus strict genomen zijn er 3 benaming voor een expertise tag:
1. een identificatie zoals "Bird", gebruikt on aan te geven welk expertise we bedoelen. Dit zal meestal overeenkomen met (2), maar dat hoeft niet.
2. een Engelse weergavetekst zoals "Birds", zoals het getoond wordt aan Engelstalige gebruikers.
3. een Nederlandse weergavetekst zoals "Vogels", zoals het getoond wordt aan Nederlandstalige gebruikers.

</details></p>

</li><li>

### Expertisetags en clubs

<details><summary>Klik om antwoord open of dicht te klappen</summary></p>
De app koppelt expertisetags aan een persoon - dus los van enig clubverband.</p>
  
Maar de expertise tags worden door clubs ingevoerd.
Dus een fijnproever kan zich afvragen: "als Jan lid is van Club 1 en Club 2, 
en de beide clubs vulen wat andere `Expertise`tags in voor Jan. Hoe reageert de app?".

Goede vraag! De lijsten van expertises van Jan vanuit beide clubs worden intern
samengevoegd. Als de lijsten identiek zijn, merkt de gebruiker daar niets van. Als maar een lijst met tags voor Jan betaat, zie je die tags (bij alle clubs van Jan).
Maar als Club 1 "Portret" en "Abstract" vermeldt, terwijl Club 2 "Abstract" en "Landschap" vermeldt, dan wordt dat door de app gecombineerd tot
"Portret" en "Abstract" en "Landschap".

Als de gecombineerde lijst te lang is, en Jan nog steeds contact heeft met beide groepen,
mag Jan dat verder regelen. Bijvoorbeeld door de bijde lijsten gelijk te trekken of een lijst leeg te maken.
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
Voorbeeld: een bestand bevat "Model" terwijl alleen "Portrait" ondersteund is.
De app toont dan "Model" - maar met een speciaal groen ikoon.
Het ikoon en bijbehorende 'tooltip' geven aan dat dit op dit moment geen officeele `expertise` is.
De app meldt expliciet dat daardoor geen vertalingen beschikbaar zijn: die zijn alleen mogelijk voor erkende expertise tags. 
Dit kan ertoe leiden dat de club de eventuele fout corrigeert of overschakelt naar een verwant erkend expertise tag.
Maar andere uitkomst is dat "Model" op een gegeven moment gepromoveerd wordt tot een officiële `expertise`: het was zo gek nog niet.
Het groene ikoon en de waarschuwing verdwijnen dan automatisch zodra de app ziet dat "Model" inmiddels een officiële tag geworden is.
</details></p>

</li>
