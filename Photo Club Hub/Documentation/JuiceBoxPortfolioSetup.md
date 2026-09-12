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

   Silence means valid. As of Lightroom Classic 15.5.1 this will **not** be silent, so expect to run
   step 3 every time.

3. **Repair the export on the server.**

   ```bash
   sed -i 's|linkURL="<div></div>"|linkURL=""|g; s|<!\[CDATA\[<div></div>\]\]>|<![CDATA[]]>|g' config.xml
   ```

   That is GNU `sed`, as found on the web server. On macOS the same command needs an empty argument
   after `-i` (`sed -i '' 's|…'`), which matters if you fix a downloaded copy instead.

   Then re-run the check in step 2 and confirm it is silent before moving on. Every re-export
   reintroduces the fault, so this is part of exporting, not a one-time fix.

   Do not skip this. Nothing downstream will complain: the authoring tool emits invalid XML
   silently, the server returns it with a 200, and `parseXMLContent()` matches it with a regex that
   never parses XML. The first symptom is a blank white page when someone taps the thumbnail, which
   is easy to miss because the row itself looks correct (see Photo-Club-Hub-Data#54).

4. **Add the member** to `fgDeGender.level2.json`, using the underscore spelling for `level3URL`.

5. **Mirror the edit into both copies.** They are meant to be byte-identical and nothing enforces it:

   - `Photo Club Hub/JSON/fgDeGender.level2.json` — the live copy
   - `Photo-Club-Hub-Data/Sources/Photo Club Hub Data/JSON/fgDeGender.level2.json` — the bundled fallback

   ```bash
   diff "Photo Club Hub/JSON/fgDeGender.level2.json" \
        "Photo-Club-Hub-Data/Sources/Photo Club Hub Data/JSON/fgDeGender.level2.json"
   ```

   A mirror that would make this automatic is specified but not built — Photo-Club-Hub-Data#7.

6. **Push the iOS repo copy.** Both apps fetch from
   `raw.githubusercontent.com/vdhamer/Photo-Club-Hub/main/JSON/` at runtime, so an edit that has not
   been pushed reaches neither of them. Editing only the Data package copy changes nothing at all.

7. **Regenerate the website after pushing, not before.** The HTML app reads the same live URL, so
   regenerating first just rebuilds the old data.

## Every export is currently broken (Lightroom Classic 15.5.1)

Since some point between 2026-05-25 and 2026-09-11, every gallery the plugin exports is invalid XML.
The three per-image text fields come out as `<div></div>` instead of empty:

```xml
<image imageURL="images/x.jpg" thumbURL="thumbs/x.jpg" linkURL="<div></div>" linkTarget="_blank">
<title><![CDATA[<div></div>]]></title>
<caption><![CDATA[<div></div>]]></caption>
```

A raw `<` inside an attribute value is illegal XML, so `juicebox.js` rejects the document and the
gallery renders as a blank white page — not even its own dark background. The Web tab preview inside
Lightroom is blank for the same reason, since it runs the same code against the same file.

### It is Lightroom, not the plugin

Worth recording, because the obvious move is to go hunting for a plugin update. Exporting one
unchanged collection twice — 2026-05-17 and 2026-09-12, same settings, same photo — gave a diff of
exactly those three fields and nothing else. The plugin's own output was byte-identical across the
two runs:

| File | Both exports |
|---|---|
| `jbcore/juicebox.js` | md5 `0ba5d18013bf96ca051bc5900e6d6cbf`, 227891 bytes |
| `index.html` | md5 `dc31684e11f145c5051c07cfef42b03e`, 1018 bytes |

Same plugin version, same template, only the interpolated values changed. So Lightroom now hands the
plugin an empty rich-text fragment where it used to hand an empty string, and the plugin writes it
through unescaped.

This also means a plugin update that merely escapes the value would not help: the file would become
valid XML carrying a bogus link URL rather than an empty one. The value has to be empty.

### Symptom to recognise

The member's row looks completely healthy — correct thumbnail, correct portfolio link — and tapping
it opens a blank page. The thumbnail survives because `parseXMLContent()` extracts it with a regex
that never parses XML, so it succeeds on a document that `juicebox.js` refuses
(vdhamer/Photo-Club-Hub-Data#54).

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
