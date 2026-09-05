# Roadmap Contact Sheet

37 candidates, sorted by effort and then by name.
Effort estimates Peter's time: **S** 1 week, **M** 3 weeks, **L** 6 weeks, **XL** 12 weeks.

| Feature | What a user would be told | Repo | Underway | Effort | Value | Tickets |
|---|---|---|---|:--:|:--:|---|
| **A place for club-less photographers** | Photographers who belong to no club can still be shown alongside those who do. | multiple | partly | S |  | #838 |
| **Choose how the tab bar behaves** | Decide for yourself whether the tab bar shrinks away while you scroll. | iOS | no | S |  | #771 |
| **Every Dutch club on the map** | Find your Fotobond club already listed, wherever in the country it is, instead of only in one or two regions. | multiple | no | S |  | #839 |
| **Everything over https** | Pages and data travel over a secure connection, so browsers stop warning people away. | multiple | no | S |  | #145, HTML#250 |
| **Expertises on the People screen** | See at a glance what kind of photography someone is known for. | iOS | no | S |  | #836 |
| **Find the instructions** | Anyone wondering how to add their club can find the instructions from inside the app. | iOS | no | S |  | #563 |
| **Instructions for publishing photos** | Written step-by-step instructions for getting a club's portfolios online. | iOS | no | S |  | #837 |
| **Less typing per member** | One link for the club derives every member's portfolio and thumbnail automatically. | iOS | no | S |  | #435 |
| **Links that always work** | A link to a photographer's own website works however it was typed in. | iOS | no | S |  | #567 |
| **Say where a photo came from** | It is clear which club and which source a portfolio and its images come from. | iOS | no | S |  | #637, #464 |
| **Tidier lists** | Museums out of the club list, former clubs last, and ex-members no longer shown as officers. | iOS | no | S |  | #253, #584, #609 |
| **Vote on what comes next** | Say which of these you want most, and see what everybody else picked. | iOS | no | S |  | #371 |
| **Watch the project grow** | See how many clubs, photographers and photos the app covers, and how that is changing. | multiple | no | S |  | #351, Data#25 |
| **Websites that notice they are stale** | A weekly nudge when a club's data has moved on but its generated site has not. | multiple | no | S |  | Data#24, HTML#257 |
| **A screen for expertises** | Browse the full list of photography types the way the website already allows. | iOS | no | M |  | #561 |
| **An app that does not disappear** | The app stops running out of memory or crashing while you scroll and browse. | iOS | no | M |  | #804, #805, #443, #665, #666 |
| **Clubs keep their own data** | A club keeps its member list on its own website, and the app picks up every change. | Data | partly | M |  | Data#9 |
| **Clubs shown where they actually are** | Pins land in the right place, and a club appears once rather than twice. | multiple | no | M |  | #622, #516 |
| **Departed clubs disappear** | A club removed from the source list also disappears from the app. | Data | no | M |  | Data#39 |
| **Follow the clubs you care about** | Pick a few favourite clubs so the app opens on them instead of on everything. | iOS | no | M |  | #590 |
| **Low barrier for uploading data files** | Submitting new or changed data can be overwhelming due to all the other GitHub features. | new | no | M |  | — |
| **Mistakes caught as you type** | Editing club data warns you about a misspelled expertise or a missing field while you type. | Data | no | M |  | Data#30 |
| **Not only photo clubs** | Point the app at a different collection entirely: cats, trains, bird species. | multiple | partly | M |  | #829, HTML#259 |
| **Photos from past exhibitions** | See the work a club showed at an exhibition, after the exhibition has ended. | HTML | partly | M |  | #834 |
| **Photos that load faster** | Photos and thumbnails stay on the device, so they appear immediately next time. | multiple | no | M |  | #43, #734, #463 |
| **Say when a file is broken** | A club whose data file has an error is reported, instead of quietly appearing empty. | iOS | no | M |  | #795 |
| **Search on more than names** | Search for a club or a kind of photography, not only for a photographer's name. | iOS | no | M |  | #561 |
| **Somewhere near you, by default** | The app opens on your own country or region, with the rest of the world available but not in the way. | multiple | no | M |  | #803, #829 |
| **Website generator on the App Store** | Install the website generator like any other app, instead of building it yourself. | HTML | partly | M |  | HTML#254 |
| **Zoom into a photo** | Pinch to zoom, so you can check a crop or read a sign. | iOS | no | M |  | #243 |
| **A project others can join** | Enough written down — a glossary, a schema, an explained architecture — that a second person can help. | Data | partly | L |  | Data#22, Data#48, Data#49, Data#13 |
| **Claim your club** | Your club is already on the map — add your members and photos without starting from scratch. | multiple | partly | L |  | #832 |
| **Edit club list in a form** | Fill in a (partially filled in) form instead of editing a file format, and the app writes the file for you. | new | no | L |  | — |
| **Exhibitions near you** | Find out what is on nearby in the coming weeks, with a reminder on your home screen. | multiple | no | L |  | #46 |
| **Show me what I care about** | Tell the app which clubs, people and kinds of photography interest you, and it stops showing you the rest. | multiple | no | L |  | #803, #590, #561 |
| **Start from your website** | Point us at your club's website and get a first draft of your club's page back. | new | no | L |  | #835 |
| **Edit club data in a form** | Fill in a (partially filled in) form instead of a file format, and the app writes the file for you. | new | no | XL |  | #833 |

## Notes

- **Every Dutch club on the map** — NEW — precondition for claim-your-club nationally
- **Everything over https** — Not just hygiene: vdhamer.com has no TLS at all, which blocks hosting any form or interactive page there, and blocks #145 and HTML#250. Strato certificate exists but is not serving.
- **Find the instructions** — NEW
- **Links that always work** — NEW
- **Say where a photo came from** — NEW
- **Tidier lists** — theme: relevance
- **A screen for expertises** — theme: relevance
- **An app that does not disappear** — NEW — replaces maps-stability
- **Clubs keep their own data** — Alternative to hosting data files on GitHub
- **Clubs shown where they actually are** — NEW
- **Follow the clubs you care about** — theme: relevance
- **Low barrier for uploading data files** — Probably requires level2-editor
- **Mistakes caught as you type** — Presumably an extension of the level2-editor
- **Search on more than names** — theme: relevance
- **Somewhere near you, by default** — NEW — theme: relevance
- **A project others can join** — NEW
- **Claim your club** — Is claim-your-club software or a marketing campagne?
- **Edit club list in a form** — Effort assumes the level2-editor already exists
- **Show me what I care about** — REWRITTEN — was a performance row, is really about relevance
- **Start from your website** — Stand-alone experiment in a separate repository

## Shape

| Size | Weeks | Count |
|---|--:|--:|
| S | 1 | 14 |
| M | 3 | 16 |
| L | 6 | 6 |
| XL | 12 | 1 |
