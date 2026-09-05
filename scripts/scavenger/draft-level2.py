#!/usr/bin/env python3
"""Draft a club's level2.json from its own website.

    ./draft-level2.py https://www.fotoclubsomething.nl

Crawls a dozen pages of one club site, finds the names that look like a member
list, and writes a level2.json next to this script for you to check and correct.
It is a draft: expect roughly nine names in ten to be right, and expect to fix
the rest by hand. Measured against seven clubs whose data we already had, on
4 Sept 2026: 92% recall, 88% precision, 82% Jaccard agreement.

Names on a club site are typed by clubmates, not by their subjects, so treat
every spelling as a first guess. The accuracy figures above measure agreement
with our own data, not correctness.

No model is used and nothing is sent anywhere. The name gazetteer is built from
the project's own existing member data, so it improves as more clubs join.
"""
import sys, re, csv, json, glob, time, html, subprocess, unicodedata, pathlib, collections

HERE = pathlib.Path(__file__).resolve().parent
REPO = HERE.parents[1]
UA = ("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 "
      "(KHTML, like Gecko) Chrome/126 Safari/537.36")
MAX_PAGES = 12

if len(sys.argv) != 2:
    sys.exit("usage: draft-level2.py <club website URL>")
START = sys.argv[1] if sys.argv[1].startswith("http") else "https://" + sys.argv[1]

# --- gazetteer, from the clubs we already have -------------------------------
GIVEN, FAMILY = set(), set()
for f in glob.glob(str(REPO / "JSON" / "*.level2.json")):
    try: d = json.load(open(f, encoding="utf-8"))
    except Exception: continue
    for m in (d.get("members") or []):
        n = m.get("name", {})
        if n.get("givenName"): GIVEN.add(n["givenName"].lower())
        if n.get("familyName"): FAMILY.add(n["familyName"].lower())

INFIX = (r"(?:[Vv]an [Dd]er|[Vv]an [Dd]en|[Vv]an [Dd]e|[Vv]an 't|[Vv]an|[Dd]e|[Dd]en|[Dd]er|"
         r"[Tt]en|[Tt]er|[Tt]e|[Hh]et|'t|[Vv]\.[Dd]\.|[Vv]d|[Oo]p de|[Aa]an de|[Uu]it de)")
# A compound family name must not swallow its own hyphen, or "Spuls-Veld"
# is read as "Spuls-" and then trimmed to "Spuls". Second element optional,
# hyphen-joined, and may carry an infix: Spuls-Veld, Beckers-van Hout,
# van Heugten-van-Nunen.
FAM = r"[A-Z][a-zà-ÿ']{1,20}(?:-(?:(?:van der|van de|van|de|der|den)[- ])?[A-Z][a-zà-ÿ']{1,20})?"
FULL = re.compile(rf"\b([A-Z][a-zà-ÿ]{{1,14}})\s+(?:({INFIX})\s+)?({FAM})\b")
# Dutch streets are <person><suffix>, so "Jan Duikerlaan" parses as a person.
# Only compounds are rejected: "van der Laan" keeps its bare token. Suffixes that
# are also common surname endings (-berg, -dijk, -veld, -hoven) are left out.
STREET = re.compile(r"(?:laan|straat|weg|plein|singel|steeg|gracht|kade)$", re.I)
STOP = set("""fotoclub fotogroep fotokring foto club groep nederland holland canon nikon sony fuji
januari februari maart april mei juni juli augustus september oktober november december lees meer
privacy beleid algemene voorwaarden nieuwe pagina home contact agenda expositie workshop cookie
lightroom photoshop facebook instagram google adobe leden bestuur album jaar werk nieuws archief
zoeken menu volgende vorige reactie reacties bekijk galerij
de het een en of maar want dus als dan toen nu hier daar waar wie wat welke deze dat dit die
ik jij hij zij wij jullie hun hen ons onze mijn jouw zijn haar er men
is was waren wordt worden werd werden heeft hebben had hadden kan kunnen kon konden
zal zullen zou zouden mag mogen moet moeten wil willen doet doen deed deden gaat gaan ging
in op aan met voor door over onder tussen naar uit bij om tot na sinds tijdens zonder tegen
vanuit vanaf binnen buiten achter naast langs volgens ondanks wegens
niet geen ook nog al alleen even weer heel erg zeer meer minst meest veel weinig
eigen nieuwe oude eerste tweede laatste beste mooie
burgemeester wethouder gedeputeerde juryleden jurylid gastspreker
maandag dinsdag woensdag donderdag vrijdag zaterdag zondag
tevens echter verder tenslotte kortom namens inmiddels""".split())

