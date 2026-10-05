#!/usr/bin/env python3
"""Portraits: the display id of each creature a page names as its portrait
(front matter "portrait: <creature id>"), from the CMaNGOS Classic database
pinned below, into data/portraits.json (read by scripts/build.ts).

  python3 scripts/portraits.py      (downloads ~13 MB once, cached in .cache/)

The book shows the game's still portrait of that display (as a unit frame's).
A page gets one only when it is about a creature: a figure (the figure
itself), a creature, or a faction (its leader, or one of its people).
"""
import glob, gzip, json, os, re, urllib.request

COMMIT = "28ef6259c782928b08a8dc9cacf6bc02e64f2b29"
URL = f"https://github.com/cmangos/classic-db/raw/{COMMIT}/Full_DB/ClassicDB_1_12_1_z2815.sql.gz"
ROOT = os.path.join(os.path.dirname(__file__), "..")
CACHE = os.path.join(ROOT, ".cache", f"classicdb-{COMMIT[:12]}.sql.gz")
OUT = os.path.join(ROOT, "data", "portraits.json")


def sql_text():
    if not os.path.exists(CACHE):
        os.makedirs(os.path.dirname(CACHE), exist_ok=True)
        urllib.request.urlretrieve(URL, CACHE)
    with gzip.open(CACHE, "rt", encoding="utf-8", errors="replace") as f:
        return f.read()


def creatures(sql, wanted):
    """creature_template rows of the wanted ids: name and first display id."""
    cols = re.findall(r"^\s*`(\w+)`", re.search(r"CREATE TABLE `creature_template` \((.*?)\n\) ENGINE", sql, re.S).group(1), re.M)
    out = {}
    for m in re.finditer(r"INSERT INTO `creature_template` (?:\([^)]*\) )?VALUES\s*(.*?);\n", sql, re.S):
        for row in re.finditer(r"\((\d+),(.*?)\)(?=,\(|$)", m.group(1), re.S):
            if int(row.group(1)) not in wanted:
                continue
            vals = [row.group(1)] + re.findall(r"'((?:[^'\\]|\\.)*)'|([^,]+)", row.group(2))
            vals = [vals[0]] + [a if a or not b else b for a, b in vals[1:]]
            d = dict(zip(cols, vals))
            display = next((int(d[k]) for k in ("ModelId1", "ModelId2", "ModelId3", "ModelId4") if int(d[k])), 0)
            out[int(d["Entry"])] = {"name": d["Name"].replace("\\'", "'"), "display": display}
    return out


wanted = set()
for f in glob.glob(os.path.join(ROOT, "content", "**", "*.md"), recursive=True):
    m = re.search(r"^portrait:\s*(\d+)", open(f, encoding="utf-8").read(), re.M)
    if m:
        wanted.add(int(m.group(1)))
found = creatures(sql_text(), wanted)
missing = sorted(wanted - set(found))
with open(OUT, "w") as f:
    json.dump({str(k): found[k] for k in sorted(found)}, f, indent=1)
    f.write("\n")
print(f"{len(found)} portraits -> data/portraits.json" + (f"; not in the database: {missing}" if missing else ""))
