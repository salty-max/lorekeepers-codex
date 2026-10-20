#!/usr/bin/env python3
"""Texts: the books and plaques of the world a page unlocks by being read
(front matter "read: <title>"), into data/texts.json (read by
scripts/build.ts): each title's objects in wow-data's Classic database
(../wow-data: a text object, type 9, a button with a page, type 10, or an
item with a page, of that name) and the title as the game writes it in every
language, so the unlock works in every client.

  python3 scripts/texts.py      (after adding or changing a read: unlock)
"""
import glob, json, os, re, sys

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..")
from root import family_path  # noqa: E402  (scripts/root.py, the kit's copy: the family folder, from a worktree too)

sys.path.insert(0, family_path("wow-data", "py"))
from wowdata import db

OUT = os.path.join(ROOT, "data", "texts.json")
# the languages a title is looked for in, in this order (Wowhead Classic's:
# esMX reads esES's names, itIT has none of its own on Classic)
LOCALES = ["enUS", "koKR", "frFR", "deDE", "zhCN", "esES", "ruRU", "ptBR", "zhTW"]


def wanted():
    """The titles pages unlock by (content/**/*.md: "- read: <title>")."""
    out = set()
    for f in glob.glob(os.path.join(ROOT, "content", "**", "*.md"), recursive=True):
        head = open(f, encoding="utf-8").read().split("\n---\n", 1)[0]
        out.update(t.strip() for t in re.findall(r"^\s*-\s*read:\s*(.+)$", head, re.M))
    return out


def text_objects():
    """The world's readable things: {English name: [(kind, id)]}: text
    objects (type 9), buttons that open a page (type 10, its data7), items
    with a page."""
    out = {}
    for kind, id, name in db("classic").execute(
        """SELECT 'object', o.id, n.name FROM object o JOIN name n ON n.kind = 'object' AND n.id = o.id AND n.locale = 'enUS'
           WHERE o.type = 9 OR (o.type = 10 AND json_extract(o.data, '$[7]') != 0)
           UNION ALL
           SELECT 'item', i.id, n.name FROM item i JOIN name n ON n.kind = 'item' AND n.id = i.id AND n.locale = 'enUS'
           WHERE i.page_id > 0"""
    ):
        out.setdefault(name, []).append((kind, id))
    return out


def names(kind, id):
    """The object's or item's name in each language, the first of each."""
    out = []
    for locale in LOCALES:
        row = db("classic").execute("SELECT name FROM name WHERE kind = ? AND id = ? AND locale = ?", (kind, id, locale)).fetchone()
        if row and row[0] not in out:
            out.append(row[0])
    return out


def main():
    titles = wanted()
    objects = text_objects()
    missing = sorted(t for t in titles if t not in objects)
    if missing:
        raise SystemExit("nothing readable of that name in the database: " + ", ".join(missing))
    data = {}
    for t in sorted(titles):
        found = sorted(objects[t])
        ids = [id for _, id in found]
        everyone = []
        for kind, id in found:
            everyone += [n for n in names(kind, id) if n not in everyone]
        if t not in everyone:
            everyone.insert(0, t)
        data[t] = {"ids": ids, "names": everyone}
    with open(OUT, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=1, sort_keys=True)
        f.write("\n")
    print(f"{len(data)} texts -> data/texts.json")


if __name__ == "__main__":
    main()
