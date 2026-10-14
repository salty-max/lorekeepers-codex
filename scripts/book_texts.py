#!/usr/bin/env python3
"""The game's own texts (every book, note and plaque the world holds) in a
client language, for the Library: a text copied in another language reads in
the client's, a quest item handed in long ago included. Run from the addon's
folder:

  python3 scripts/book_texts.py frFR

Reads the English texts from the pinned CMaNGOS database (text objects, type
9, and items with a page: their titles and page chains) and the language's
pages from .cache/books-<locale>.json, Wowhead's Forever pages for each text
({ "o<object id>" | "i<item id>": [ HTML pages ] }). Wowhead turns scripts
away, so that file comes from a browser: each /forever/<lang>/object=<id> or
item=<id> page embeds new Book({ pages: [...] }) (docs/localization.md).
Tracked corrections and translations in i18n/<locale>/books-supplement.json
take precedence, with hashes of their English sources and provenance. Its
excluded records document deprecated/test items and broken source bindings.

Writes i18n/<locale>/books.json: { English title: [ { first, pages } ] },
first the start of the English first page (letters only, to tell apart the
texts that share a title), pages plain text: the game's tags turned into
lines, its placeholders into the game's tokens ($N, $C, $R, $gmale:female;).
"""
import gzip, hashlib, html, json, os, re, sys

locale = sys.argv[1]
db = gzip.open(".cache/classicdb-28ef6259c782.sql.gz", "rt", encoding="utf-8", errors="replace").read()
VALUE = re.compile(r"'((?:[^'\\]|\\.)*)'|(-?[\d.]+)|NULL")


def unescape(s):
    return re.sub(r"\\(.)", lambda m: {"n": "\n", "r": "", "t": "\t", "0": ""}.get(m.group(1), m.group(1)), s)


def rows(table):
    for m in re.finditer(rf"INSERT INTO `{table}` VALUES(.*?);\n", db, re.S):
        for r in re.finditer(r"\(((?:[^()']|'(?:[^'\\]|\\.)*')*)\)", m.group(1)):
            yield [unescape(v.group(1)) if v.group(1) is not None else (v.group(2) or "") for v in VALUE.finditer(r.group(1))]


def columns(table):
    return re.findall(r"^\s*`(\w+)`", re.search(rf"CREATE TABLE `{table}` \((.*?)\n\)", db, re.S).group(1), re.M)


pages = {r[0]: (r[1], r[2]) for r in rows("page_text")}
ic = columns("item_template")
ni, pi = ic.index("name"), ic.index("PageText")
texts = [(f"o{r[0]}", r[3], r[8]) for r in rows("gameobject_template") if r[1] == "9" and r[8] != "0"]
texts += [(f"i{r[0]}", r[ni], r[pi]) for r in rows("item_template") if len(r) > pi and r[pi] not in ("0", "")]


def chain(page):
    out, seen = [], set()
    while page and page != "0" and page in pages and page not in seen:
        seen.add(page)
        out.append(pages[page][0])
        page = pages[page][1]
    return out


def letters(text, n=24):
    text = re.sub(r"\$[A-Za-z]", "", re.sub(r"<[^>]+>", " ", text))
    return re.sub(r"[^a-z]", "", text.lower())[:n]


TOKENS = {"nom": "$N", "name": "$N", "classe": "$C", "class": "$C", "race": "$R"}


def plain(page):
    # the placeholders first, while they are still escaped
    page = re.sub(r"&lt;([^&]{1,24})&gt;", lambda m: TOKENS.get(m.group(1).lower()) or (
        "$g%s:%s;" % tuple(m.group(1).split("/")) if m.group(1).count("/") == 1 else "<" + m.group(1) + ">"), page)
    page = re.sub(r"<br\s*/?>", "\n", page, flags=re.I)
    page = re.sub(r"</(p|h\d)>", "\n\n", page, flags=re.I)
    page = re.sub(r"<(?!texte|text)[^>]*>", "", page)
    page = html.unescape(page).replace(" ", " ").translate(str.maketrans({"‘": "'", "’": "'", "“": '"', "”": '"'}))
    # The user's prose punctuation rule, without touching $gmale:female;.
    parts = re.split(r"(\$g[^;]+;)", page)
    page = "".join(p if i % 2 else re.sub(r"\s*;\s*", ", ", p) for i, p in enumerate(parts))
    page = re.sub(r"[ \t]+\n", "\n", page)
    page = re.sub(r"\n{3,}", "\n\n", page)
    return page.strip()


source = json.load(open(f".cache/books-{locale}.json", encoding="utf-8"))
supplement_path = f"i18n/{locale}/books-supplement.json"
supplement = json.load(open(supplement_path, encoding="utf-8")) if os.path.exists(supplement_path) else {}
corrections = supplement.get("entries", {})
excluded = supplement.get("excluded", {})
known = {key for key, _, _ in texts}
if (set(corrections) | set(excluded)) - known:
    raise ValueError("Readable supplement references unknown object/item ids")
if set(corrections) & set(excluded):
    raise ValueError("A readable cannot be both translated and excluded")
out, missing = {}, []
for key, title, first in texts:
    if key in excluded:
        continue
    en = chain(first)
    tr = source.get(key)
    correction = corrections.get(key)
    if correction:
        digest = hashlib.sha256(json.dumps(en, ensure_ascii=False, separators=(",", ":")).encode()).hexdigest()
        if correction["title"] != title or correction["source_sha256"] != digest:
            raise ValueError(f"{key}: translated source changed, review {supplement_path}")
        tr = correction["pages"]
    if not isinstance(tr, list) or not tr:
        missing.append(f"{key} {title}")
        continue
    entry = {"first": letters(en[0]) if en else "", "pages": [plain(p) for p in tr]}
    # Keep enough of the source to distinguish shared openings, such as the
    # three Twilight circulars beginning "For immediate dissemination...".
    entry["full_first"] = letters(en[0], None) if en else ""
    entry["full_source"] = [letters(p, None) for p in en]
    if correction and correction.get("english_first"):
        entry["first"] = letters(correction["english_first"])
        entry["full_first"] = letters(correction["english_first"], None)
    variants = out.setdefault(title, [])
    if not any(v["pages"] == entry["pages"] or v["full_source"] == entry["full_source"] for v in variants):
        variants.append(entry)
for title, variants in out.items():
    for v in variants:
        others = [w for w in variants if w is not v]
        while any(w["full_first"].startswith(v["first"]) for w in others):
            length = len(v["first"]) + 1
            if length > len(v["full_first"]):
                raise ValueError(f"{title}: indistinguishable English first pages")
            v["first"] = v["full_first"][:length]
    for v in variants:
        del v["full_first"]
        del v["full_source"]
os.makedirs(f"i18n/{locale}", exist_ok=True)
with open(f"i18n/{locale}/books.json", "w", encoding="utf-8") as f:
    json.dump(dict(sorted(out.items())), f, ensure_ascii=False, indent=1)
    f.write("\n")
print(f"i18n/{locale}/books.json: {sum(len(v) for v in out.values())} texts under {len(out)} titles; {len(excluded)} documented source exceptions; {len(missing)} unaccounted for: {', '.join(missing[:12])}{' ...' if len(missing) > 12 else ''}")
