## Basic questions

<details><summary>Click to expand or collapse category</summary></p>
<ul>

<li>

### What does the app do?

<details><summary>Click to expand or collapse answer</summary></p>
The description in the <font color="red">Apple App Store</font> reads:</p>

> The app shows selected work by members of photo clubs.
>
> The app thus serves as a permanent online exhibition of the members of various photo clubs.
> A user can find a club by browsing, searching by name or via the interactive maps.
> Club members can be found by browsing, searching by name or keyword and via the lists of club members.
>
> Clubs can add themselves by publishing a list of their members online.
> In a separate step the club can offer links to selected photos per member.
> With this data a sister macOS app can automatically generate portfolio pages for existing websites.
> Both apps are on GitHub.
</details></p>

</li><li>

### Why was the app made?

<details><summary>Click to expand or collapse answer</summary></p>

Photographers join a photo club to show their work to each other.
That seeing and being-seen works fine _within_ the club because the members meet regularly.</p>

Visibility of their work _outside_ the club runs via online websites and physical exhibitions.
Visits to this kind of small website have been declining for years:
visitors have to take the initiative themselves to find them, and the content rarely changes.
Users' attention has therefore shifted to large websites
(such as CNN.com or Petapixel.com, with their paid editorial teams)
and social media platforms such as Facebook that serve as meeting places.</p>

That is why we saw a need for an intermediate form especially for photo clubs: something between the relatively unvisited websites
and the (too) hectic and fleeting social media. With the aim of being able to view the photo work of clubs easily and in peace and quiet.
</details></p>

</li><li>

### Why is my club not in the app?

<details><summary>Click to expand or collapse answer</summary></p>
You can add a club yourself. There are step-by-step instructions for this (see the question about documentation).</p>

Various clubs in the Netherlands are already included to kick-start process.
</details></p>

</li><li>

### Is there an Android or PC version of the app?

<details><summary>Click to expand or collapse answer</summary></p>

There is an **iOS** (iPhone/iPad) version of the app on the Apple App Store.
For other phone brands and for larger screens there is a **web version**.

