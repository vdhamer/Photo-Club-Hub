#!/usr/bin/env python3
"""Repair a JuiceBox config.xml that Lightroom Classic exported with empty values wrapped in a <div>.

Some Lightroom Classic release between 2026-05-26 and 2026-09-12 (15.4, 15.4.1, 15.5 or 15.5.1)
changed how an empty metadata value reaches a Web module plug-in: it now arrives as an empty HTML
block rather than an empty string, and the JuiceBox plug-in writes it through unaltered.

    <image imageURL="..." thumbURL="..." linkURL="<div></div>" linkTarget="_blank">
    <title><![CDATA[<div></div>]]></title>
    <caption><![CDATA[<div></div>]]></caption>

Only `linkURL` is fatal: a raw '<' inside an attribute value makes the document ill-formed, so
juicebox.js renders nothing and the gallery is a blank white page. The same token in title or
caption sits inside CDATA, which legally contains '<', and parses. All three are repaired anyway,
since a stray empty element is not what the photographer wrote either.

Verified 2026-09-13: only *empty* values are wrapped. A Title and Caption with content exported
plainly, while the empty linkURL beside them did not. This unwraps a wrapper spanning an entire
value, so a value that legitimately contains markup keeps it.

Textual rather than XML-based on purpose: the input does not parse, which is the whole problem.

Usage:  unwrap.py <config.xml>     edits the file in place

Exits non-zero if the file still does not parse afterwards. The <div> shape is the only one seen so
far, and a silent no-op on some other shape would be indistinguishable from a healthy export.
"""
import re
import sys
import xml.etree.ElementTree as ET


def parse_error(text):
    """Return the parser's complaint, or None when the text is well-formed XML."""
    try:
        ET.fromstring(text)
    except ET.ParseError as error:
        return str(error)
    return None


def unwrap(text):
    """Remove a <div> wrapper that spans the whole value of linkURL, title or caption."""
    wrapper = r'<div>(.*?)</div>'
    keep_inner = lambda match: match.group(1) + match.group(2) + match.group(3)

    text = re.sub(r'(linkURL=")' + wrapper + r'(")', keep_inner, text, flags=re.S)
    for tag in ("title", "caption"):
        text = re.sub(r'(<' + tag + r'><!\[CDATA\[)' + wrapper + r'(\]\]></' + tag + r'>)',
                      keep_inner, text, flags=re.S)
    return text


def main():
    if len(sys.argv) != 2:
        sys.exit("usage: unwrap.py <config.xml>")

    path = sys.argv[1]
    with open(path, encoding="utf-8") as file:
        original = file.read()

    was_broken = parse_error(original)
    repaired = unwrap(original)

    still_broken = parse_error(repaired)
    if still_broken:
        print(f"{path}: STILL INVALID after unwrapping: {still_broken}", file=sys.stderr)
        if repaired == original:
            print("  No <div> wrapper was found, so this is a corruption of a shape this script "
                  "does not know about. Do not upload the file.", file=sys.stderr)
        sys.exit(1)

    if repaired == original:
        print(f"{path}: nothing to unwrap, valid")
        return

    with open(path, "w", encoding="utf-8") as file:
        file.write(repaired)
    print(f"{path}: unwrapped, now valid" + (" (was invalid)" if was_broken else ""))


if __name__ == "__main__":
    main()
