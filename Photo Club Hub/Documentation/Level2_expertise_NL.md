## FAQ over `expertise` in level2.json bestanden

In Level 2 kan men per clublid 1 of 2 expertisegebieden opgevenaangeven.
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
Hiermee kan met zien dat b.v. Rob zich toespitsts op "conceptuele fotografie".
Maar het hoofddoel is om Rob te kunnen vinden tussen alle andere fotografen als men in de apps zoekt op "conceptuele fotografie".
</details></p>

</li><li>

### Wat ziet een gebruiker van opgegeven `expertises`?

<details><summary>Klik om antwoord open of dicht te klappen</summary></p>

1. In de HTML/web versie van de app, staan ze (nu) vermeld in een kolom "expertisegebieden" in de tabel met clubleden.
2. In de iOS versie zie je (straks) de beschikbare trefwoorden bij iedere fotograaf in het `Namenlijst` pagina.
3. In de iOS versie staat (nu) alle beschikbare expertisegebieden helemaal onderaan de `Namenlijst` pagina (zoek op "expertise" of "zzz").
</p>

En op termijn komen er ook zoekfuncties bij:

1. In de HTML versie, moeten de getoonde expertises **klikbare links** worden. Dit brengt je naar een lijst met alle fotografen met die expertise. Dit is een alternatief voor het zoeken in de iOS versie.
2. In de iOS versie, kan men straks **zoeken** op expertisegebied door de eerste paar letters in te tikken in de zoekbalk.
Dus intypen van "zwart" reduceert de lijst tot fotografen die aan "zwart-wit" gekoppeld zijn.
Maar toont ook namen zoals "Kees de Zwart": de zoekbalk zoekt gelijktijdig op naam en op expertise.
3. In de HTML versie, zou er een eigenlijk ook een **aparte pagina** moeten komen met een (klikbare) lijst met alle beschikbare expertisegebieden.
Hiermee kan je zien welke er zijn, wat hun uitleg is, en hoeveel fotografen ze vermeld hebben.  
</details></p>

</li><li>

### Wat is de bedoeling eigenlijk?

<details><summary>Klik om antwoord open of dicht te klappen</summary></p>
Stel dat er tien, honderd of zelfs duizend clubs meedoen met ieder zeg 20 leden.
Dan zijn er 200, 2000 of zelfs 20000 fotografen bekend in de app. 
De app bevat nu al zoekfuncties op naam van de fotograaf (en op naam/locaatie van de club).
Hier vind je bekenden mee. Expertisegebieden maakt het mogelijk om voor jou interessante personen te ontdekken.</p>

Analogie met Google Search: soms zoek je om iets terug te vinden waarvan je weet dat het bestaat.
Maar vaker zoek je iets waarvan je niet vooraf weet wat het antwoord zou moeten zijn.  
</details></p>

</li><li>

### Hoeveel expertisegebieden per clublid?

<details><summary>Klik om antwoord open of dicht te klappen</summary></p>
Eén of twee. Bij meer dan twee gaat de app bewust een beetje moeilijk doen.</p>

De gedachte is dat een zoekopdracht net als bij Google herkenbaar vooral relevante resultaten oplevert. 
Mischien niet precies de soort "architectuur" waar je in geintereseerd bent. Maar we willen voorkomen dat je bij een portfolio
lang moet bladeren voordat je die enkele verdwaalde architectuurfoto's tegenkomt.
</details></p>

</li><li>

### Hoeveen en welke expertisegebieden zijn beschikbaar?

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

### Waarom maar 2 trefwoorden per persoon?

<details><summary>Klik om antwoord open of dicht te klappen</summary></p>
x
</details></p>

</li><li>

### Hoeveel trefwoorden komen er?

<details><summary>Klik om antwoord open of dicht te klappen</summary></p>
x
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
