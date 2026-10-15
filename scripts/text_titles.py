#!/usr/bin/env python3
"""The Library's titles in a client language, English one of them: every text
each game holds (wow-data's databases, ../wow-data: its `readable` table, the
text objects and the items with a page) by its id, the identity a copy is
known by ("o<object id>", "i<item id>"), with its title in that language, each
game's own and complete: i18n/<locale>/texts.json, { "forever": { id: title },
"classic": { id: title } }. A copy whose identity is known reads by this
language's title (Library.lua's ns.textTitle), never by its English one. Run
from the addon's folder, for every language:

  python3 scripts/text_titles.py frFR
"""
import json, os, sys

locale = sys.argv[1]
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "wow-data", "py"))
from wowdata import db


def titles(game):
    out = {}
    for kind, id, name in db(game).execute(
        """SELECT r.kind, r.id, n.name FROM readable r
           JOIN name n ON n.kind = r.kind AND n.id = r.id AND n.locale = ?
           WHERE r.removed IS NOT 1 ORDER BY r.kind DESC, r.id""",
        (locale,),
    ):
        name = (name or "").strip().replace("’", "'")
        if name and not name.startswith("["):
            out[f"{kind[0]}{id}"] = name
    return out


out = {"forever": titles("forever"), "classic": titles("classic")}
# Titles supplied with the readable supplement (by the text's identity) fill
# only those neither game names in this language: the game's own always win.
supplement = f"i18n/{locale}/books-supplement.json"
if os.path.exists(supplement):
    for id, entry in json.load(open(supplement, encoding="utf-8")).get("entries", {}).items():
        if entry.get("localized_title"):
            for game in out.values():
                game.setdefault(id, entry["localized_title"])
os.makedirs(f"i18n/{locale}", exist_ok=True)
with open(f"i18n/{locale}/texts.json", "w", encoding="utf-8") as f:
    json.dump({k: dict(sorted(v.items(), key=lambda kv: (kv[0][0], int(kv[0][1:])))) for k, v in out.items()}, f, ensure_ascii=False, indent=1)
    f.write("\n")
print(f"i18n/{locale}/texts.json: {len(out['forever'])} of Forever's texts, {len(out['classic'])} of Classic's")
