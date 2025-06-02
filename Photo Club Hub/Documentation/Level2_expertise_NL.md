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
Eén of twee. Bij meer dan twee gaat de app bewust een beetje moeilijk doen.</p>

De gedachte is dat een zoekopdracht net als bij Google vooral relevante resultaten oplevert. 
Mischien niet precies de soort "architectuur" waar je in geintereseerd bent. Maar we willen voorkomen dat je bij een portfolio
lang moet bladeren voordat je die enkele verdwaalde architectuurfoto's tegenkomt.
</details></p>

</li><li>

### Hoeveel en welke expertisegebieden zijn beschikbaar?

<details><summary>Klik om antwoord open of dicht te klappen</summary></p>
In de iOS versie van de app staat alle beschikbare expertisegebieden helemaal onderaan de `Namenlijst` pagina (zoek op "expertise" of "zzz").
Deze lijst is dynamisch (online opgehaald): mogelijk dat er volgende week bijvoorbeeld een gebied bijgekomen is.</p>

De HTML versie krijgt hopelijk ooit een extra pagina met diezelfde lijst. 
Verder kan je een technische versie van de lijst [hier](https://github.com/vdhamer/Photo-Club-Hub/blob/main/JSON/root.level0.json) inzien.
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
De gedachte is dat een zoekopdracht net als bij Google vooral relevante resultaten oplevert.
Mischien niet precies de soort "architectuur" waar je in geintereseerd bent.
Maar we willen voorkomen dat je bij een portfolio lang moet bladeren voordat je die enkele verdwaalde architectuurfoto's tegenkomt.</p>

Wij proberen met de beperking te voorkomen dat de fotograaf tracht om al zijn werk in bakjes te vangen.
Veel "specialismes" neigt eigenlijk naar "geen expertisegebieden". En dat is ook een valide antwoord.
Een beginnende fotograaf heeft bijvoorbeeld vaak nog geen echt specialisme - hooguit een soort projekt.

</details></p>

</li><li>

### Hoeveel trefwoorden komen er?

<details><summary>Klik om antwoord open of dicht te klappen</summary></p>
Dat moet blijken. Criteria:

- Wikipedia gebieden t.a.v. onderwerp ("portret") of techniek ("zwart/wit") zijn hoe dan ook prima.
- Het moet vrij duidelijk zijn wat eronder valt.
- Liefst weinig overlap met bestaande gebieden, "Natuur" is b.v. onhandig als er ook "landschappen" en "wilde dieren" categorieen zijn.
- Er moeten meerdere beoefenaars te verwachten zijn. Maar het hoeven niet veel te zijn.
- Die beoefenaars moeten zichzelf als (amateur)fotografen zien. Bij een eventuele bespreking zou het om de fotografie en niet het gefotografeerde moeten gaan.

Naarmate er meer fotografen aan boord komen, zal de lijst geleidelijk doorgroeien. Van de hudige 20 richting b.v. 100.
We moeten proberen onder de 100 te blijven (ook bij veel fotografen) omdat dit problemen gaat geven met met 
vinden en kiezen van trefwoorden (architectuur vs wolkenkrabbers). 
</details></p>

</li><li>

### Fijnmazigheid?

<details><summary>Klik om antwoord open of dicht te klappen</summary></p>
x
</details></p>

</li><li>

### Wie beheert de lijst met trefwoorden?

<details><summary>Klik om antwoord open of dicht te klappen</summary></p>
x
</details></p>

</li><li>

### Project versus specialisme?

<details><summary>Klik om antwoord open of dicht te klappen</summary></p>
x
</details></p>

</li></ul>

</details></p>

## Technische haken en ogen

<details><summary>Klik om categorie open of dicht te klappen</summary></p>
<ul>

<li>

### Vertalingen?

<details><summary>Klik om antwoord open of dicht te klappen</summary></p>
x
</details></p>

</li><li>

### Identifiers?

<details><summary>Klik om antwoord open of dicht te klappen</summary></p>
x
</details></p>

</li><li>

### Trefwoorden per fotograaf of per clublid?

<details><summary>Klik om antwoord open of dicht te klappen</summary></p>
x
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
