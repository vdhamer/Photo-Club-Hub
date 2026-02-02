## FAQ regarding `Expertise` in level2.json files

A Level 2 file can specify up to two `expertise` tags per photographer.
Detailed instructions for creating Level 2 files can be found in
[Level2_aanmaken_EN](https://github.com/vdhamer/Photo-Club-Hub/blob/main/Photo%20Club%20Hub/Documentation/Level2_aanmaken_EN.md).
This FAQ covers the use and management of the app's `expertise` tags.

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

1. In the HTML/web version of the app, `expertises` are shown in the `Expertise tags` column in the tables of club members.
2. In the iOS version of the app, `expertises` are shown per photographer on the `Portfolio` page. 
2. In the iOS version, the list of `expertises` and their statistics are shown at the bottom of the `Photographers` screen. To avoid a lot of scrolling you can search for "expertises" or any other text that has no matches like "zzz".
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
Assume the app contains ten, a hundred, or even a thousand clubs, with on average 15 members each.
That gives us maybe 150, 1500, or even 15,000 photographers in the app.
The app contains a Search capability allowing you to find known photographers — if you know their name.
Expertise tags allow you to discover relevant photographers you didn't know about yet.
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

### How many tags can we choose from?

<details><summary>Click to expand or collapse an answer</summary></p>
At the moment, there are roughly 25 tags available.

In the iOS version of the app, all available (and some candidate) tags are listed at the bottom of the `Photographers` screen.
You can reach the bottom quickly by using the Search bar to filter out all the photographers.</p>

The HTML/web version of the app will get a comparable list, but it will be accessed a bit differently. 

The list is stored online and will change over time: there may be a new tag tomorrow that is not on the list today.
The online master list (in JSON format) with all supported tags can be found
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
Yes. The selected tags reflect somebody's current areas of expertise.
People learn or can shift their focus.

</details></p>

</li><li>

### Why allow only two extertise tags per photographer?

<details><summary>Click to expand or collapse an answer</summary></p>
The purpose of having Expertise tags is that searching on tags will give you a largely relevant list of photographers.
A search on "Street" may give you multiple styles of street photography, but all in all the resulting
photographers should have a recognizable expertise in street photography. And it will probably show up
in their portfolio.

If we would allow 5 or even 10 tags, the results would include people who occasionally do street photography - which
makes the searching on expertise tags much less useful for finding good street photography images and their makers.

Expressed differently, the expertise tags per person serve a very different purpose than Lightroom keywords per image:
you may successfully use hundreds or thousands of LR keywords to find specific photos ("birthday", "beach", "Iceland"). 
Our expertise tags are meant to find photographers who are known for a particular expertise.</p>
</details></p>

</li><li>

### How many different expertise tags will there eventually be?

<details><summary>Click to expand or collapse an answer</summary></p>
For now, we target keeping the list size below 100. Criteria:</p>

- It should be relatively clear what the tag means. So "outdoors" is less suitable than "landscape."
- Any photography domain recognized by Wikipedia ("portrait photography") is a reasonable candidate for a tag.
- A tag shouldn't have a lot of overlap with existing tags. So no simultaneous "old buildings" next to "architecture".
- A tag with only one expected user is too specialized. Partly because of the "max 100 tags" target.
- The practitioners in the domain should see themselves as photographers, rather than enthusiasts like
  train spotters or butterfly experts who happen to use photos to communicate. Our open source software could
  be suitable for such other uses, but we don't want to mix photography content with other content.

</details></p>

</li><li>

### Granularity?

<details><summary>Click to expand or collapse an answer</summary></p>
A very specialized Expertise tag with only a few practitioners is not necessarily a bad idea.
A tag that would only get used for one photographer is overdoing things (if you know the domain, you may already
know the photographer), a specialized domain like "underwater photography" tends to be relatively valuable
because it is hard to find such practitioners. 
  
A large area of expertise will lose value if it is too broad. A tag like "people" may be applied to
"street", "portrait", "model", "family", and "sports".

Therefore, curating the list of keywords is a tradeoff between:
- clarity and recognizability of the tag,
- keeping the list tags short enough that relevant tags are not overlooked, and
- minimizing tag overlap.
</details></p>

</li><li>

### Who manages the list of supported tags?

<details><summary>Click to expand or collapse an answer</summary></p>
For now, this would be the maker(s) of the app. But this task of technically maintaining the
[root.level0.json](https://github.com/vdhamer/Photo-Club-Hub/blob/main/JSON/root.level0.json) file could be delegated
to a suitable volunteer.
</details></p>

</li><li>

### Project versus expertise?

<details><summary>Click to expand or collapse an answer</summary></p>
A long-running photography project can start to sound like an expertise or specialism:
somebody invests a lot of effort into some theme and may become well known for that.
But there are differences: a project is by definition temporary; and an expertise can
often be applied in multiple projects.
</details></p>

</li></ul>

</details></p>

## Technical description

<details><summary>Click to expand or collapse a category</summary></p>
<ul>

<li>

### Displaying in multiple languages

<details><summary>Click to expand or collapse an answer</summary></p>
Supported expertise tags can be shown in the user interface in at least two languages: English and Dutch.
This means that if a photographer is known for multiple-exposure photography, the app will display either
"Multiple exposure" for English or "Meervoudige opnamen" for Dutch - depending on your language preference.
These translations for supported tags are stored in the
[root.level0.json](https://github.com/vdhamer/Photo-Club-Hub/blob/main/JSON/root.level0.json) file.
If the app runs across a temporary tag (because of a user error, or as a proposal),
that tag is shown untranslated because it doesn't occur in the root.level0.json file right now.
</details></p>

</li><li>

### Tag entry in a single language

<details><summary>Click to expand or collapse an answer</summary></p>
When defining the tags per photographer in the Level2.json file, you should be using an English term and,
if it is supported, using the so-called `idString` identifier as defined in the
[root.level0.json](https://github.com/vdhamer/Photo-Club-Hub/blob/main/JSON/root.level0.json) file.
It might also be convenient to simply copy that `idString` identifier from an existing Level 2 file:
if it works there, it will work for you as well.

So strictly speaking (see root.level0.json) an expertise has 3 distinct names:
1. The internal `idString` such as `Multiple-exposure` as used to identify the tag.
   This will often correspond to the English name but it doesn't have to.
2. An Engelse (EN) representation such as `Multiple exposure` as shown to English-speaking users.
3. A Dutch (NL) representation such as `Meervoudige opnamen` as shown to Dutch-speaking users.
If your device is set to another language, the software will then use the English version.
But the app allows you to provide more than two translations if you want (e.g. German = DE or Hindi = HI).

So to summarize: 
- Level 2 files use the `idString` identifier, which usually matches the **English** version (e.g. "Travel").
- Translation is done automatically by the app.
  The way the `idString` version is translated is configured centrally, so few people will see this. 

</details></p>

</li><li>

### Role of clubs in expertise tags

<details><summary>Click to expand or collapse an answer</summary></p>
The app associates tags with **photographers** rather than with photographers in their capacity as member of any single club.
That is a bit tricky. It means that if John is a member of ClubA and of ClubB, the app will show the same
tags when you scroll to John as a member of ClubA or scroll to John as a member of ClubB.
This is similar to saying "John's birthday is Feb 29".
John's birthday doesn't depend on any photo club he is or was a member of.</p>
  
The tricky part is that ClubA and ClubB can both specify expertise tags for John, and undoubtedly won't coordinate
to get the same set of tags in their respective Level 2 files.

So what does the app do if it finds photographers who have or had associations with more than one club?
The answer is simple: multiple lists of tags are assumed to all be true, and are merged into one list that is applied
to the two (or more) clubs. Example outcome:
- If the lists are identical, nobody will notice anything: you see identical lists for both clubs.
- If only one club provided expertise tags, these are shown for both clubs.
- If ClubA specified "Portrait" and ClubB specified and "Landscape", this is shown as "Portrait" + "Landscape".
- If ClubA specified "Portrait" + "Abstract" and ClubB specified "Abstract" + "Landscape" these will be combined to 
  "Abstract" + "Portrait" + "Landscape". And the app will show that there are more than 2 tags and the member can help by
  choosing what the desired outcome is asking at least one club to adapt their tags.
</details></p>

</li><li>

### To many expertise tags

<details><summary>Click to expand or collapse an answer</summary></p>
For 3 or more expertise tags, the app will display a warning like "Too many expertises" instead of the 3rd tag.
This is meant to trigger the club to fix this.
</details></p>

</li><li>

### Errors in the provided `expertise` tags

<details><summary>Click to expand or collapse an answer</summary></p>
What happens if a Level 2 file contains a tag that hasn't been supported or just contains a typo?
Example: the file has a tag called "Model" while there is only a tag for "Portrait".
The app will then display a warning icon next to the unofficial tag "Model" to indicate that it doesn't really
know that tag. And that, consequently, there will be no translations available.

This *may* prompt the club to fix a typo, or replace the temporary tag with a similar supported tag.
Alternatively, it may prompt the app's maintainers to promote the temporary tag to a supported one if it meets
the necessary criteria. Once a temporary tag is promoted onto the supported 
[root.level0.json](https://github.com/vdhamer/Photo-Club-Hub/blob/main/JSON/root.level0.json) tag list,
or alternatively the Level 2 file has been fixed, the warning icon will disappear.
</details></p>

</li>
