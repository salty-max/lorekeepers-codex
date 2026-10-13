#!/usr/bin/env python3
"""The names a translation must use: every place, faction and figure the
English pages name, as each game's client writes it in that language.

  python3 scripts/glossary.py frFR

Places and factions from each client's own tables (wago.tools: AreaTable and
Faction, Classic Era and the pinned Forever build, in English and in the
language), figures from Wowhead's Classic and Forever tooltips by their ids
(the pages' npc unlocks and portraits). Cached in .cache/i18n/.

Writes i18n/<locale>/glossary.json, { "places" | "factions" | "figures":
{ English: { "forever": name, "classic": name } } }, for the translator;
and i18n/<locale>/classic.json, { Forever's name: Classic's name } where the
two clients differ: a translation is written with Forever's names (the game
it launches for), and Classic's own replace them when the file loads there
(Locale.lua). Classic's names lose the English some carry in brackets
("Les Carmines (Redridge Mts)"): prose never takes it.
"""
import csv, glob, json, os, re, sys, time, urllib.error, urllib.request

ROOT = os.path.join(os.path.dirname(__file__), "..")
CACHE = os.path.join(ROOT, ".cache", "i18n")
UA = {"User-Agent": "LorekeepersCodex/1.0 (addon localization; github.com/salty-max/lorekeepers-codex)"}
PRODUCTS = {"classic": "product=wow_classic_era", "forever": "product=wow_classic_beta&build=1.60.1.70291"}
WOWHEAD = {"classic": "classic", "forever": "forever"}
# Wowhead's language codes
WH = {"frFR": 2, "deDE": 3, "esES": 6, "esMX": 7, "ruRU": 8, "ptBR": 10, "koKR": 1, "zhCN": 4}


def fetch(url, path):
    if not os.path.exists(path):
        os.makedirs(os.path.dirname(path), exist_ok=True)
        try:
            with urllib.request.urlopen(urllib.request.Request(url, headers=UA), timeout=180) as r:
                body = r.read()
        except urllib.error.HTTPError as e:
            if e.code != 404:
                raise
            body = b"{}"  # (not in that game: kept, not asked again)
        with open(path, "wb") as f:
            f.write(body)
        time.sleep(0.2)
    return path


def table(game, name, locale):
    loc = "" if locale == "enUS" else f"&locale={locale}"
    path = fetch(f"https://wago.tools/db2/{name}/csv?{PRODUCTS[game]}{loc}", os.path.join(CACHE, game, f"{name}-{locale}.csv"))
    field = "AreaName_lang" if name == "AreaTable" else "Name_lang"
    return {r["ID"]: r[field] for r in csv.DictReader(open(path, encoding="utf-8"))}


def wowhead(game, id, locale):
    path = fetch(f"https://nether.wowhead.com/{WOWHEAD[game]}/tooltip/npc/{id}?locale={WH.get(locale, 0)}", os.path.join(CACHE, game, f"npc-{id}-{locale}.json"))
    try:
        return (json.load(open(path, encoding="utf-8")) or {}).get("name")
    except json.JSONDecodeError:
        return None


def bare(name):
    # (straight apostrophes, as the pages: some of the game's own names curl them)
    return re.sub(r"\s*\([^)]*\)\s*$", "", name or "").strip().replace("\u2019", "'")


