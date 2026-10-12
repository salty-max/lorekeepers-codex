#!/usr/bin/env python3
"""Texts: the books and plaques of the world a page unlocks by being read
(front matter "read: <title>"), into data/texts.json (read by
scripts/build.ts): each title's objects in the CMaNGOS Classic database pinned
in scripts/portraits.py too (a text object, type 9, of that name) and the title as
the game writes it in every language, from Wowhead Classic's tooltips (cached
in .cache/wowhead/), so the unlock works in every client.

  python3 scripts/texts.py      (after adding or changing a read: unlock)
"""
import glob, gzip, json, os, re, time, urllib.request

# the database scripts/portraits.py pins (the same file, cached once)
COMMIT = "28ef6259c782928b08a8dc9cacf6bc02e64f2b29"
URL = f"https://github.com/cmangos/classic-db/raw/{COMMIT}/Full_DB/ClassicDB_1_12_1_z2815.sql.gz"
ROOT = os.path.join(os.path.dirname(__file__), "..")
CACHE = os.path.join(ROOT, ".cache", f"classicdb-{COMMIT[:12]}.sql.gz")


def sql_text():
    if not os.path.exists(CACHE):
        os.makedirs(os.path.dirname(CACHE), exist_ok=True)
        urllib.request.urlretrieve(URL, CACHE)
    with gzip.open(CACHE, "rt", encoding="utf-8", errors="replace") as f:
        return f.read()


OUT = os.path.join(ROOT, "data", "texts.json")
WOWHEAD = os.path.join(ROOT, ".cache", "wowhead")
UA = {"User-Agent": "LorekeepersCodex/0.9 (addon data; github.com/salty-max/lorekeepers-codex)"}
# Wowhead's locales (koKR, frFR, deDE, zhCN, esES, ruRU, ptBR, zhTW); esMX
# reads esES's names, itIT has none of its own on Classic.
LOCALES = [0, 1, 2, 3, 4, 6, 7, 8, 10]


def wanted():
    """The titles pages unlock by (content/**/*.md: "- read: <title>")."""
    out = set()
    for f in glob.glob(os.path.join(ROOT, "content", "**", "*.md"), recursive=True):
        head = open(f, encoding="utf-8").read().split("\n---\n", 1)[0]
        out.update(t.strip() for t in re.findall(r"^\s*-\s*read:\s*(.+)$", head, re.M))
    return out


def text_objects(sql):
    """The dump's text objects (type 9): {name: [ids]}."""
    cols = re.findall(r"^\s*`(\w+)`", re.search(r"CREATE TABLE `gameobject_template` \((.*?)\n\) ENGINE", sql, re.S).group(1), re.M)
    out = {}
    for m in re.finditer(r"INSERT INTO `gameobject_template` (?:\([^)]*\) )?VALUES\s*(.*?);\n", sql, re.S):
        for row in re.finditer(r"\((\d+),(.*?)\)(?=,\(|$)", m.group(1), re.S):
            vals = [row.group(1)] + re.findall(r"'((?:[^'\\]|\\.)*)'|([^,]+)", row.group(2))
            vals = [vals[0]] + [a if a or not b else b for a, b in vals[1:]]
            d = dict(zip(cols, vals))
            if d.get("type") == "9":
                out.setdefault(d["name"].replace("\\'", "'"), []).append(int(d["entry"]))
    return out


def names(id):
    """The object's name in each of Wowhead's locales."""
    out = []
    for locale in LOCALES:
        path = os.path.join(WOWHEAD, f"object-{id}-{locale}.json")
        if not os.path.exists(path):
            os.makedirs(WOWHEAD, exist_ok=True)
            url = f"https://nether.wowhead.com/classic/tooltip/object/{id}?locale={locale}"
            with urllib.request.urlopen(urllib.request.Request(url, headers=UA), timeout=30) as r, open(path, "wb") as f:
                f.write(r.read())
            time.sleep(0.25)
        name = (json.load(open(path, encoding="utf-8")) or {}).get("name")
        if name and name not in out:
            out.append(name)
    return out


def main():
    titles = wanted()
    objects = text_objects(sql_text())
    missing = sorted(t for t in titles if t not in objects)
    if missing:
        raise SystemExit("no text object of that name in the database: " + ", ".join(missing))
    data = {}
    for t in sorted(titles):
        ids = sorted(objects[t])
        everyone = []
        for id in ids:
            everyone += [n for n in names(id) if n not in everyone]
        if t not in everyone:
            everyone.insert(0, t)
        data[t] = {"ids": ids, "names": everyone}
    with open(OUT, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=1, sort_keys=True)
        f.write("\n")
    print(f"{len(data)} texts -> data/texts.json")


if __name__ == "__main__":
    main()