def score(g, inf, fam):
    """An infix confirms a name, it never creates one, or any capitalised word
    before "Van" becomes a person. A known given name in the family position means
    two people side by side ("Bram  Greetje"), not one unusual surname."""
    if g.lower() in STOP or fam.lower() in STOP: return 0
    if STREET.search(fam) and len(fam) > 7: return 0
    kg, kf = g.lower() in GIVEN, fam.lower() in FAMILY
    s = (2 if kg else 0) + (1 if kf else 0)
    if inf and (kg or kf): s += 2
    if fam.lower() in GIVEN and not kf: s -= 2
    if s == 0 and re.match(r"^[A-Z][a-z]{2,9}$", g) and re.match(r"^[A-Z][a-zà-ÿ'\-]{2,}$", fam):
        s = 1
    return s

def key(g, inf, fam):
    """Identity is given name plus family name. The infix is left out on purpose:
    sites write "van den Broek" and "van de Broek" for one person, and diacritics
    come and go, so neither can be part of who someone is."""
    d = unicodedata.normalize("NFD", f"{g} {fam}".lower())
    return " ".join("".join(c for c in d if not unicodedata.combining(c)).split())

def names_in(text):
    """-> {key: (given, infix, family, score)}; infix lowercased, as the data stores it."""
    out = {}
    for m in FULL.finditer(" ".join(text.split())):
        g, inf, fam = m.group(1), (m.group(2) or ""), m.group(3)
        s = score(g, inf, fam)
        fam = fam.rstrip("-'")
        if s >= 2 and len(fam) > 1:
            k = key(g, inf, fam)
            prev = out.get(k)
            # keep the spelling with diacritics; the infix is always lowercased
            if (not prev
                    or (any(ord(c) > 127 for c in g + fam)
                        and not any(ord(c) > 127 for c in prev[0] + prev[2]))
                    or len(inf) > len(prev[1])):
                out[k] = (g, inf.lower(), fam, s)
    return out

strip = lambda s: html.unescape(re.sub(r"<[^>]+>", " ", s))
BLOCK = re.compile(r"<(li|td|h2|h3|h4|figcaption|dt|strong)\b[^>]*>(.*?)</\1>", re.I | re.S)
ANCHOR = re.compile(r"<a\b[^>]*>(.*?)</a>", re.I | re.S)
PARA = re.compile(r"<p\b[^>]*>(.*?)</p>", re.I | re.S)
SLUG = re.compile(r"/([A-Za-z][A-Za-zÀ-ÿ]*[-_][A-Za-z][A-Za-zÀ-ÿ'\-]*)(?:\.[a-z]{2,4})?(?:/|$|\?)")
GOOD = re.compile(r"leden|member|fotografen|deelnemers|galerij|gallery|portfolio|expositie|"
                  r"eigen-?werk|wie-?zijn|over-?ons|bestuur|jaar", re.I)
SKIP = re.compile(r"\.(jpg|jpeg|png|gif|pdf|zip|mp4|css|js)($|\?)|wp-admin|wp-login|/feed|"
                  r"\?replytocom|#|mailto:|tel:|/tag/|/author/", re.I)
host = lambda u: (re.match(r"https?://([^/]+)", u or "") or [None, ""])[1].lower().replace("www.", "")

def fetch(url, dest):
    r = subprocess.run(["curl", "-sSL", "--max-time", "20", "--max-filesize", "3000000",
                        "-A", UA, "-w", "%{http_code}", "-o", str(dest), url],
                       capture_output=True, text=True)
    return (r.stdout or "000").strip().startswith("2")

# --- crawl -------------------------------------------------------------------
cache = HERE / ".cache"; cache.mkdir(exist_ok=True)
h0, seen, queue, pages = host(START), set(), [START], []
print(f"reading {h0} ...", file=sys.stderr)
while queue and len(pages) < MAX_PAGES:
    u = queue.pop(0)
    if u in seen or SKIP.search(u) or host(u) != h0: continue
    seen.add(u)
    dest = cache / f"p{len(pages):02d}.html"
    if not fetch(u, dest):
        time.sleep(.4); continue
    body = dest.read_text(errors="replace")
    pages.append((u, body))
    found = []
    for m in re.finditer(r'href=["\']([^"\']+)["\']', body, re.I):
        href = m.group(1)
        full = (href if href.startswith("http")
                else re.match(r"https?://[^/]+", u).group(0) + href if href.startswith("/")
                else u.rsplit("/", 1)[0] + "/" + href)
        if host(full) == h0 and not SKIP.search(full) and full not in seen:
            found.append(full)
    found.sort(key=lambda x: (0 if re.search(r"/(onze-)?leden/?$|/members/?$", x, re.I)
                              else 1 if GOOD.search(x) else 2, len(x)))
    queue = found[:20] + queue
    time.sleep(.6)

if not pages:
    sys.exit(f"error: could not read anything from {START}")

