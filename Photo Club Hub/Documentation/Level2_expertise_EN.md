## FAQ regarding `Expertise` in level2.json files

A Level 2 file can specify up to two `expertise` tags per photographer.
Detailed instructions for creating Level 2 files can be found in
[Level2_aanmaken_EN](https://github.com/vdhamer/Photo-Club-Hub/blob/main/Photo%20Club%20Hub/Documentation/Level2_aanmaken_EN.md).
This FAQ covers the use and management the app's `expertise` tags.

## Basics

<details><summary>Click to expand or collapse a category</summary></p>
<ul>

<li>

### What is an `Expertise` tag?

<details><summary>Click to expand or collapse an answer</summary></p>
An expertise is a photography domain for which the photographer is known. 
An `expertise` tag in the app can tell you that Bob is specialized in "Abstract" photography.
This enables you to find Rob and others by typing "abstract" or "abst" into the Search bar on the
`Portfolio` screen.
</details></p>

</li><li>

### Where do app users see `expertises`?

<details><summary>Click to expand or collapse an answer</summary></p>

1. In the HTML/web version of the app, `expertises` are shown in the `Areas of expertise` column in the tables of club members.
2. In the iOS version of the app, `expertises` are shown per photographer on the `Portfolio` page. 
2. In the iOS version, the list of `expertises` and their statistics are shown at the bottom of the `Who's Who` screen. To avoid a lot of scrolling you can search for "expertises" or any other text that has no matches like "zzz".
4. In the iOS version, you can **search** for `expertise` tags by typing in the first few letters of the expertise in the Search bar.
   So typing "black" shortens the list to only show photographers that have the "Black & White" tag.
   But you may also find a stray photographer with a name like "Blackstone" unless you type "black ".</p>

In a future release, you can expect similar search functions for the HTML/web version:

1. Clicking on an expertise tag brings you to a list of all photographers labelled with that tag.
2. A separate Expertise tags page will show all supported tags with their statistics and with links to pages per Expertise.
</details></p>

</li><li>

### Why have Expertises?

<details><summary>Click to expand or collapse an answer</summary></p>
Assume the app contains ten, a hundred or even a thousand clubs, with on average 15 members each.
That gives us maybe 150, 1500 or even 15,000 photographers in the app.
The app contains a Search capability allowing you to find known photographers - if you know their name.
Expertise tags allows you discover relevant photographers you didn't know about yet.
</details></p>

</li><li>

### Number of expertise tags per photographer?

<details><summary>Click to expand or collapse an answer</summary></p>
The app allows up to two tags per photographer.</p>

If there are more than two expertise tags, the app deliberately starts softly complaining.
The point of limiting the number of tags is that a search on an expertise tag should
return pretty relevant results. Meaning that the member's portfolio hopefully contains images
that confirm that the member is active and experienced in that area.
</details></p>

</li><li>

### Can somebody have zero `Expertise` tags?

<details><summary>Click to expand or collapse an answer</summary></p>
Sure. That can have various causes:

1. Maybe the photographer doesn't have a clear specialization
   ("I shoot whatever I happen to encounter and don't have a particularly recognizable style").
2. The person is, for whatever reason, not inclined to share that information.
3. The club hasn't gotten around to collecting this information yet.

</details></p>

</li><li>

### How many tags can I choose from?

<details><summary>Click to expand or collapse an answer</summary></p>
At the moment there are roughly 25 tags available.

In the iOS version of the app, all available (and some candidate) tags are listed at the bottom of the `Who's Who` screen.
You can reach the bottom quickly by using the Search bar to filter out all the photographers.</p>

De HTML/web version of the app will get a comparable list, but it will be accessed a bit differently. 

The list is stored online and will change over time: there may be a new tag tomorrow that is not on the list today.
The online master list (in JSON formaat) with all approved tags can be found
[here](https://github.com/vdhamer/Photo-Club-Hub/blob/main/JSON/root.level0.json).
</details></p>

</li></ul>

</details></p>

## Guidelines

<details><summary>Click to expand or collapse a category</summary></p>
<ul>

<li>

### Can someone's `expertise` tags change over time?

<details><summary>Click to expand or collapse an answer</summary></p>
Certainly. The selected tags reflect somebody's current areas of expertise.
People learn or can shift focus.

</details></p>

</li><li>

### Why allow only two extertise tags per photographer?

<details><summary>Click to expand or collapse an answer</summary></p>
The idea is that searching on Expertise tags will give you largely relevant results.
A search on "Street" may give you multiple styles of street photography, but all-in-all the resulting
photographers should have a recognizable expertise in street photography.

If we would allow 5 or even 10 tags, the results would include people who occasionaly do architecture photography
- which makes the searching on expertise tags much less useful for finding specialists. Expressed differently, 
the expertise tags per person serve a very different purpose than Lightroom keywords per image:
you may succesfully use hundreds or thousands of LR keywords to find specific photos ("birthday", "beach", "Iceland"). 
Our expertise tags are meant to find photographers ("who are known for their street photography").</p>
</details></p>

</li><li>

### How many different expertise tags will there be in the long run?

<details><summary>Click to expand or collapse an answer</summary></p>
Hopefully below 100. Criteria:</p>

- Any photography domain recognized by Wikipedia ("portrait photography") is credible candidate.
- It should be relatively clear what the tag means. So "outdoors" is not ok, while "landscape is ok."
- A tag shouldn't have a lot of overlap with existing tags. So no simultaneous "old buildings" next to "architecture".
- A tag with only one expected user is too specialized. Partly because of the "max 100 tags" target.
- The practioners in the domain should see themselves as photographers, rather than enthousiasts like
  train spotters or butterfly enthousiasts who happen to use photo's to communicate. Our open source software could
  conceivably be suitable for other uses, but we want to avoid mixing "our" data with "their" data.

</details></p>

</li><li>

### Granularity?

<details><summary>Click to expand or collapse an answer</summary></p>
A small area of expertise with only a few partitioners is not necessarily a problem:
a small domain ("underwater photography") may have a relatively high value to those who need it. 
  
A large area of expertise ("people") will lose value if it is too diverse ("street", "portait", "model", "family", and "sports" would all
fall under "people").

So curating the list of keywords is a tradeoff between:
- clarity and recognizability of the term,
- keeping the list short enough that tags are not overlooked, and
- minimizing overlaping categories.
</details></p>

</li><li>

### Who manages the list of approved tags?

<details><summary>Click to expand or collapse an answer</summary></p>
For now the maker(s) of the app.
But this task (technically maintaining the
[root.level0.json](https://github.com/vdhamer/Photo-Club-Hub/blob/main/JSON/root.level0.json) file) could be done by others.
</details></p>

</li><li>

### Project versus specialisme?

<details><summary>Click to expand or collapse an answer</summary></p>
Een langlopend project kan lijken op een expertise: iemand kan er bekend om zijn.
Maar er zijn verschillen: Het project is in principe van tijdelijke aard. 
En een expertise is vaak algemener en kan dus van pas komen bij meerdere projekten.
</details></p>

</li></ul>

</details></p>

## Technische bijkomstigheden

<details><summary>Click to expand or collapse a category</summary></p>
<ul>

<li>

### Meertalige weergave

<details><summary>Click to expand or collapse an answer</summary></p>
Erkende expertisetags kunnen in de app weergegeven worden in het Nederlands en in het Engels.
Als een fotograaf gekoppeld is aan zwart-wit fotografie, wordt dat afhankelijk van omstandigheden dus automatisch in de juiste taal weergegeven ("Zwart-wit", "Black & White").
Als de app een onbekend expertisegebied tegenkomt, wordt er niet vertaald. En is er een waarschuwing te zien - mede omdat het en invoerfout kan zijn.
</details></p>

</li><li>

### Eentalige invoer

<details><summary>Click to expand or collapse an answer</summary></p>
Bij het koppelen van expertisegebieden aan fotografen gebruik je meestal de Engelse term.
Maar die identificatie (`idString`) kan in principe afwijken van wat er in het Engels getoond wordt.

Dus strict genomen zijn er 3 benaming voor een expertisegebied:
1. een identificatie zoals "Bird", gebruikt on aan te geven welk expertise we bedoelen. Dit zal meestal overeenkomen met (2), maar dat hoeft niet.
2. een Engelse weergavetekst zoals "Birds", zoals het getoond wordt aan Engelstalige gebruikers.
3. een Nederlandse weergavetekst zoals "Vogels", zoals het getoond wordt aan Nederlandstalige gebruikers.

</details></p>

</li><li>

### Expertisetags en clubs

<details><summary>Click to expand or collapse an answer</summary></p>
De app koppelt expertisetags aan een persoon - dus los van enig clubverband.</p>
  
Maar de expertisegebieden worden door clubs ingevoerd.
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

### Teveel expertisegebieden?

<details><summary>Click to expand or collapse an answer</summary></p>
Bij 3 of meer expertisegebieden, meldt de app "Teveel Expertises" op de plek van het 3e element.
Dit moet de club aanmoedigen om het te corrigeren.
</details></p>

</li><li>

### Fouten bij invoeren `expertises`?

<details><summary>Click to expand or collapse an answer</summary></p>

Wat gebeurt als een Level 2 bestand een onbekende `expertise` tag bevat die niet bekend is in de app?
Voorbeeld: een bestand bevat "Model" terwijl alleen "Portrait" ondersteund is.
De app toont dan "Model" - maar met een speciaal groen ikoon.
Het ikoon en bijbehorende 'tooltip' geven aan dat dit op dit moment geen officeele `expertise` is.
De app meldt expliciet dat daardoor geen vertalingen beschikbaar zijn: die zijn alleen mogelijk voor erkende expertise tags. 
Dit kan ertoe leiden dat de club de eventuele fout corrigeert of overschakelt naar een verwant erkend expertisegebied.
Maar andere uitkomst is dat "Model" op een gegeven moment gepromoveerd wordt tot een officiële `expertise`: het was zo gek nog niet.
Het groene ikoon en de waarschuwing verdwijnen dan automatisch zodra de app ziet dat "Model" inmiddels een officiële tag geworden is.
</details></p>

</li>