def main():
    locale = sys.argv[1]
    pages = sorted(glob.glob(os.path.join(ROOT, "content", "**", "*.md"), recursive=True))
    prose = "\n".join(open(p, encoding="utf-8").read() for p in pages)
    out = {"places": {}, "factions": {}, "figures": {}}
    # places and factions: every one whose English name the pages use
    for kind, name in (("places", "AreaTable"), ("factions", "Faction")):
        en = {g: table(g, name, "enUS") for g in PRODUCTS}
        loc = {g: table(g, name, locale) for g in PRODUCTS}
        for g in PRODUCTS:
            for id, english in en[g].items():
                if len(english) < 4 or not re.search(rf"(?<![\w']){re.escape(english)}(?![\w'])", prose):
                    continue
                entry = out[kind].setdefault(english, {})
                if loc[g].get(id) and g not in entry:
                    entry[g] = bare(loc[g][id])
    # figures: the pages' npc unlocks and portraits, and every character the
    # prose names (a name of two words or more: the pinned database's
    # creatures, Forever's new ones from the beta's traces in Yonder's cache)
    ids = set()
    import gzip
    db = gzip.open(os.path.join(ROOT, ".cache", "classicdb-28ef6259c782.sql.gz"), "rt", encoding="utf-8", errors="replace").read()
    i = db.find("INSERT INTO `creature_template` VALUES")
    known = {}
    for m in re.finditer(r"\((\d+),'((?:[^'\\]|\\.)*)'", db[i : db.find(";\n", i)]):
        known.setdefault(m.group(2).replace("\\'", "'"), m.group(1))
    traces = os.path.join(ROOT, "..", "yonder", ".cache", "forever", "questiedb-npc-7e87203312ef.lua")
    if os.path.exists(traces):
        for m in re.finditer(r"\[(\d+)\] = \{[^{}]*?\[npcKeys\.name\] = \"([^\"]+)\"", open(traces, encoding="utf-8").read()):
            known.setdefault(m.group(2), m.group(1))
    for name, id in known.items():
        if " " in name and re.search(rf"(?<![\w']){re.escape(name)}(?![\w'])", prose):
            ids.add(id)
    for p in pages:
        head = open(p, encoding="utf-8").read().split("\n---\n", 1)[0]
        for m in re.finditer(r"^\s*-\s*(?:\[\w+\]\s*)?npc:\s*(.+)$", head, re.M):
            ids |= set(re.findall(r"\d+", m.group(1).split("#")[0]))
        for m in re.finditer(r"^portrait:\s*(\d+)", head, re.M):
            ids.add(m.group(1))
    for id in sorted(ids, key=int):
        english = wowhead("classic", id, "enUS") or wowhead("forever", id, "enUS")
        if not english:
            continue
        entry = out["figures"].setdefault(english, {})
        for g in PRODUCTS:
            name = wowhead(g, id, locale)
            if name:
                entry[g] = name.replace("\u2019", "'")
    dest = os.path.join(ROOT, "i18n", locale)
    os.makedirs(dest, exist_ok=True)
    with open(os.path.join(dest, "glossary.json"), "w", encoding="utf-8") as f:
        json.dump(out, f, ensure_ascii=False, indent=1, sort_keys=True)
        f.write("\n")
    # Forever's names that Classic writes otherwise (the longest first: a
    # place's name may hold another's)
    swaps = {}
    for kind in out.values():
        for e in kind.values():
            fv, cl = e.get("forever"), e.get("classic")
            if fv and cl and fv != cl and fv not in swaps:
                swaps[fv] = cl
    # (French elides "de" before a vowel: "d'Austrivage" is "de Southshore"
    # on Classic, "de Fossoyeuse" is "d'Undercity")
    if locale == "frFR":
        vowel = lambda w: w[:1] in "AEIOUÂÉÈÊÎÔÛ"
        for fv, cl in list(swaps.items()):
            if vowel(fv) and not vowel(cl):
                swaps["d'" + fv] = "de " + cl
            elif not vowel(fv) and vowel(cl):
                swaps["de " + fv] = "d'" + cl
    with open(os.path.join(dest, "classic.json"), "w", encoding="utf-8") as f:
        json.dump(dict(sorted(swaps.items(), key=lambda kv: (-len(kv[0]), kv[0]))), f, ensure_ascii=False, indent=1)
        f.write("\n")
    print(f"i18n/{locale}/glossary.json: {sum(len(v) for v in out.values())} names; classic.json: {len(swaps)} Classic names")


if __name__ == "__main__":
    main()
