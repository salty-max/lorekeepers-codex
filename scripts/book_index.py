#!/usr/bin/env python3
"""Readable identities and first-page templates for every translated catalog.

Run after book_texts.py for every translated locale. Read only wow-data's
databases and tracked catalogs/supplements. Never use a title alone to choose
between different texts. English bodies with a documented wrong page binding
are withheld rather than replacing a saved copy with unrelated prose.
"""
import hashlib
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT.parent / "wow-data" / "py"))
from wowdata import db


def pages(game, key, locale):
    kind = "object" if key[0] == "o" else "item"
    return [row[0] for row in db(game).execute(
        "SELECT text FROM readable_page WHERE kind=? AND id=? AND locale=? ORDER BY idx",
        (kind, int(key[1:]), locale))]


def plain(text):
    # Match the Library's HTML conversion, preserving literal <aside> text.
    if re.search(r"<html>", text, re.I):
        text = re.sub(r"<br\s*/?>", "\n", text, flags=re.I)
        text = re.sub(r"</(?:p|h\d)>", "\n\n", text, flags=re.I)
        text = re.sub(r"<[^>]+>", "", text)
    text = re.sub(r"\$[Bb]", "\n", text)
    text = re.sub(r"\$G(?=[^:;]*:)", "$g", text)
    text = text.replace("\u00a0", " ").translate(str.maketrans({"’": "'", "‘": "'", "“": '"', "”": '"'}))
    parts = re.split(r"(\$g[^;]+;)", text)
    text = "".join(part if i % 2 else re.sub(r"\s*;\s*", ", ", part) for i, part in enumerate(parts))
    return text.strip()


def patterns(text):
    """ASCII letter templates, placeholders wildcarded, both gender forms.

    Accent bytes and punctuation are ignored consistently by Lua and Python.
    Full first pages distinguish shared openings. A character's name/class/race
    is matched in its original language, independent of the current client.
    """
    forms = [plain(text)]
    while any(re.search(r"\$g([^:;]*):([^;]*);", form) for form in forms):
        expanded = []
        for form in forms:
            match = re.search(r"\$g([^:;]*):([^;]*);", form)
            if not match:
                expanded.append(form)
                continue
            for gender in match.groups():
                expanded.append(form[:match.start()] + gender + form[match.end():])
        forms = expanded
    out = set()
    for form in forms:
        chunks = re.split(r"\$[NnCcRr]", form)
        letters = [re.sub(r"[^a-z]", "", chunk.lower()) for chunk in chunks]
        out.add("[a-z]*".join(letters))
    return out


catalogs = {}
supplements = {}
swaps = {}
records = {}
for folder in sorted((ROOT / "i18n").iterdir()):
    if not (folder / "books.json").exists():
        continue
    locale = folder.name
    catalogs[locale] = json.loads((folder / "books.json").read_text())
    supplement = folder / "books-supplement.json"
    supplements[locale] = json.loads(supplement.read_text()).get("entries", {}) if supplement.exists() else {}
    classic = folder / "classic.json"
    swaps[locale] = json.loads(classic.read_text()) if classic.exists() else {}
    for title, variants in catalogs[locale].items():
        for variant in variants:
            for key in variant["ids"]:
                if key in records and records[key] != title:
                    raise ValueError(f"{key}: inconsistent English title")
                records[key] = title

texts, aliases, canonical, chains = {}, {}, {}, {}
for key, title in sorted(records.items()):
    english = pages("classic", key, "enUS") or pages("forever", key, "enUS")
    corrections = [entries[key] for entries in supplements.values() if key in entries]
    opening = next((entry["english_first"] for entry in corrections if entry.get("english_first")), None)
    # A verified opening corrects a broken binding, not the full English body.
    source = [plain(page) for page in english] if not opening else []
    digest = hashlib.sha256(json.dumps([title, source or [key]], ensure_ascii=False).encode()).hexdigest()
    identity = chains.setdefault(digest, key)
    canonical[key] = identity
    texts.setdefault(identity, {"title": title, "pages": source})


def add(title, key, first, prefix=False):
    bucket = aliases.setdefault(title, {}).setdefault(canonical[key], set())
    bucket.update(pattern + ("[a-z]*" if prefix else "") for pattern in patterns(first))


for key, title in sorted(records.items()):
    english = pages("classic", key, "enUS") or pages("forever", key, "enUS")
    corrections = [entries[key] for entries in supplements.values() if key in entries]
    opening = next((entry["english_first"] for entry in corrections if entry.get("english_first")), None)
    if opening:
        add(title, key, opening, prefix=True)
    elif english:
        add(title, key, english[0])
    for locale, catalog in catalogs.items():
        variant = next((v for v in catalog.get(title, []) if key in v["ids"]), None)
        if not variant:
            continue
        first = variant["pages"][0]
        localized_titles = {title}
        for game in ("classic", "forever"):
            kind = "object" if key[0] == "o" else "item"
            row = db(game).execute("SELECT name FROM name WHERE kind=? AND id=? AND locale=?",
                                   (kind, int(key[1:]), locale)).fetchone()
            if row:
                localized_titles.add(row[0].replace("’", "'"))
        supplied_title = supplements[locale].get(key, {}).get("localized_title")
        if supplied_title:
            localized_titles.add(supplied_title)
        classic_first = first
        for before, after in sorted(swaps[locale].items(), key=lambda pair: -len(pair[0])):
            classic_first = classic_first.replace(before, after)
        for name in localized_titles:
            add(name, key, first)
            add(name, key, classic_first)

shared_patterns = {key: set() for key in texts}
for variants in aliases.values():
    for key, values in variants.items():
        shared_patterns[key].update(values)
for key, entry in texts.items():
    entry["patterns"] = sorted(shared_patterns[key])
out = {"canonical": canonical, "texts": texts,
       "titles": {title: {key: True for key in sorted(variants)}
                  for title, variants in sorted(aliases.items())}}
output_path = ROOT / "i18n" / "books-index.json"
output_path.write_text(json.dumps(out, ensure_ascii=False, indent=1) + "\n")
print(f"{output_path.relative_to(ROOT)}: {len(texts)} identities, {len(aliases)} titles")
