#!/usr/bin/env python3
"""The game's own texts (every book, note and plaque the world holds) in a
client language, for the Library: a text copied in another language reads in
the client's, a quest item handed in long ago included. Run from the addon's
folder:

  python3 scripts/book_texts.py frFR

Reads wow-data's databases (../wow-data): the texts (text objects, type 9,
and items with a page), their English titles and pages from Classic Era's
(Forever's own texts' from Forever's), the language's pages from Forever's
(Wowhead's Forever pages, saved from a browser and kept in wow-data: Wowhead
turns scripts away), the game's markup already turned into lines and its
placeholders into the game's tokens ($N, $C, $R, $gmale:female;). A text
Wowhead gives only in English, in brackets, is no translation. Tracked corrections and translations in
i18n/<locale>/books-supplement.json take precedence, with hashes of their
English sources and provenance. Its excluded records document
deprecated/test items and broken source bindings.

Writes i18n/<locale>/books.json: { English title: [ { first, pages } ] },
first the start of the English first page (letters only, to tell apart the
texts that share a title), pages plain text in the Codex's own rules (plain
spaces, straight quotes, no semicolons).
"""
import hashlib, json, os, re, sys

locale = sys.argv[1]
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "wow-data", "py"))
from wowdata import db

# every text: (key, English title), the objects first, by id
texts = db("classic").execute(
    """SELECT key, title FROM (
         SELECT 'o' || o.id AS key, n.name AS title FROM object o
         JOIN name n ON n.kind = 'object' AND n.id = o.id AND n.locale = 'enUS' WHERE o.type = 9 AND o.page_id > 0
         UNION ALL
         SELECT 'i' || i.id, n.name FROM item i
         JOIN name n ON n.kind = 'item' AND n.id = i.id AND n.locale = 'enUS' WHERE i.page_id > 0)
       ORDER BY substr(key, 1, 1) DESC, CAST(substr(key, 2) AS INTEGER)"""
).fetchall()


def pages(game, key, loc):
    """a text's pages in a game and a language, in order"""
    kind = "object" if key[0] == "o" else "item"
    return [r[0] for r in db(game).execute("SELECT text FROM readable_page WHERE kind = ? AND id = ? AND locale = ? ORDER BY idx", (kind, int(key[1:]), loc))]


def letters(text, n=24):
    text = re.sub(r"\$[A-Za-z]", "", re.sub(r"<[^>]+>", " ", text))
    return re.sub(r"[^a-z]", "", text.lower())[:n]


def untranslated(tr, en):
    """Wowhead's English in brackets: the language's client has no text of its
    own there (a supplement's translation, or none)"""
    if not en or len(tr) != len(en):
        return False
    for page, source in zip(tr, en):
        page = page.strip()
        if not (page.startswith("[") and page.endswith("]")) or letters(page[1:-1], None) != letters(source, None):
            return False
    return True


def plain(page):
    """the Codex's own rules over the game's text: plain spaces, straight
    quotes, no semicolons (the gender tokens' own kept)"""
    page = page.replace("\u00a0", " ").translate(str.maketrans({"\u2018": "'", "\u2019": "'", "\u201c": '"', "\u201d": '"'}))
    parts = re.split(r"(\$g[^;]+;)", page)
    page = "".join(p if i % 2 else re.sub(r"\s*;\s*", ", ", p) for i, p in enumerate(parts))
    page = re.sub(r"[ \t]+\n", "\n", page)
    page = re.sub(r"\n{3,}", "\n\n", page)
    return page.strip()


supplement_path = f"i18n/{locale}/books-supplement.json"
supplement = json.load(open(supplement_path, encoding="utf-8")) if os.path.exists(supplement_path) else {}
corrections = supplement.get("entries", {})
excluded = supplement.get("excluded", {})
known = {key for key, _ in texts}
if (set(corrections) | set(excluded)) - known:
    raise ValueError("Readable supplement references unknown object/item ids")
if set(corrections) & set(excluded):
    raise ValueError("A readable cannot be both translated and excluded")
out, missing = {}, []
for key, title in texts:
    if key in excluded:
        continue
    # the English: Classic's, else Forever's (its own texts, Wowhead's pages)
    en = pages("classic", key, "enUS") or pages("forever", key, "enUS")
    tr = pages("forever", key, locale) or None
    if tr and untranslated(tr, en):
        tr = None
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