With the [web version](https://www.fcDeGender.nl/en/clubs) you can view club portfolios in an internet browser (_Chrome_, _Edge_, _Safari_...)
on all kinds of devices (Android phones, Chinese phone brands, tablets, laptops, Windows PC, Mac).
Both versions have the same approach and show the same data.

Behind the scenes the web version consists of an app that, at the push of a button, creates the required web pages.
Those pages can be added to existing club websites. These will often be WordPress websites.
Someone viewing the web version does not see the underlying app: the app, as it were, only maintains the web pages.

Improvements to **both** versions are being worked on continuously.
We are open to volunteers who want and are able to make a third version for Android.
But at the moment the web version is a fine solution for Android, Windows and more.
</details>

</li><li>

### Is the app free?

<details><summary>Click to expand or collapse answer</summary></p>

Yes. The app version on the Apple App Store is and remains free.
The software for generating the web version is and remains free too.
The source code of this software is "open source" and falls under the so-called
[MIT license](https://github.com/vdhamer/Photo-Club-Hub/blob/main/.github/LICENSE.md).
</details>

</li><li>

### Is the app finished?

<details><summary>Click to expand or collapse answer</summary></p>

Both versions of the app should already be quite usable in their current versions.
But app versions are released roughly monthly: with these you get extra
functionality, the software stays in step with the changing software world (e.g. Apple iOS 26)
and software bugs are fixed.
</details>

</li></ul>

</details></p>

## Policy

<details><summary>Click to expand or collapse category</summary></p>

<ul><li>

### Is the app only for the Netherlands?

<details><summary>Click to expand or collapse answer</summary></p>

No. The emphasis is currently on growth in the Netherlands, but the app targets worldwide usage.

For this the app supports two languages: Dutch and English.
In English the app is called "Photo Club Hub" instead of "Fotoclub Hub".
The sister app "Photo Club Hub HTML" aka "Fotoclub Hub HTML" also supports both languages.
</details></p>

</li><li>

### Why are photo museums included?

<details><summary>Click to expand or collapse answer</summary></p>
Because it could be useful for some users. And was fairly easy to add.
</details></p>

</li><li>

### Are there any costs involved?

<details><summary>Click to expand or collapse answer</summary></p>
Little or none. The _Photo Club Hub_ and _Photo Club Hub HTML_ software is free and remains free.
And there are no costs for central storage or compute because there is no significant central infrastructure.</p>

If we assume that a club almost always already has a website and has at least one member with Lightroom Classic,
then the only known cost item that remains is an optional one-time purchase of an LR plug-in
([Juicebox Pro](https://www.juicebox.net)).
It can be looked into whether a free alternative
is sufficient (LR comes with a few web plug-ins, Juicebox itself has a 'Lite' version).
Building an alternative to that plug-in yourself is in principle possible but not easy: it therefore depends on
finding a volunteer who is enthusiastic about adding this.
It can also be looked into whether the plug-in costs for this purpose can be bought off centrally on a one-time basis at Juicebox.
</details></p>

</li><li>

### Who decides which photos are in the app?

<details><summary>Click to expand or collapse answer</summary></p>
The clubs.</p>

For example, a club may choose to have photos of all club exhibitions
of the past few years on display.
But you can also agree that each photographer selects photos themselves for his/her portfolio in the app.
Or a combination. The app does assume that the photos have been selected.
This suggests having, say, less than ten new photos (rather than a hundred photos per photographer per year).
Portfolios and exhibiting mean making choices.
</details></p>

</li><li>

### Should I worry about privacy?

<details><summary>Click to expand or collapse answer</summary></p>
No. A club manages its own data.</p>

And that data is stored on the club website and is supplied and maintained by the club.
The data in question here is typically already found on the existing websites:
names of club members, a selection of photos, club officers, etc.
So now that same data has been converted into a machine-readable format,
so that it can be shown in a consistent, uniform way.</p>

Most of the fields are optional.
So a club is not obliged to e.g. link to their website, or indicate who their treasurer is.
Furthermore, the app does not deal with addresses, e-mail addresses or phone numbers of members.
This is by design: the software does not have the information and could not use the data if it did.
Even the location of the club's home base is optional. The location is stored as GPS coordinates,
which you can round off or point to a local landmark if you want.
The same applies at club-member level: a link to a personal website or specifying areas of expertise
is optional. The app of course also does not require that a club member appears on the list.

#### Comparison with websites

In this respect the app corresponds to the setup of existing club websites: the club has control
over what they want to supply/show and should coordinate internally how they organize that. The most important difference
is that new information fields in the app ("_we want to state what brand of camera a member uses_" - hmmmm)
require a software extension because otherwise the software technology used
([link](https://en.wikipedia.org/wiki/JSON)) completely ignores an unknown field.
</details></p>

</li><li>

### Does my club keep control over its own photos?

<details><summary>Click to expand or collapse answer</summary></p>
Yes. No copies are made of the photos. The photos are on the club's website.
Technically they are only "linked to".
And even the lists with links to photos preferably reside on the club's website, and thus _not_ in a central location.
So this is not comparable to sharing photos via Facebook, Instagram, Flickr, X, etc. Social media therefore makes
a copy, and often tries to appropriate rights (^%$#) to photos in exchange for the use of the free service.
This app, by contrast, is explicitly designed so that the club/photographer retains full control:
no copies of photos or data are made, there is no central server,
and the software is free and the source code is public.</p>

Example: the photos and lists of photos of Fotogroep De Gender are on [www.fcDeGender.nl](https://www.fcDeGender.nl).
That is the existing website of that club.
And that website always already had the names of the members, and a selection of photos per member.
You could say that with handier tools you do the same thing as before.
In a way that overcomes some problems with existing websites by using a somewhat more modern approach.

It is even possible, by the way, to place "Jan's photos" with Jan himself if desired.
However, we expect that for practical reasons this will not be used much, and we recommend keeping it simple, especially at the start.
</details></p>

</li><li>

### Can someone copy the displayed photos?

<details><summary>Click to expand or collapse answer</summary></p>
Let's first make clear that the photos are on the club website - and not somewhere central.
So this question applies to any club website on which photos can be seen.

Copying cannot be fully prevented: any online image that is visible can be captured as a screenshot.
But here it is set up to make copying as difficult as possible. In our procedure for this...

- right-clicking and "Save as.." is often blocked in the software. This is determined by the club's website and browsers.
- every photo is visibly provided with the name of the creator in the lower left corner.
- every photo is digitally and invisibly marked (EXIF copyright) with the name of the creator.
</details></p>

</li><li>

### Do former members have to be listed in the app?

<details><summary>Click to expand or collapse answer</summary></p>

No. But the app is made so that it is possible. This is often appreciated
(e.g. if someone was a member for 20 years, and has to cancel his/her membership for health reasons).
"Stay in the app or not" can be decided per member. Or per club.
It is wise to coordinate this with the member themselves.
Technically a **user** of the app can also choose whether former members are displayed.
And each club can decide a policy on this point itself:
if the club does not supply the data, it is of course not visible. More details can be found below.
</details></p>

</li><li>

### Is there an Android or PC version of the app?

<details><summary>Click to expand or collapse answer</summary></p>
For practical reasons the app version supports the iPhone and iPad.
But there are plenty of other target groups. So there is also a so-called "web version".
You view it in your browser (Chrome, Edge, Safari...) and it thus covers both PC/Mac users and all brands of smartphones.
That web version consists of HTML pages that can be added to an existing website (e.g. Wordpress).</p>

The software for the web version is called "Fotoclub Hub HTML" and "Photo Club Hub HTML" in English.
With it a website administrator can automatically create pages from the _same_ data files
that are used for the "Photo Club Hub" app.
[Here](http://www.vdhamer.com/fgDeGender/) is an early test version of such a generated mini-site.
This avoids double work when maintaining both app and website.
Photo Club Hub HTML thus generates a member list with links to the portfolios of the club members.
</details></p>

</li><li>

### Will all this still work in a few years?

<details><summary>Click to expand or collapse answer</summary></p>
With a company (e.g. Adobe) you may assume that everything is supported for at least 10 years.
After all, you pay for it, and it is Adobe's responsibility to ensure continuity
as long as they make a reasonable profit. But there is no hard guarantee.

Here things are different: the source code is public ("open source"), so that in principle it can never be lost.
But the software needs maintenance from time to time. And users often hope for extensions and renewals.
Software maintenance and expansion require quite a lot of specialist knowledge in software and is therefore unfeasible for a photo club.

Since there is no budget, we strive to ensure that there will soon be enough users that more volunteers
come along who are willing to tinker with the software incidentally and without compensation.
For example because they have an idea and can help realize it themselves.
This stands or falls with being able to build up a small group of techies who can and want to do that.
They do not have to be in the same place or even in the same country.
With use by, for example, 100 clubs there is a chance that there happens to be someone (e.g. a student)
among them who could help out. This _can_ start to snowball:
more developers > more functionality > more users > more chance of developers.
Or not - there is no guarantee.
But there is the ambition to solve this in this way.

For a club this continuity question need not be a drama:
the investment per club to supply data is very limited.
Comparable, say, to another improvement action around the club website.
</details></p>

</li></ul>

</details></p>

## Comparisons

<details><summary>Click to expand or collapse category</summary></p>

<ul><li>

### How does this differ from a club website?

<details><summary>Click to expand or collapse answer</summary></p>

A website requires the visitor to take the initiative _themselves_ to look for information.
That works well for specific questions about e.g. opening hours or contact details.
But works poorly for relatively small sites: to stay up to date you have to manually visit multiple
sites - and often it turns out that nothing has changed. The result is few visitors (except around the expo).
Which in turn makes it less attractive to update the site. Which leads to even fewer visitors.</p>

The classic "static" websites are being replaced in terms of attention by larger "dynamic" sites.
In this case you can solve this by
- bundling the news of multiple clubs in one place. Then there is always something that has changed since last time.
- one bookmark instead of a list of bookmarks per club to be maintained.
- making changes clearly visible: showing the newest photos of a photographer first.
- perhaps one day configurable notifications.
</details></p>

</li><li>

### How does this differ from social media such as Facebook or Instagram?

<details><summary>Click to expand or collapse answer</summary></p>
There are ways to automatically detect changes in websites (RSS).
But by and large news has by now become the domain of the large classic media (e.g., CNN.com)
and of social media such as Facebook, Instagram, etc.

First, something is always happening, and it tries (often too persistently) to steer you towards news that you find interesting.

A special platform for photo clubs has, e.g. compared to Instagram, the advantage that it is quieter there.
That is especially important with an art form such as photography: at an exhibition
you would rather have a museum atmosphere than a busy market square where everyone and everything is screaming for attention.

Concretely this means:

- only photography as an art form (so no photos of the business lunch or the cat)
- attention for the photo clubs
- gallery-like display so that the photos come into their own (so no advertising or world news)
</details></p>

</li><li>

### How does this differ from an online photo club such as Glass.photo?

<details><summary>Click to expand or collapse answer</summary></p>
[Glass.photo](https://glass.photo) sees photographers as individuals - but you can see Glass as 1 big photo club.
Compared to Glass, Photo Club Hub has...

- no annual subscription and associated login screen. Glass has a few employees and therefore incurs significant costs.
- no copies of the photos. Photos and member list are with the clubs.
- no option to comment on other people's photos via the app. So no moderation needed either.
- for the time being an emphasis on the Netherlands. Glass is international, although the founders are in Amsterdam.
- no option yet to "follow" individuals or clubs. But that will become necessary with sufficient use.
</details></p>

</li></ul></details></p>

## Usage

<details><summary>Click to expand or collapse category</summary></p>

<ul><li>

### Are there any costs involved?

<details><summary>Click to expand or collapse answer</summary></p>
Little or none. The Photo Club Hub and Photo Club Hub HTML software is free and remains free.
And there are no costs for central storage or computing power: there is no significant central infrastructure.</p>

If we assume that a club almost always already has a website and has at least one member with Lightroom Classic,
then the only known cost item that remains is a one-time purchase of an LR plug-in
([Juicebox Pro](https://www.juicebox.net)). It can be looked into whether a free alternative
suffices (LR comes with a few web plug-ins, Juicebox itself has a 'Lite' version).
Building an alternative to that plug-in yourself is in principle possible but not easy: it therefore depends on
finding a volunteer who is willing to do so.
It can also be looked into whether the plug-in costs for this purpose can be bought off centrally on a one-time basis.
</details></p>

</li><li>

### Is there an Android or PC version of the app?

<details><summary>Click to expand or collapse answer</summary></p>
For practical reasons the app version supports the iPhone and iPad.
But there are plenty of other target groups. So there is also a so-called "web version" of this app.
You view it in your browser (Chrome, Edge, Safari...) and it thus covers both PC/Mac users and all brands of smartphones.
That web version consists of HTML pages that can be added to an existing website (e.g. Wordpress).</p>

The software for the web version is called "Photo Club Hub HTML" (en) or "Fotoclub Hub HTML" (nl).
With it a website administrator can automatically create pages from the _same_ data files
that are used for the "Photo Club Hub" app.
[Here](http://www.vdhamer.com/fgDeGender/) is an early test version of such a generated mini-site.
This avoids double work when maintaining both app and website.
Photo Club Hub HTML thus generates a member list with links to the portfolios of the club members.
</details></p>

</li><li>

### How can I find Photo Club Hub on the Apple App Store?

<details><summary>Click to expand or collapse answer</summary></p>
By searching on "Photo Club Hub" (English) or "Fotoclub Hub" (Dutch).
In both cases you get exactly the same app: there is one latest version that supports both languages.
</details></p></li></ul>
</details></p>

## Data management

<details><summary>Click to expand or collapse category</summary></p>

<ul><li>

### May a text also contain special characters?

<details><summary>Click to expand or collapse answer</summary></p>
Yes. Names of e.g. people may contain special (Unicode) characters. For example "François".
This applies to all fields, including the names of museums ("Museum für Fotografie") and translations
("Le musée est spécialisé dans la conservation de...").
</details></p>

</li><li>

### Can I add a photo museum?

<details><summary>Click to expand or collapse answer</summary></p>
Yes. You do that by extending the Level 1 list.
Please only add museums that are clearly interesting for photography.</p>

Currently only a few well-known photo museums in e.g. Germany, the US and Japan are included
although the list of Dutch photography museums should be relatively complete.
</details></p>

</li><li>

### What if a club has no website?

<details><summary>Click to expand or collapse answer</summary></p>
I don't know exactly. The vast majority of clubs already have a website (= something from which you can retrieve files
via a web address such as "http://www.myclub.nl/..."). Per level:

- Level 1 does not require a website of your own. The information is in a central file.
- Level 2 costs almost no storage. Easy to find a volunteer willing to put a single small file online.
Instructions for this will follow.
- Level 3 is a bit trickier, but storage at a befriended club might be negotiable.
Or finding a [free website provider](https://www.techradar.com/web-hosting/best-free-web-hosting).
I don't think we are going to create instructions for "how do I make a website" (the hosting providers do that).
But we can share example instructions made by a club.
</details></p>

</li><li>

### Can a deceased former member be visible?

<details><summary>Click to expand or collapse answer</summary></p>
If a club does not maintain its data, this will eventually happen with every member.
The internet does not yet have a good solution for this.
For example, on Facebook it can happen that a deceased person receives (with the best intentions) congratulations on his/her birthday.

Removing someone "just like that" can be very painful for surviving relatives who want to keep the memory alive.
But keeping someone "just like that" can sometimes also be painful.
So we recommend the clubs 3 basic rules:

    1. coordinate with the person involved.
    2. if the stakeholders are unreachable, remove the data.
    3. try to keep the app up to date regarding the distinction member / former member / deceased.

For the app this means that the responsibility for the content lies entirely with the clubs.
And if an entire club is unexpectedly dissolved, that club will sooner or later disappear from the app
because they no longer pay the bill for their club website.
</details></p>

</li><li>

### What is all this fuss about Levels?

<details><summary>Click to expand or collapse answer</summary></p>
A club can participate at Level 1, 2 or 3.

- At Level 1 the app only knows that the club exists and where the club is located.
- Level 2 adds a list of club members to this.
- Level 3 adds portfolios with photos to this.

A club can take these steps at its leisure. At Level 2 the app shows the list of members (and not at Level 1).
At level 3 you can browse through portfolios (and not at Level 1 and 2).

The built-in documentation in the app explains this a bit further. The GitHub site contains examples of the input files
and a detailed explanation of what each piece of information means ([GitHub](https://github.com/vdhamer/Photo-Club-Hub)).
</details></p>

</li><li>

### Am I accidentally skipping Level 1?

<details><summary>Click to expand or collapse answer</summary></p>
Maybe.
We have entered the Level 1 data for some local clubs in the Netherlands.
Other clubs can supply their Level 1 data to us themselves.
Fortunately Level 1 data is relatively simple: you just need to supply the club name, municipality, and GPS coordinates.
Plus preferably (not required) a single sentence ("remark") about something worth knowing about the club.
</details></p>

</li><li>

### How do I create a Level 2 file?

<details><summary>Click to expand or collapse answer</summary></p>
There is a separate step-by-step guide with instructions for this: [tinyurl.com/Level2creation](https://tinyurl.com/Level2creation).
There is also a Dutch version of this: [tinyurl.com/Level2aanmaken](https://tinyurl.com/Level2aanmaken).
</details></p>

</li><li>

### How do I get a Level 2 file onto my club website?

<details><summary>Click to expand or collapse answer</summary></p>

For the first clubs we are willing to _temporarily_ put the file on our own server.
The disadvantage of this is that every revision of the file has to go through us.

Those in the know can also put the file on their own site with `ftp` - but `ftp` is not really user-friendly.

The idea is therefore to put the file on your own server via **Wordpress** (or something comparable).
Wordpress is relatively user-friendly and is often used. After the upload, the app can retrieve the file via a web address (URL).
In Wordpress you can e.g. upload photos via `Dashboard` > `Media`. Wordpress shows the web address of the file. We then put that web address into the `level1.json` file for you.

When uploading via Wordpress, 3 complications can be expected:

1. **Logging in**. Login credentials are needed to change anything on a Wordpress site. Someone from the club must already know these.
It is handy to assign minor maintenance of the `Level 2` file to that person: they have the login credentials and know Wordpress a little.

2. **File type**. After all, WordPress expects "media" files of types such as .jpg or .mp4 or .pdf. It does not expect .json files.
This can be solved via a Wordpress plug-in such as [https://wordpress.org/plugins/mime-types-plus/](https://wordpress.org/plugins/mime-types-plus/)

3. **Stable address**. Sooner or later people will want to replace the `Level 2` file with an updated version.
The new version should really end up at the same web address as the previous version. Otherwise existing links/references no longer work.
Wordpress has "permalinks" for that. You will find these on the Wordpress page you use to upload the file.

A separate step-by-step guide with step-by-step instructions for "how do I get my Level 2 file onto the club website" is coming. Who will help to figure this out and write it?

</details></p>

</li><li>

### How can a club determine its own Level 1 description?

<details><summary>Click to expand or collapse answer</summary></p>
It can be done automatically by filling in the `remark` for the club at the top of
a Level 2 file with the desired text.
That Level 2 file is in principle managed by the club (whereas Level 1 is centralized).
This replaces the `remark` at Level 1 in the app with the better `remark` at Level 2.
This should also work for `latitude` and `longitude` (GPS coordinates).

Please notify us of such changes at club level: then we will also correct the Level 1 file.
</details></p></li></ul>
</details></p>

## Future?

<details><summary>Click to expand or collapse category</summary></p>

<ul><li>

### Simpler data entry

<details><summary>Click to expand or collapse answer</summary></p>
The current way to enter a club's data is described in [tinyurl.com/Level2creation](https://tinyurl.com/Level2creation)
(or [tinyurl.com/Level2aanmaken](https://tinyurl.com/Level2aanmaken) in Dutch).
This comes down to

> "the club supplies the data in a data file (for example `fcMaasvlakte.level2.json`) in a strict format

so that software can pluck the correct data from this file.

Creating this file means following some rules, but for many people that is not easy.
It should be possible to do better with additional software that offers "**form-like**" input and creates or adjusts the
expected JSON file.
Something like what websites use for entering orders, say. But
in this case without a central "server" with the associated user/password hassle.
It produces or modifies a file on your own computer.
</details></p>

</li><li>

### Photos of past exhibitions

<details><summary>Click to expand or collapse answer</summary></p>
A start has been made on this in Photo Club Hub HTML ([example](https://www.fcDeGender.nl/fgDeGender/expo2025/)).

This is about showing the photos of club exhibitions _after_ the physical exhibition has ended.
For upcoming exhibitions: see [next point](https://github.com/vdhamer/Photo-Club-Hub/blob/main/Photo%20Club%20Hub/Documentation/FAQ_en.md#announcing-upcoming-exhibitions).
</details></p>

</li><li>

### Announcing upcoming exhibitions

<details><summary>Click to expand or collapse answer</summary></p>
One could think of showing a chronological list of past exhibitions and the upcoming exhibition.
The upcoming exhibition would lead to an image of the exhibition's announcement poster.
The app version could also actively report which exhibitions are coming up nearby in the next two weeks ("widget" on the iOS home screen).
</details></p>

</li></ul></details></p>

## More information

<details><summary>Click to expand or collapse category</summary></p>

<ul><li>

### There must be more documentation?

<details><summary>Click to expand or collapse answer</summary></p>
Certainly:

| Title  | Link | Dutch | English  |
| ----------- | ----------- | :---: | :---: |
| FAQ | [tinyurl.com/fchFAQnl](https://tinyurl.com/fchFAQnl) | ✓ | - |
| FAQ (this document) | [link](https://github.com/vdhamer/Photo-Club-Hub/blob/main/Photo%20Club%20Hub/Documentation/FAQ_en.md) | - | ✓ |
| Creating a level1.json file for a division | [tinyurl.com/Level1aanmaken](https://tinyurl.com/Level1aanmaken) | ✓ | - |
| Creating a level1.json file for a division | [link](https://github.com/vdhamer/Photo-Club-Hub/blob/main/Photo%20Club%20Hub/Documentation/Level1_creation_EN.md) | - | ✓ |
| Creating a level2.json file for a club | [tinyurl.com/Level2aanmaken](https://tinyurl.com/Level2aanmaken) | ✓ | - |
| Creating a new level2.json file for your club | [tinyurl.com/Level2creation](https://tinyurl.com/Level2creation) | - | ✓ |
| FAQ about `expertise` in level2.json files | [link](https://github.com/vdhamer/Photo-Club-Hub/blob/main/Photo%20Club%20Hub/Documentation/Level2_expertise_NL.md) | ✓ | - |
| FAQ about `expertise` in level2.json files | [link](https://github.com/vdhamer/Photo-Club-Hub/blob/main/Photo%20Club%20Hub/Documentation/Level2_expertise_EN.md)  | - | ✓ |
| Readme Photo Club Hub - Dutch | [link](https://github.com/vdhamer/Photo-Club-Hub/blob/main/.github/README_NL.md) | ✓ | - |
| Readme Photo Club Hub - English| [link](https://github.com/vdhamer/Photo-Club-Hub/blob/main/.github/README.md) | - | ✓ |
| Readme Photo Club Hub HTML | [link](https://github.com/vdhamer/Photo-Club-Hub-HTML/blob/main/.github/README.md) | - | ✓ |
| Internal readme in Photo Club Hub app | built into app | ✓ | ✓ |
| FotoclubHubIntro_NL.pptx Powerpoint | [download](https://tinyurl.com/fchPPTnl) | ✓ | coming |
| File management directly in Github | [link](https://github.com/vdhamer/Photo-Club-Hub/blob/main/Photo%20Club%20Hub/Documentation/GitHub_bestandsbeheer_NL.md) | ✓ | coming |
| Featured Image pipeline (rather technical) | [link](https://github.com/vdhamer/Photo-Club-Hub/blob/main/Photo%20Club%20Hub/Documentation/FeaturedImagePipeline.md) | - | ✓ |
</details></p>

</li></ul>

</details></p>
