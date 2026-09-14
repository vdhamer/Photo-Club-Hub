# Adding a JuiceBox portfolio for a club member

A seldom-run procedure, which is why it is written down. It applies to **Fotogroep de Gender** (all
members) and to **Fotogroep Waalre** (former members only) — the two entries in
`clubsFullyUsingJuiceBox` and `clubsPartiallyUsingJuiceBox` in `MemberPortfolio+refreshFirstImage.swift`.
For every other club, `level3URL` is just a web page and none of this applies.

For how the data then flows into `featuredImage`, see [FeaturedImagePipeline.md](FeaturedImagePipeline.md).

## The two naming conventions are opposite

This is the trap. The same person is spelled differently in the two URLs, and both spellings drop
any diacritics:

| Field | Pattern | Example |
|---|---|---|
| `level3URL` (portfolio) | `Given_Family` — **underscores** | `portfolios/Erik_Magnee/` |
| `photographerImage` (portrait) | `Given-Family` — **hyphens** | `uploads/Erik-Magnee.jpg` |

Getting the portfolio one wrong costs both the portfolio *and* the thumbnail, because the thumbnail
is derived from `level3URL` rather than stored in the JSON.

## Steps

1. **Export the gallery** from the JuiceBox Pro Lightroom plugin.

   Copying an existing member's settings carries the ~28 gallery-level settings across correctly, and
   nothing in the per-member configuration is known to cause trouble. The current failure is not
   yours to configure around — see *Every export is currently broken*, below.

2. **Verify the export before going any further.**

   ```bash
   curl -s "https://www.fcDeGender.nl/portfolios/Given_Family/config.xml" | xmllint --noout -
   ```

   Silence means valid, and with the fixed plugin template it should be silent every time. If it is
   not, something has regressed again: run step 3 and say so in the thread linked below.

   Do not skip the check, even once the plugin is fixed. Nothing downstream complains about a
   malformed gallery: the export reports success, the server serves it with a 200, and the app's
   own `parseXMLContent()` matches it with a regex that never parses XML. The first symptom is a
   blank white page when someone taps the thumbnail, long after the fact, and the member's row looks
   perfectly healthy until they do (vdhamer/Photo-Club-Hub-Data#54).

3. **Nothing to repair, with the fixed plugin template installed.** The fatal case is handled at
   source: `clean_url` blanks the sentinel before it reaches the `linkURL` attribute, so exports are
   valid XML again. Step 2 should be silent every time.

   What the vendor fix does *not* cover is an empty **title** or **caption**, which still come
   through as `<div></div>`. That is legal inside CDATA and breaks nothing, but Juicebox treats it as
   a non-empty title and builds a caption frame for it: measured at 23 px of empty strip under every
   photo in such a gallery, where a genuinely empty title produces none at all. Cosmetic, and
   inconsistent between members.

   Two ways to deal with it, if it bothers you. Wrapping `clean_url` around the title and caption in
   the plugin template fixes every gallery at once and leaves real values untouched, which matters
   because titles are genuinely used — `© Bert Zantingh`, and the exhibition galleries. Deselecting
   Title and Caption in the plugin's Image Info section works too, but is per collection and blanks
   real values along with the sentinel.

   `scripts/juicebox/unwrap.py` remains for repairing a gallery already uploaded in the broken state,
   without re-exporting it. It exits non-zero if a file still does not parse after the known repair,
   which is the case where the corruption has changed shape and the file must not be uploaded.

4. **Add the member** to `fgDeGender.level2.json`, using the underscore spelling for `level3URL`.

5. **Mirror the edit into both copies.** They are meant to be byte-identical and nothing enforces it:

   - `Photo Club Hub/JSON/fgDeGender.level2.json` — the live copy
   - `Photo-Club-Hub-Data/Sources/Photo Club Hub Data/JSON/fgDeGender.level2.json` — the bundled fallback

   ```bash
   diff "Photo Club Hub/JSON/fgDeGender.level2.json" \
        "Photo-Club-Hub-Data/Sources/Photo Club Hub Data/JSON/fgDeGender.level2.json"
   ```

   A mirror that would make this automatic is specified but not built — Photo-Club-Hub-Data#7.
   That mirror runs the other way: the intent is to edit the Data package and generate the iOS
   copy. Until it exists, the order below is the one that works, not the one that was designed.

6. **Push the iOS repo copy.** Both apps fetch from
   `raw.githubusercontent.com/vdhamer/Photo-Club-Hub/main/JSON/` at runtime, so an edit that has not
   been pushed reaches neither of them. Editing only the Data package copy changes nothing at all.

   That URL is compiled into every released binary and cannot be redirected, so it keeps serving the
   data even after the Data package becomes the copy you edit. What changes then is which side you
   type into, not which side is fetched.

7. **Regenerate the website after pushing, not before.** The HTML app reads the same live URL, so
   regenerating first just rebuilds the old data.

## The Lightroom bug that made step 3 necessary

A Lightroom Classic release in 2026 began writing an *empty* metadata value as `<div></div>` rather
than as nothing. In the `linkURL` attribute that is a raw `<`, which makes the file invalid XML, so
juicebox.js renders a blank white page. Values with content were never affected.

Juicebox fixed it at source on 2026-09-10: either de-select **Link URL** in the plugin's Image Info
settings, or replace the plugin's own `config.xml` template with the corrected one from
[the vendor's thread](https://juicebox.net/forum/viewtopic.php?id=5551). Install that first, and step
3 stops applying to anything you export from then on.

Full analysis, evidence and the remaining app-side gap: vdhamer/Photo-Club-Hub-Data#54.

## Checking a whole club at once

Every member's gallery, validated in one pass:

```bash
for u in $(grep -o '"level3URL": "[^"]*"' "Photo Club Hub/JSON/fgDeGender.level2.json" | cut -d'"' -f4); do
  err=$(curl -sf --max-time 25 "${u}config.xml" | xmllint --noout - 2>&1 | head -1)
  printf '%-30s %s\n' "${u#*/portfolios/}" "${err:-OK}"
done
```

Every member prints either `OK` or the parser error, so a silent line means the loop did not run
rather than that everything passed.

Worth running after any batch of portfolio work.

It covers member portfolios only, because it walks the `level3URL`s in the Level 2 files. The
exhibition galleries under `/exposities/` are reached from WordPress links and appear in no JSON, so
neither this loop nor the weekly sweep in the Data package ever sees them. If you re-export one, run
the step 2 check on it by hand.
