# French readable translations

14 October 2026. Follow-up to `french-readable-gaps.md`. The audit found 29
records with no French body, including seven with English bodies stored as
French. This change supplies French for 15 readable texts and preserves one
empty source page as empty. Thirteen records remain documented source exceptions.
This covers the audit's records, not every possible Forever-only readable.

## Translations supplied

The following 14 texts are translated from the pinned English page chains.
Their wording is ours, not certified French client text. Pages, facts and
reader placeholders are preserved. No later lore has been added.

| Source | Readable |
| --- | --- |
| o175747 | The Invasion of Draenor |
| o175759 | The Betrayer Ascendant |
| o175773 | Dorgar Stoenbrow |
| o175774 | Fellari Swiftarrow |
| o175775 | Ferren Marcus |
| o175777 | Holia Sunshield |
| o175781 | Yana Bloodspear |
| o177204 | Sorrow of the Earthmother |
| o177208 | The White Stag and the Moon |
| o179909 | Rock of Durotan |
| i4834 | Venture Co. Documents |
| i9542 | Simple Letter |
| i18401 | Foror's Compendium of Dragon Slaying |
| i21142 | From the Desk of Lord Victor Nefarius |

`o182203`, The Green Hills of Stranglethorn, now has its complete 30-page
French chain. Its 29 body pages reuse the existing French quest chapters
`i2756`–`i2759`, in order. The English book and chapter bodies were compared
page by page. Differences were spacing, one spelling error, and the final
end marker. The cover and end marker are translated here.

`i20949`, Magical Ledger, has an empty English page. Its French page remains
empty. There is no text to translate.

The missing label for Green Hills also receives a French fallback. Verified localized tooltip titles take priority.
Existing client titles, including the odd "Les parents du Traître", are kept
for consistency with the game.

## Source exceptions

These records receive no substitute body. A matching title is not sufficient
reason to attach another document's translation to it. Existing recorded
copies continue to display their original pages. Some may be obsolete, but
obtainability was not independently verified for each client.

| Source | Reason |
| --- | --- |
| o181475 | Monument of Remembrance: in neither Classic Era nor Forever (no Wowhead page in either), a later expansion's object. Excluded by the user's call, 14 October 2026. |
| o181573 | Jar of ashes: the same. |
| o181895 | Ship-repair title points to an unrelated postscript about Thrall and Outland. |
| i12564 | Assassination Note points to the Horde Catapult museum plaque. |
| i1078 | Explicitly deprecated. Duplicates Gramma Stonefield's Note. |
| i1356 | Commendation title points to the last page of Shaw's Report. |
| i2793 | Explicitly deprecated. Duplicates part of Berard's Journal. |
| i3677 | Explicitly deprecated. Duplicates the end of Decrypted Letter. |
| i3686 | Explicitly deprecated test item. |
| i5174 | Note from Neeru points to the Control Console Operating Manual. |
| i5353 | Message for Elissa points to a historical account of Ameth'Aran, ending with Foreboding Plans. |
| i5688 | Explicit test item. Duplicates Letter to Jin'Zil. |
| i6280 | Musty Missive points to Yuriv's Tombstone. |

These exceptions live beside the translations in `books-supplement.json`,
so a future source correction can be reviewed rather than silently imported.

## Two correspondence findings

**Captain's Documents (`i5882`).** The French manifest and letter are correct.
The [English Forever page](https://www.wowhead.com/forever/item=5882) visibly
begins "The Bleeding Sparrow: Manifest" and has two pages. The pinned database
instead attaches the three-page Spy's Report. The supplement preserves the
French manifest and uses its verified English opening. It does not replace
it with the unrelated scout report.

**Decoded Twilight Text (`i20552`).** This is one of several items sharing a
title. The four-page French wind-stone instructions were already in the
catalog, alongside the Ortell and escort circulars. All three had the same
24-letter English fingerprint, so matching selected the first. The importer
now extends the fingerprints until each opening is distinguishable. The
simulation checks all three against the generated French catalog.

The duplicate Pteradon Skeleton records have identical English page chains
but two equivalent French wordings. The importer keeps one translation for
that one text instead of two indistinguishable variants.

## Sources and rebuilding

The English source is the existing pinned CMaNGOS database
`classicdb-28ef6259c782.sql.gz`. The French chapter and manifest pages come
from the existing Wowhead browser cache. Every supplemented chain has a
source hash and a provenance note in `i18n/frFR/books-supplement.json`.

The [French Classic White Stag page](https://www.wowhead.com/classic/fr/object=177208)
was checked in the browser and still served a bracketed English body. The
[French Dorgar page](https://www.wowhead.com/classic/fr/object=175773)
provided no body. We do not treat these missing upstream translations as
verified French client wording.

Rebuild with `python3 scripts/book_texts.py frFR`,
`python3 scripts/text_titles.py frFR` and `bun run locales`.
`bun run check` validates the generated addon and runs both client simulations.

## Forever's newer texts (later on 14 October 2026)

Forever's list of texts grew to 447 after the French fetch. The 21 newer
items with a Wowhead page were fetched in French, and their English too
(`books-enUS.json` in wow-data: neither Questie nor the Classic database
has it). Ten came back in French. Ten came back as English in brackets,
Wowhead's mark for a string the French client lacks: they are translated
here like the earlier ones (`i207098`, `i208205`, `i208224`, `i210967`,
`i216610`, `i219929`, `i221017`, `i227748`, `i228144`, `i236002`). The
importer now treats a bracketed copy of the English as no translation at
all, so none ships as one again. `i226421`, a placeholder item named
`PLACEHOLDER_ASHBRINGER_QUESTITEM_01`, is a source exception. The importer
reports 391 texts under 372 titles, 14 source exceptions, and 39 texts
Wowhead has no page for in any language.
