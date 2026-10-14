#!/usr/bin/env python3
"""The Library's titles in a client language: every text the world holds
(wow-data's Classic database, ../wow-data: text objects, type 9, and items
with a page) by its English title, with its title in that language, Forever's
and Classic Era's (each game's database): i18n/<locale>/texts.json, {
"forever": { English: title }, "classic": { English: title where Classic's
differs } }. A text copied in another language reads by this one's title
(Locale.lua). Run from the addon's folder:

  python3 scripts/text_titles.py frFR
"""
import json, os, sys

locale = sys.argv[1]
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "wow-data", "py"))
from wowdata import db

texts = db("classic").execute(
    """SELECT 'object', o.id, n.name FROM object o JOIN name n ON n.kind = 'object' AND n.id = o.id AND n.locale = 'enUS'
       WHERE o.type = 9 AND o.page_id > 0
       UNION ALL
       SELECT 'item', i.id, n.name FROM item i JOIN name n ON n.kind = 'item' AND n.id = i.id AND n.locale = 'enUS'
       WHERE i.page_id > 0
       ORDER BY 1 DESC, 2"""
).fetchall()  # (the objects first, by id: a title several texts share takes the first's)


def title(game, kind, id):
    row = db(game).execute("SELECT name FROM name WHERE kind = ? AND id = ? AND locale = ?", (kind, id, locale)).fetchone()
    return row[0] if row else None


out = {"forever": {}, "classic": {}}
for kind, id, english in texts:
    fv, cl = title("forever", kind, id), title("classic", kind, id)
    fv = fv.replace("’", "'") if fv else None
    cl = cl.replace("’", "'") if cl else None
    if fv and fv != english:
        out["forever"].setdefault(english, fv)
    if cl and cl != (fv or english):
        out["classic"].setdefault(english, cl)
# Labels supplied with the readable supplement fill only titles for which
# neither game has a localized one. The game's own labels always win.
supplement = f"i18n/{locale}/books-supplement.json"
if os.path.exists(supplement):
    for entry in json.load(open(supplement, encoding="utf-8")).get("entries", {}).values():
        if entry.get("localized_title"):
            out["forever"].setdefault(entry["title"], entry["localized_title"])
os.makedirs(f"i18n/{locale}", exist_ok=True)
with open(f"i18n/{locale}/texts.json", "w", encoding="utf-8") as f:
    json.dump({k: dict(sorted(v.items())) for k, v in out.items()}, f, ensure_ascii=False, indent=1)
    f.write("\n")
print(f"i18n/{locale}/texts.json: {len(texts)} texts, {len(out['forever'])} titles of Forever's, {len(out['classic'])} of Classic's own")
