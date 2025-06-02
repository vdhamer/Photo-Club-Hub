## FAQ over `expertise` in level2.json bestanden

In Level 2 kan men per clublid 1 of 2 expertisegebieden opgeven.
Het aanmaken en het formaat van Level 2 bestanden is beschreven in
[Level2_aanmaken_NL](https://github.com/vdhamer/Photo-Club-Hub/blob/main/Photo%20Club%20Hub/Documentation/Level2_aanmaken_NL.md).
Deze FAQ gaat over het doel en optimale gebruik van `expertise`.

## Basisvragen

<details><summary>Klik om categorie open of dicht te klappen</summary></p>
<ul>

<li>

### Wat betekent `expertise` hier?

<details><summary>Klik om antwoord open of dicht te klappen</summary></p>
Het gaat hier om 1 of 2 gebieden waar een fotograaf om bekend staat.
Hiermee kan met zien dat b.v. Rob zich toespitsts op abstracte fotografie. Maar hopelijk valt dat ook te zien aan de foto's van Rob.
Het hoofddoel is om Rob te kunnen vinden tussen alle andere fotografen als men in de app zoekt op "abstract" of "abs".
</details></p>

</li><li>

### Waar ziet een gebruiker de gemelde `expertises`?

<details><summary>Klik om antwoord open of dicht te klappen</summary></p>

1. In de HTML/web versie van de app, staan ze vermeld in een kolom "expertisegebieden" in de tabel met clubleden.
2. In de iOS versie zie je (straks) de beschikbare trefwoorden bij iedere fotograaf op het `Namenlijst` pagina.
3. In de iOS versie staan de beschikbare expertisegebieden helemaal onderaan de `Namenlijst` pagina (zoek op "expertise" of "zzz", want het is een eind scrollen).
</p>

En op termijn komen er ook zoekfuncties bij:

1. In de HTML versie, moeten de getoonde expertises **klikbare links** worden. Dit brengt je naar een lijst met alle fotografen met die expertise.
2. In de iOS versie, kan men straks **zoeken** op expertisegebied door de eerste paar letters in te tikken in de zoekbalk.
Dus intypen van "zwart" reduceert de lijst tot fotografen die aan "zwart-wit" gekoppeld zijn.
Maar toont ook namen zoals "Kees de Zwart": deze zoekbalk zoekt zowel op naam en op expertise.
3. In de HTML versie, zou er een eigenlijk ook een **aparte pagina** moeten komen met een (klikbare) lijst met alle beschikbare expertisegebieden.
Hiermee kan je zien welke er zijn, wat hun uitleg is, en hoeveel fotografen ze vermeld hebben.  
</details></p>

</li><li>

### Wat is de bedoeling eigenlijk?

<details><summary>Klik om antwoord open of dicht te klappen</summary></p>
Stel dat er tien, honderd of zelfs duizend clubs meedoen met ieder 20 leden.
Dan zijn er 200, 2000 of zelfs 20.000 fotografen bekend in de app. 
De app bevat zoekfuncties waarmee je op naam van de fotograaf kunt zoeken.
Hier vind je bekenden mee. Expertisegebieden laat je interessante fotografen ontdekken die je nog niet kende.
</details></p>

</li><li>

### Hoeveel expertisegebieden per clublid?

<details><summary>Klik om antwoord open of dicht te klappen</summary></p>
Nul, één of twee. Bij meer dan twee gaat de app bewust een beetje moeilijk doen.</p>

De gedachte is dat een zoekopdracht net als bij Google Search vooral relevante resultaten oplevert. 
Mischien niet precies de soort "architectuur" waar die je zocht. Maar we willen voorkomen dat je bij een portfolio
langdurig moet bladeren voordat je foto's tegenkomt die je als architectuurfoto's zou kunnen bestempelen.
</details></p>

</li><li>

### Hoeveel en welke expertisegebieden zijn beschikbaar?

<details><summary>Klik om antwoord open of dicht te klappen</summary></p>
In de iOS versie van de app staat alle beschikbare expertisegebieden helemaal onderaan de `Namenlijst` pagina (zoek op "expertise" of "zzz").
Deze lijst is dynamisch (online opgehaald): het kan dat er volgende week een nieuw gebied bijgekomen is. Momenteel zijn het er ruim 20.</p>

De HTML versie krijgt wellicht een extra pagina met diezelfde lijst. 
Verder kan je de actuele lijst (in JSON formaat) [hier](https://github.com/vdhamer/Photo-Club-Hub/blob/main/JSON/root.level0.json) inzien.
</details></p>

</li></ul>

</details></p>

## Richtlijnen

<details><summary>Klik om categorie open of dicht te klappen</summary></p>
<ul>

<li>

### Mag mijn expertise veranderen op de tijd?

<details><summary>Klik om antwoord open of dicht te klappen</summary></p>
Zeker. De gekozen gebieden zijn bedoeld als huidige expertise.
"Ik deel vroeger veel aan macro" zou betekenen dat Macro van de lijst kan.

</details></p>

</li><li>

### Waarom max 2 expertisegebieden per persoon?

<details><summary>Klik om antwoord open of dicht te klappen</summary></p>
De gedachte is dat een zoekopdracht net als bij Google Search vooral relevante resultaten oplevert.
Mischien niet precies de soort "architectuur" waar je in geintereseerd bent.
Maar we willen voorkomen dat je bij een portfolio lang moet bladeren voordat je die enkele verdwaalde architectuurfoto's tegenkomt.</p>

Het is dus _niet_ de bedoeling dat de fotograaf tracht om al zijn werk in trefwoorden te vangen.
Veel "specialismes" neigt eigenlijk naar "geen expertisegebieden". En dat is ook een valide antwoord.
Sommige fotografen hebben nu eenmaal geen of nog geen herkenbaar specialisme.

</details></p>

</li><li>

### Hoeveel trefwoorden komen er?

<details><summary>Klik om antwoord open of dicht te klappen</summary></p>
Dat moet blijken. Criteria:</p>

- Wikipedia gebieden t.a.v. fotografieonderwerp ("portret") of techniek ("zwart/wit") zijn hoe dan ook prima.
- Het moet vrij duidelijk zijn wat eronder valt.
- Liefst weinig overlap met bestaande gebieden. "Natuur" is b.v. onhandig als er ook "landschappen" en "wilde dieren" categorieën zijn.
- Er moeten meerdere beoefenaars te verwachten zijn. Maar het hoeven niet veel te zijn.
- Die beoefenaars moeten zichzelf als (amateur)fotografen zien. Bij een eventuele bespreking zou het om de fotografie en niet het gefotografeerde moeten gaan.

Naarmate er meer fotografen aan boord komen, zal de lijst geleidelijk groeien.
We willen proberen onder de 100 te blijven (ook bij veel fotografen) omdat dit anders problemen geeft met 
kiezen en gebruik van "vakjes" (architectuur vs kathedralen). 
</details></p>

</li><li>

### Fijnmazigheid?

<details><summary>Klik om antwoord open of dicht te klappen</summary></p>
Een klein expertisegebied met slechts een handjevol beoefenaars hoeft geen probleem te zijn.
Het is namelijk voor die beoefenaars en geinteresseerden juist extra waardevol. 
  
Dit is net als bij liefhebbers van bijzondere categorieen muziek of boeken.
Maar het is handig als het minimale overlap geeft met andere categorieën.
Het moet echter ook weer niet zo klein is dat er maar 1 persoon belangstelling in heeft. 

Een te grote expertisegebied ("buitenfotografie") levert minder waarde, en geeft kans op oplap met andere categorieën ("landschap", "street").
</details></p>

</li><li>

### Wie beheert de lijst met trefwoorden?

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

## Technische kanten

<details><summary>Klik om categorie open of dicht te klappen</summary></p>
<ul>

<li>

### Meertalige weergave

<details><summary>Klik om antwoord open of dicht te klappen</summary></p>
Erkende expertisegebieden worden in de app weergegeven in het Nederlands of in het Engels.
Als een fotograaf gekoppeld is aan zwart-wit fotografie, wordt dat afhankelijk van omstandigheden als "Zwart-wit" of als "Black & White" weergegeven.
Als de app een onbekend expertisegebied tegenkomt, wordt er niet vertaald. En is er een waarschuwing te zien - mede omdat het en invoerfout kan zijn.
</details></p>

</li><li>

### Een-talige invoer

<details><summary>Klik om antwoord open of dicht te klappen</summary></p>
Bij het koppelen van expertisegebieden aan fotografen gebruik je meestal de Engelse term.
Maar die identificatie (`idString`) kan in principe afwijken van wat er in het Engels getoond wordt.
Dus strict genomen zijn er 3 benaming voor een expertisegebied:</p>

1. een identificatie zoals "Bird", gebruikt on aan te geven welk expertisegebied we bedoelen. Dit zal bijna altijd overeenkomen met (2), maar het hoeft niet:
2. een Engelse weergavetekst zoals "Birds", zoals het getoond wordt aan Engelstalige gebruikers.
3. een Nederlandse weergavetekst zoals "Vogels", zoals het getoond wordt aan Nederlandstalige gebruikers.

</details></p>

</li><li>

### Expertisegebieden en clubs?

<details><summary>Klik om antwoord open of dicht te klappen</summary></p>
Strikt genomen vindt de app dat de expertisegebieden aan een persoon hangen.
En dus niet afhankelijk zijn van de club waar de persoon lid is of was.</p>
  
Maar de expertisegebieden worden door clubs ingevoerd.
Dus een fijnproever kan zich afvragen: "als Jan lid is van Club 1 en Club 2, 
en de beide clubs iets anders invullen voor `Expertise` van Jan, wat doet de app?".

Goede vraag overigens! De lijsten van expertises van Jan vanuit beide clubs worden intern
samengevoegd. Als de lijsten identiek zijn, zie je daar niets van. Als maar een lijst gevuld is,
zie je dat. Als Club 1 meldt "Portret" + "Abstract", termijn Club 2 zegt "Abstract" + "Landschap",
dan gebruikt de app "Portret" + "Abstract" + "Landschap" aan de slag.

Als de gecombineerde lijst te lang is, en Jan nog steeds contact heeft met beide groepen,
mag Jan dat verder regelen. Bijvoorbeeld door de `expertises` bij 1 club weg te halen.
</details></p>

</li><li>

### Teveel trefwoorden?

<details><summary>Klik om antwoord open of dicht te klappen</summary></p>
x
</details></p>

</li><li>

### Meerdere soorten trefwoorden?

<details><summary>Klik om antwoord open of dicht te klappen</summary></p>
x
</details></p>

</li>
