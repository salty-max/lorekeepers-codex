#!/usr/bin/env python3
"""The Library's titles in a client language: every text the world holds
(the pinned CMaNGOS database's text objects, type 9, and items with a page)
by its English title, with its title in that language from Wowhead's
tooltips, Forever's and Classic Era's: i18n/<locale>/texts.json, { "forever":
{ English: title }, "classic": { English: title where Classic's differs } }.
A text copied in another language reads by this one's title (Locale.lua). The
tooltips are cached in the kit's .cache/i18n/. Run from the addon's folder:

  python3 scripts/text_titles.py frFR
"""
import csv, gzip, io, json, os, re, sys, time, urllib.error, urllib.request
from concurrent.futures import ThreadPoolExecutor

locale = sys.argv[1]
KIT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "addon-kit")
CACHE = os.path.join(KIT, ".cache", "i18n")
UA = {"User-Agent": "LorekeepersCodex/1.0 (addon localization; github.com/salty-max/lorekeepers-codex)"}
WH = {"frFR": 2, "deDE": 3, "esES": 6, "esMX": 7, "ruRU": 8, "ptBR": 10, "koKR": 1, "zhCN": 4}
GAMES = {"forever": "forever/", "classic": "classic/"}

db = gzip.open(".cache/classicdb-28ef6259c782.sql.gz", "rt", encoding="utf-8", errors="replace").read()


def rows(table):
    for m in re.finditer(rf"INSERT INTO `{table}` VALUES(.*?);\n", db, re.S):
        for r in re.finditer(r"\(((?:[^()']|'(?:[^'\\]|\\.)*')*)\)", m.group(1)):
            yield next(csv.reader(io.StringIO(r.group(1)), quotechar="'", escapechar="\\", skipinitialspace=True))


def columns(table):
    m = re.search(rf"CREATE TABLE `{table}` \((.*?)\n\)", db, re.S)
    return re.findall(r"^\s*`(\w+)`", m.group(1), re.M)


ic = columns("item_template")
name_i, page_i = ic.index("name"), ic.index("PageText")
texts = [("object", r[0], r[3]) for r in rows("gameobject_template") if r[1] == "9" and r[8] != "0"]
texts += [("item", r[0], r[name_i]) for r in rows("item_template") if len(r) > page_i and r[page_i] not in ("0", "")]


def tooltip(game, kind, id):
    path = os.path.join(CACHE, game, f"{kind}-{id}-{locale}.json")
    if not os.path.exists(path):
        os.makedirs(os.path.dirname(path), exist_ok=True)
        url = f"https://nether.wowhead.com/{GAMES[game]}tooltip/{kind}/{id}?locale={WH[locale]}"
        try:
            with urllib.request.urlopen(urllib.request.Request(url, headers=UA), timeout=120) as r:
                body = r.read()
        except urllib.error.HTTPError as e:
            if e.code != 404:
                raise
            body = b"{}"
        with open(path, "wb") as f:
            f.write(body)
        time.sleep(0.2)
    try:
        return (json.load(open(path, encoding="utf-8")) or {}).get("name")
    except json.JSONDecodeError:
        return None


def names(t):
    kind, id, english = t
    return english, tooltip("forever", kind, id), tooltip("classic", kind, id)


out = {"forever": {}, "classic": {}}
with ThreadPoolExecutor(6) as pool:
    for english, fv, cl in pool.map(names, texts):
        fv = fv.replace("’", "'") if fv else None
        cl = cl.replace("’", "'") if cl else None
        if fv and fv != english:
            out["forever"].setdefault(english, fv)
        if cl and cl != (fv or english):
            out["classic"].setdefault(english, cl)
# Labels supplied with the readable supplement fill only titles for which
# Wowhead had no localized tooltip. Verified client labels always win.
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