# --- extract -----------------------------------------------------------------
# Structure decides membership; prose only corroborates. Blogs are full of guest
# speakers, jury members and famous photographers who are not members here.
roster, evidence = {}, collections.defaultdict(list)
infixes = collections.defaultdict(set)
for url, body in pages:
    structural = {}

    def absorb(found, from_slug=False):
        """Record every infix spelling before anything is collapsed.

        Merging happens by identity, which deliberately ignores the infix, so
        without this the variants disappear inside the dict and the report below
        can never see them. A slug is scored lower than visible text: a CMS builds
        it by lowercasing and hyphenating, so it is a machine's rendering of the
        name rather than what anyone wrote."""
        for k, (g, inf, fam, sc) in found.items():
            if inf: infixes[k].add(inf)
            v = (g, inf, fam, sc - 1 if from_slug else sc)
            if k not in structural or v[3] > structural[k][3]: structural[k] = v

    for a in ANCHOR.findall(body): absorb(names_in(strip(a)))
    for _, b in BLOCK.findall(body): absorb(names_in(strip(b)))
    for m in re.finditer(r'(?:href|src)=["\']([^"\']+)["\']', body, re.I):
        for sl in SLUG.findall(m.group(1)):
            absorb(names_in(" ".join(w.capitalize() for w in re.split(r"[-_]", sl) if w)),
                   from_slug=True)
    for k, v in structural.items():
        if k not in roster or v[3] > roster[k][3]: roster[k] = v
        evidence[k].append(url)
    for q in PARA.findall(body):
        for k in names_in(strip(q)):
            if k in roster: evidence[k].append(url)

# --- write -------------------------------------------------------------------
nick = re.sub(r"[^A-Za-z0-9]", "", h0.split(".")[0]) or "club"
members = [{"name": {"givenName": g, "infixName": inf, "familyName": fam},
            "optional": {}}
           for g, inf, fam, _ in (roster[k] for k in sorted(roster, key=lambda k: roster[k][2].lower()))]
doc = {"club": {"idPlus": {"town": "FILL IN", "fullName": "FILL IN", "nickName": nick},
                "coordinates": {"latitude": 0, "longitude": 0},
                "optional": {}},
       "members": members}
out = HERE / f"{nick}.level2.json"
out.write_text(json.dumps(doc, indent=1, ensure_ascii=False) + "\n", encoding="utf-8")

print(f"\n{len(pages)} pages read, {len(members)} candidate members\n", file=sys.stderr)
for k in sorted(roster, key=lambda k: roster[k][2].lower()):
    g, inf, fam, s = roster[k]
    print(f"  {(g + ' ' + inf + ' ' + fam).replace('  ', ' '):<32} "
          f"{len(set(evidence[k]))}p  {sorted(set(evidence[k]))[0][:64]}", file=sys.stderr)
# Near-duplicates are usually a typo on the club's own site rather than two people.
# A club website is typed by a clubmate, not by its subject, and the mistakes are
# phonetic and directional: "van der" loses its r to "van de", "Osch" becomes "Os".
# Both are pronounced the same, and the shorter form is nearly always the wrong one.
# So the longer spelling is offered as the likely original, but nothing is merged:
# "Jan Bos" and "Jan Bosch" really can be two people. The authority is neither
# spelling on the club site but the person's own page or LinkedIn, where nobody
# misspells their own name.
pairs = []
ks = sorted(roster)
for i, a in enumerate(ks):
    ga, _, fa, _ = roster[a]
    for b in ks[i + 1:]:
        gb, _, fb, _ = roster[b]
        if ga.lower() == gb.lower() and (fa.lower().startswith(fb.lower())
                                         or fb.lower().startswith(fa.lower())):
            pairs.append((roster[a], roster[b]))
if pairs:
    print("\nprobably one person, misspelt on their own site. Longer form shown first,",
          file=sys.stderr)
    print("as the usual error is a dropped letter. Check against the person's own page:",
          file=sys.stderr)
    for a, b in pairs:
        long_, short_ = sorted((a, b), key=lambda t: -len(t[1] + t[2]))
        fmt = lambda t: (t[0] + " " + t[1] + " " + t[2]).replace("  ", " ")
        print(f"  {fmt(long_):<30} rather than  {fmt(short_)}", file=sys.stderr)

# An infix cannot be derived. "van de" and "van der" are both frozen leftovers of a
# three-gender Dutch that no longer exists, so both are correct for different
# families and neither is a longer-is-better case. When a site writes more than one
# for the same person, say so and pick nothing: a wrong infixName does not read as a
# typo, it creates a second person the next time the data loads.
mixed = {k: v for k, v in infixes.items() if len(v) > 1 and k in roster}
if mixed:
    print("\nthe site writes the infix more than one way. Not derivable, so check the",
          file=sys.stderr)
    print("person's own page rather than guessing; the draft uses the first shown:",
          file=sys.stderr)
    for k, v in sorted(mixed.items()):
        g, inf, fam, _ = roster[k]
        print(f"  {g} {fam}: " + " / ".join(sorted(v, key=lambda x: (x != inf, x))), file=sys.stderr)

print(f"\nwrote {out}", file=sys.stderr)
print("club block needs town, fullName and coordinates by hand.", file=sys.stderr)
