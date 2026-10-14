#!/usr/bin/env python3
"""Portraits: the display id of each creature a page names as its portrait
(front matter "portrait: <creature id>"), from wow-data's Classic database
(../wow-data: the creature's first model, its English name), into
data/portraits.json (read by scripts/build.ts).

  python3 scripts/portraits.py

The book shows the game's still portrait of that display (as a unit frame's).
A page gets one only when it is about a creature: a figure (the figure
itself), a creature, or a faction (its leader, or one of its people).
"""
import glob, json, os, re, sys

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..")
sys.path.insert(0, os.path.join(ROOT, "..", "wow-data", "py"))
from wowdata import db

OUT = os.path.join(ROOT, "data", "portraits.json")


def creatures(wanted):
    """the wanted creatures: English name and first display id"""
    out = {}
    for id, name, models in db("classic").execute(
        f"""SELECT c.id, n.name, c.display_ids FROM creature c
            JOIN name n ON n.kind = 'creature' AND n.id = c.id AND n.locale = 'enUS'
            WHERE c.id IN ({",".join("?" * len(wanted))})""",
        sorted(wanted),
    ):
        out[id] = {"name": name, "display": int((models or "0").split(",")[0])}
    return out


wanted = set()
for f in glob.glob(os.path.join(ROOT, "content", "**", "*.md"), recursive=True):
    m = re.search(r"^portrait:\s*(\d+)", open(f, encoding="utf-8").read(), re.M)
    if m:
        wanted.add(int(m.group(1)))
found = creatures(wanted)
missing = sorted(wanted - set(found))
with open(OUT, "w") as f:
    json.dump({str(k): found[k] for k in sorted(found)}, f, indent=1)
    f.write("\n")
print(f"{len(found)} portraits -> data/portraits.json" + (f"; not in the database: {missing}" if missing else ""))
