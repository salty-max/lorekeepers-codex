# German translation review: Lorekeeper's Codex

2026-10-14. Reviewed commit `8f85417`. Review only, with no translation,
generator or addon changes.

Follow-up, 15 October 2026: the corrections are implemented. See
[German translation fixes](german-translation-fixes.md) for the changes and
the source discrepancy deliberately retained. The findings below preserve
the original review, and the JSON ledger now records each resolution.

## Verdict

The German is usable and the authored coverage is complete. I would keep the
first-translation label and fix the concrete meaning and runtime problems
before calling it polished. This does not need a wholesale retranslation.
Most pages are understandable, retain their information and keep the two
narrators recognizable. The recurring weakness is following English sentence
structure and idioms too closely, even where the resulting German is awkward
or points to the wrong thing.

The report contains **45 notes: 25 P2 and 20 P3**. This includes
seven occurrences of one repeated lexical problem, three runtime findings
(one is an explicitly documented limitation), and two provenance/copy notes.
P2 means a meaningful issue to fix soon. P3 covers lower-impact wording,
clarification or a source decision. Not every note is a proven mistranslation.
Each one says what is established and what is a judgement call.

## Coverage and limits

| Component | Reviewed |
| --- | --- |
| Authored lore pages | All 438 German titles and full bodies read |
| Chapter titles and summaries | All 45 read |
| Interface and achievement strings | All 206 read |
| TOC descriptions | German description in all three client TOCs read |
| Readable supplements | All 29 entries read, including 25 authored translations |
| Library source coverage | All 447 object/item records checked |
| Shipped Library catalog | 391 variants under 372 titles, 1,215 pages screened |
| Client behavior | Existing checks plus focused executions of the actual locale and Library code |

English and German paragraph counts and faction/client marker sequences were
compared for every authored page. Every retained language finding was checked
against its English source where applicable. Numeric literals and interface
format argument types/order match. The English-source hash check reports no
stale German pages. All 438 source-pair hashes stayed unchanged during review.

The Library contains about 71,800 German words of sourced game transcripts.
Its full corpus was screened for English fallback bodies and checked against
the source inventory. The authored supplements were read individually, and
selected recovered passages were compared for meaning. This is **not a
word-for-word certification of every sourced game transcript**. Likewise,
passing the simulation does not test line wrapping or clipping inside a live
WoW client. The report does not claim native-human sign-off or remove
`meta.json`'s first-translation flag.

## What is working

- Archesonus remains a female royal historian, with warm, dry remarks and
  loyalty to Ironforge. Parqual's Horde asides still sound sharper and more
  sceptical. His Nathanos aside is a good example: he is obliged to record
  that the insulting ranger is not always wrong.
- The narrator's formal **Ihr/Euch** and the interface's informal **du** have
  different jobs and work together. I would not mechanically unify them.
- Short lines such as the opening of Teldrassil and Archesonus's invitation
  to bring a free afternoon carry her humour naturally. The German first
  stanza of the Fourth Troll Legend preserves both the warning and a rhyme.
- All faction/client paragraph tags survived. Gender tokens and punctuation
  syntax pass, with no prose semicolons found. Format arguments match their
  English keys. The German TOC descriptions are clear.
- Unusual game names should not be "corrected" from memory of modern Retail.
  The pinned client data uses **Holzplanke** for Timber and **Stormrage** in
  the names of the relevant armor pieces. The names match the project's
  client-first policy. Ironforge and Stormwind are not automatically English
  leftovers in these client versions.

I also considered **Adelshaus** a possible false friend, then dropped it as a
confirmed error. [Wowhead's German Deadmines listing](https://www.wowhead.com/de/zone=1581/die-todesminen)
uses that term for van Cleef's dispute. It needs historical client verification
before anyone substitutes a new institutional name. The same caution applies
to words that look strange in the game's older translations.

## Fix first

1. **Classic article substitution.** A generated name swap inserts an extra
   article in eight paragraphs and the Cenarion Circle title. Actual output
   includes `dem Der Zirkel des Cenarius` and `Der Der Zirkel des Cenarius`.
   Forever does not show this problem. The TBC TOC uses the same Classic content.
2. **Personalized readable matching.** An English report beginning
   `Hello, Thorin...` retains its English body although its title becomes
   German. The catalog fingerprint removes `$N`, while matching compares the
   rendered name. Existing German tests check presence, not this behavior.
3. **Meaning and reference.** Reposition the lake apposition in The Sundering,
   clarify the battle in Darrowshire, and state that Elaadrin seeks guidance
   from the Kirin Tor. Nathanos should train with the elves, not `ausbilden`
   without an object.
4. **Repeated lexical choices.** Use `Ausgräber` for excavation workers.
   Unqualified `Gräber` overwhelmingly suggests graves to a modern reader.
   A rare agent-noun reading is possible, but it is a bad choice in a book
   that also discusses real graves throughout.
5. **German sentence construction.** Correct the Earthen Ring attribution,
   the Shadowglen help clause and the Windshapers' `sich ... wagen` phrase.
   Then polish the interface and lower-impact literal idioms.

The three runtime findings are detailed first below. The rest are ordered
by priority and file. Suggested text is editorial guidance, sometimes a
whole sentence and sometimes a fragment, **not blind search-and-replace**.
Preserve source hashes, paragraph markers and confirmed client names.

## Findings

### DE-001 — P2: runtime limitation

[addon/LorekeepersCodex/Library.lua](/Users/max/code/wow-addons/lorekeepers-codex/addon/LorekeepersCodex/Library.lua:91)

Current: ns.bookTexts[t.title]

Suggested: Use a stable readable identity or map every known source-language title to it.

A saved French Lettre simple remains French after switching to German. Current code documents English-only conversion. Extend the contract explicitly if all prior library copies should follow the new client language.

### DE-002 — P2: runtime

[addon/LorekeepersCodex/Library.lua](/Users/max/code/wow-addons/lorekeepers-codex/addon/LorekeepersCodex/Library.lua:96)

Current: first:sub(1, #v.first) == v.first

Suggested: Match personalized first pages with placeholder-aware patterns, or keep a safe discriminating prefix before the token.

Sealed Research Report fails to localize when Hello, $N is expanded to Hello, Thorin. Even an unexpanded literal $N fails because generator removes N but runtime retains it. The title still appears German.

### DE-003 — P2: runtime

[i18n/deDE/classic.json](/Users/max/code/wow-addons/lorekeepers-codex/i18n/deDE/classic.json:5)

Current: "Zirkel des Cenarius": "Der Zirkel des Cenarius"

Suggested: Add a durable classic-by-hand.json override mapping Zirkel des Cenarius to itself and regenerate classic.json, or suppress article-only differences in the glossary generator. Do not only hand-edit this generated file.

Loading the actual German file through Locale.lua on Classic creates double articles in eight paragraphs (druids, tauren, moonglade, cenarion-circle, silithid, abyssal-council, ruins-of-ahnqiraj, silithus) and the Cenarion Circle title. Forever has zero. The TBC TOC loads the same Classic content. Static checks pass.

### DE-004 — P2: provenance

[addon/CURSEFORGE.md](/Users/max/code/wow-addons/lorekeepers-codex/addon/CURSEFORGE.md:52)

Current: The books you keep in the Library read in the game's own French or German too.

Suggested: Books in the Library can also be read in French or German. Existing game translations are supplemented with our own translations where needed.

The German supplement records 25 addon-authored translations. This should not be described as uniformly the game's own wording. Existing saved French copies and some personalized English reports also remain untranslated after a language change.

### DE-005 — P2: grammar

[i18n/deDE/pages/ages-past/the-war-of-the-spider.md](/Users/max/code/wow-addons/lorekeepers-codex/i18n/deDE/pages/ages-past/the-war-of-the-spider.md:6)

Current: von den Neruber

Suggested: von den Nerubern

Dative plural after von requires -n.

### DE-006 — P2: grammar meaning

[i18n/deDE/pages/azshara/azshara.md](/Users/max/code/wow-addons/lorekeepers-codex/i18n/deDE/pages/azshara/azshara.md:12)

Current: Dies sind nicht die Holzschlundfeste

Suggested: Diese Furbolgs gehören nicht zur Holzschlundfeste, die die Tunnel im Teufelswald bewacht.

Use the official faction label Holzschlundfeste, but correct the plural/singular construction and distinguish the furbolgs from the fortress.

### DE-007 — P2: grammar meaning

[i18n/deDE/pages/azshara/the-sundering.md](/Users/max/code/wow-addons/lorekeepers-codex/i18n/deDE/pages/azshara/the-sundering.md:6)

Current: über Kalimdor, einem See aus reiner Magie

Suggested: Vor zehntausend Jahren herrschten die Nachtelfen vom Ufer des Brunnens der Ewigkeit aus über Kalimdor. Der Brunnen war ein See aus reiner Magie im Herzen der Welt.

The lake apposition is misplaced and its case does not agree with the intended noun. Next to Kalimdor it suggests the continent is a lake. Make the Well the explicit subject of a second sentence.

### DE-008 — P2: lexical

[i18n/deDE/pages/badlands/hammertoes-digsite.md](/Users/max/code/wow-addons/lorekeepers-codex/i18n/deDE/pages/badlands/hammertoes-digsite.md:6)

Current: überrannten die Gräber

Suggested: überrannten die Ausgräber

Gräber normally means graves, not excavation workers. Recurs elsewhere.

### DE-009 — P2: lexical

[i18n/deDE/pages/badlands/uldaman.md](/Users/max/code/wow-addons/lorekeepers-codex/i18n/deDE/pages/badlands/uldaman.md:6)

Current: den Gräbern der Liga

Suggested: den Ausgräbern der Liga

Same diggers/graves ambiguity.

### DE-010 — P2: grammar

[i18n/deDE/pages/barrens/razorfen-downs.md](/Users/max/code/wow-addons/lorekeepers-codex/i18n/deDE/pages/barrens/razorfen-downs.md:6)

Current: unter den Stacheleber

Suggested: unter den Stachelebern

Dative plural, also sweep similar race nouns.

### DE-011 — P2: lexical

[i18n/deDE/pages/callings/hunters.md](/Users/max/code/wow-addons/lorekeepers-codex/i18n/deDE/pages/callings/hunters.md:12)

Current: zuerst die Gräber findet

Suggested: zuerst die Ausgräber findet

Same diggers/graves ambiguity reverses the punchline.

### DE-012 — P2: lexical

[i18n/deDE/pages/callings/warriors.md](/Users/max/code/wow-addons/lorekeepers-codex/i18n/deDE/pages/callings/warriors.md:10)

Current: wo die Gräber graben sollten

Suggested: wo die Ausgräber graben sollten

Diggers translated as graves.

### DE-013 — P2: lexical

[i18n/deDE/pages/dun-morogh/explorers-league.md](/Users/max/code/wow-addons/lorekeepers-codex/i18n/deDE/pages/dun-morogh/explorers-league.md:6)

Current: Historiker, Archäologen und Gräber

Suggested: Historiker, Archäologen und Ausgräber

League described as consisting of graves.

### DE-014 — P2: lexical

[i18n/deDE/pages/duskwood/stalvan-mistmantle.md](/Users/max/code/wow-addons/lorekeepers-codex/i18n/deDE/pages/duskwood/stalvan-mistmantle.md:10)

Current: Eine Lehrstelle

Suggested: Eine Stelle als Lehrer

Teaching post became an apprenticeship vacancy.

### DE-015 — P2: meaning

[i18n/deDE/pages/eastern-plaguelands/darrowshire.md](/Users/max/code/wow-addons/lorekeepers-codex/i18n/deDE/pages/eastern-plaguelands/darrowshire.md:8)

Current: um sie noch einmal zu schlagen

Suggested: um die Schlacht noch einmal zu schlagen

English fight it again points explicitly to the battle. German sie can refer to the battle, but the nearest antecedent is the spirits, producing the distracting reading defeat the spirits. Name the battle to remove that ambiguity.

### DE-016 — P2: meaning

[i18n/deDE/pages/eastern-plaguelands/nathanos-blightcaller.md](/Users/max/code/wow-addons/lorekeepers-codex/i18n/deDE/pages/eastern-plaguelands/nathanos-blightcaller.md:6)

Current: mit den Hochelfen von Quel'Thalas ausbilden durfte

Suggested: mit den Hochelfen von Quel'Thalas trainieren durfte

Ausbilden is transitive educating others, not training alongside them.

### DE-017 — P2: lexical

[i18n/deDE/pages/peoples/dark-iron-dwarves.md](/Users/max/code/wow-addons/lorekeepers-codex/i18n/deDE/pages/peoples/dark-iron-dwarves.md:8)

Current: ihre Gräber der Schattenschmiede

Suggested: ihre Ausgräber der Schattenschmiede

Diggers translated as graves.

### DE-018 — P2: grammar

[i18n/deDE/pages/peoples/earthen-ring.md](/Users/max/code/wow-addons/lorekeepers-codex/i18n/deDE/pages/peoples/earthen-ring.md:8)

Current: Ihre Absichten hat man rein genannt, selbst wer

Suggested: Ihre Absichten wurden selbst von denen als rein bezeichnet, die ihren Umgang für fragwürdig halten.

Even by those became even whoever, lacking link to predicate.

### DE-019 — P2: lexical

[i18n/deDE/pages/peoples/scarlet-crusade.md](/Users/max/code/wow-addons/lorekeepers-codex/i18n/deDE/pages/peoples/scarlet-crusade.md:6)

Current: und seither brennen sie: die Toten

Suggested: und seither verbrennen sie die Toten

Burn enemies became intransitive burn. Keep the cutting tone but correct verb.

### DE-020 — P2: grammar

[i18n/deDE/pages/teldrassil/shadowglen.md](/Users/max/code/wow-addons/lorekeepers-codex/i18n/deDE/pages/teldrassil/shadowglen.md:8)

Current: indem er hilft, was darin falsch gelaufen ist

Suggested: indem er hilft, die Probleme im Wald zu lösen

English helping with becomes German helfen with a direct-object was clause. Use helfen bei or helfen plus infinitive.

### DE-021 — P2: lexical

[i18n/deDE/pages/western-plaguelands/scholomance.md](/Users/max/code/wow-addons/lorekeepers-codex/i18n/deDE/pages/western-plaguelands/scholomance.md:8)

Current: durch sehr viel schlechte Geschichte führt

Suggested: durch eine düstere Vergangenheit führt

Bad history means dark past, not low-quality historiography.

### DE-022 — P2: lexical

[i18n/deDE/pages/wetlands/whelgars-excavation-site.md](/Users/max/code/wow-addons/lorekeepers-codex/i18n/deDE/pages/wetlands/whelgars-excavation-site.md:8)

Current: betrachteten die Gräber als Freiwild

Suggested: betrachteten die Ausgräber als Freiwild

Diggers translated as graves.

### DE-023 — P2: meaning

[i18n/deDE/pages/zephras-isle/the-high-order.md](/Users/max/code/wow-addons/lorekeepers-codex/i18n/deDE/pages/zephras-isle/the-high-order.md:6)

Current: blickt auf die Kirin Tor von Dalaran, um ihnen zu zeigen, wie

Suggested: hofft, von den Kirin Tor in Dalaran zu lernen, wie das gelingt

The English looks to the Kirin Tor to show them how makes the Kirin Tor the source of guidance. German um ihnen zu zeigen normally carries Elaadrin as the subject and can read as him instructing them. State that he seeks to learn from them.

### DE-024 — P2: grammar

[i18n/deDE/pages/zephras-isle/the-windshapers.md](/Users/max/code/wow-addons/lorekeepers-codex/i18n/deDE/pages/zephras-isle/the-windshapers.md:6)

Current: die Ebene der Elemente zu wagen

Suggested: sich in die Ebene der Elemente zu wagen

Venture into requires sich in ... wagen.

### DE-025 — P2: grammar

[i18n/deDE/words.json](/Users/max/code/wow-addons/lorekeepers-codex/i18n/deDE/words.json:25)

English key: `A line on the tooltip of creatures that unlock a page (a page to find, or its title once found), and of players whose people's or calling's page is still to find.`

Current: und von Spielern, deren Volk oder Berufung noch eine Seite zu finden hat.

Suggested: und von Spielern, für deren Volk oder Berufung dir noch die Seite fehlt.

The race/class is made the subject that must find a page. The player is the one who lacks it.

### DE-026 — P3: provenance

[docs/german-readable-translations.md](/Users/max/code/wow-addons/lorekeepers-codex/docs/german-readable-translations.md:21)

Current: the German client has none

Suggested: Wowhead provides no German body for these pages.

A missing localized body in Wowhead does not establish what the real game client contains. Correct the stronger claim.

### DE-027 — P3: idiom

[i18n/deDE/books-supplement.json](/Users/max/code/wow-addons/lorekeepers-codex/i18n/deDE/books-supplement.json:76)

Readable: `i216956`.

Current: genug Fähigkeit aufbringen

Suggested: endlich die nötige Fähigkeit beweisen

Muster the competence is clumsily literal. Better preserve the speaker's contempt with endlich fähig genug sein.

### DE-028 — P3: upstream meaning

[i18n/deDE/books.json](/Users/max/code/wow-addons/lorekeepers-codex/i18n/deDE/books.json:1381)

Readable: `o182203`, The Green Hills of Stranglethorn, page 12.

Current: Wir packten unsere Sachen und kehrten gut gelaunt ins Lager zurück.

Suggested: Wir packten unsere Sachen und kehrten bedrückt ins Lager zurück.

English says solemnly after the terrifying tiger appearance. The German client-cache wording says cheerfully. This is inherited upstream, not an authored supplement mistake. Preserve verbatim only by conscious choice.

### DE-029 — P3: idiom

[i18n/deDE/pages/ages-past/sargeras-and-the-betrayal.md](/Users/max/code/wow-addons/lorekeepers-codex/i18n/deDE/pages/ages-past/sargeras-and-the-betrayal.md:8)

Current: Er brach die Gefängnisse

Suggested: Er brach die Gefängnisse auf

The literal prison-breaking is awkward German. Both destroying the prisons and breaking them open fit the English. This is idiomatic polish, not a lore correction.

### DE-030 — P3: idiom

[i18n/deDE/pages/ages-past/the-lich-king.md](/Users/max/code/wow-addons/lorekeepers-codex/i18n/deDE/pages/ages-past/the-lich-king.md:8)

Current: Es schlug auf den Gletscher von Eiskrone in Nordend

Suggested: Es schlug auf dem Eiskronengletscher in Nordend ein

For an impact, einschlagen or aufschlagen is more idiomatic than the bare schlagen construction. This is a wording correction, not a changed event.

### DE-031 — P3: idiom

[i18n/deDE/pages/badlands/kargath.md](/Users/max/code/wow-addons/lorekeepers-codex/i18n/deDE/pages/badlands/kargath.md:8)

Current: einen stehenden Befehl

Suggested: einen dauerhaften Befehl

Stehender Befehl can occur in military usage, so this is not a confirmed mistranslation. Dauerhafter or allgemeiner Befehl is clearer for ordinary readers.

### DE-032 — P3: gender

[i18n/deDE/pages/blasted-lands/nethergarde-keep.md](/Users/max/code/wow-addons/lorekeepers-codex/i18n/deDE/pages/blasted-lands/nethergarde-keep.md:8)

Current: die Draenei Kum'isha

Suggested: der Draenei Kum'isha

Kum'isha is explicitly named Kum'isha der Sammler in both pinned games. Der Draenei is consistent with this masculine client label. Generic English draenei did not specify gender.

### DE-033 — P3: clarity

[i18n/deDE/pages/burning-steppes/anduin-lothar.md](/Users/max/code/wow-addons/lorekeepers-codex/i18n/deDE/pages/burning-steppes/anduin-lothar.md:10)

Current: brach die Horde in der folgenden Flucht

Suggested: schlug die Horde in die Flucht

Rout rendered as flight, with unclear side retreating. Verify English.

### DE-034 — P3: reference

[i18n/deDE/pages/durotar/ragefire-chasm.md](/Users/max/code/wow-addons/lorekeepers-codex/i18n/deDE/pages/durotar/ragefire-chasm.md:8)

Current: um ihn zu säubern

Suggested: um die Höhlen zu säubern

Masculine pronoun has only Taragaman nearby, not the plural caves. Check English.

### DE-035 — P3: idiom

[i18n/deDE/pages/elwynn/si-7.md](/Users/max/code/wow-addons/lorekeepers-codex/i18n/deDE/pages/elwynn/si-7.md:8)

Current: endete mit beiden Männern tot

Suggested: endete mit dem Tod beider Männer

English absolute construction copied into German.

### DE-036 — P3: clarity

[i18n/deDE/pages/moonglade/keeper-remulos.md](/Users/max/code/wow-addons/lorekeepers-codex/i18n/deDE/pages/moonglade/keeper-remulos.md:6)

Current: mit dem hirschgleichen Unterleib seines Vaters

Suggested: mit einem hirschgleichen Unterleib wie dem seines Vaters

Can imply possessing father's literal body. English also compressed, classify optional clarification.

### DE-037 — P3: agreement

[i18n/deDE/pages/peoples/night-elves.md](/Users/max/code/wow-addons/lorekeepers-codex/i18n/deDE/pages/peoples/night-elves.md:10)

Current: dass sie bis vor wenigen Jahren alle Zeit der Welt hatten

Suggested: dass sie bis vor wenigen Jahren alle Zeit der Welt hatte

The English uses singular they. German switches from eine Nachtelfe to plural hatten without making the collective reference explicit. Either retain singular hatte or deliberately name the whole people.

### DE-038 — P3: idiom

[i18n/deDE/pages/stonetalon/stonetalon-mountains.md](/Users/max/code/wow-addons/lorekeepers-codex/i18n/deDE/pages/stonetalon/stonetalon-mountains.md:8)

Current: bis auf den Grund niedergebrannt

Suggested: vollständig niedergebrannt

Burned to the ground calque applied to an entire forested valley.

### DE-039 — P3: lexical

[i18n/deDE/pages/tirisfal/the-crusades-fallen.md](/Users/max/code/wow-addons/lorekeepers-codex/i18n/deDE/pages/tirisfal/the-crusades-fallen.md:8)

Current: an der Mündung des Eiskronengletschers

Suggested: Verify the inscription and use a glacier-specific expression, such as an der Gletscherzunge, if that is what it describes.

Mouth was carried into German as the river term Mündung. Gletscherzunge or an approach/entrance may be intended, but the exact landmark is not pinned by the source. Clarify only after checking the inscription. This is a wording/source question, not a proven changed location.

### DE-040 — P3: idiom

[i18n/deDE/pages/ungoro-crater/crystal-pylons.md](/Users/max/code/wow-addons/lorekeepers-codex/i18n/deDE/pages/ungoro-crater/crystal-pylons.md:8)

Current: eine ehrliche Befriedigung

Suggested: Es ist schlicht befriedigend, wenn eine Entdeckung zuerst die Werkbank und erst später die Geschichtsbücher erreicht.

Ehrliche Befriedigung is understandable, so this is optional polishing. A simpler formulation makes Archesonus's pleasure in a useful discovery more immediate and less abstract.

### DE-041 — P3: reference

[i18n/deDE/pages/wetlands/menethil-harbor.md](/Users/max/code/wow-addons/lorekeepers-codex/i18n/deDE/pages/wetlands/menethil-harbor.md:8)

Current: Kümmert Euch um ihn

Suggested: Helft dem Captain

English Attend to him is also compressed. Clarify help for Stoutfist rather than accidentally referring back to defeating Nek'rosh. This is ambiguity, not a proved reversal.

### DE-042 — P3: idiom

[i18n/deDE/words.json](/Users/max/code/wow-addons/lorekeepers-codex/i18n/deDE/words.json:23)

English key: `A Tale Worth Telling`

Current: Eine Geschichte, die es wert ist

Suggested: Eine erzählenswerte Geschichte

Achievement title drops telling and leaves worth it without its complement.

### DE-043 — P3: idiom

[i18n/deDE/words.json](/Users/max/code/wow-addons/lorekeepers-codex/i18n/deDE/words.json:31)

English key: `All Walks of Life`

Current: Aus allen Lebenslagen

Suggested: Alle Lebenswege

Walks of life means kinds of people/backgrounds, not changing circumstances.

### DE-044 — P3: idiom

[i18n/deDE/words.json](/Users/max/code/wow-addons/lorekeepers-codex/i18n/deDE/words.json:149)

English key: `Show each new page in the game's own alert. A click on it reads the page.`

Current: Ein Klick darauf liest die Seite.

Suggested: Ein Klick darauf öffnet die Seite.

A click opens a page, it does not read it. Appears in two alert descriptions.

### DE-045 — P3: idiom

[i18n/deDE/words.json](/Users/max/code/wow-addons/lorekeepers-codex/i18n/deDE/words.json:204)

English key: `this forgets every page and achievement this character has found. Type /codex reset yes to do it.`

Current: das vergisst jede Seite und jeden Erfolg, die dieser Charakter gefunden hat.

Suggested: das löscht alle gefundenen Seiten und erhaltenen Erfolge dieses Charakters.

Warning uses forget as a literal action and achievements are earned rather than found.

## Page coverage ledger

Every German page body and title was read. A row with no individual note means
no actionable problem was retained in that pass, not a guarantee of perfection.
The JSON companion records each page, source hashes and linked findings.

| Chapter | Pages read | Pages with retained notes |
| --- | ---: | ---: |
| Forewords | 10 / 10 | 0 |
| ages-past | 13 / 13 | 3 |
| alterac | 10 / 10 | 0 |
| arathi | 8 / 8 | 0 |
| ashenvale | 8 / 8 | 0 |
| azshara | 9 / 9 | 2 |
| badlands | 5 / 5 | 3 |
| barrens | 13 / 13 | 1 |
| blackrock-mountain | 12 / 12 | 0 |
| blasted-lands | 6 / 6 | 1 |
| burning-steppes | 6 / 6 | 1 |
| callings | 9 / 9 | 2 |
| darkshore | 7 / 7 | 0 |
| deadwind-pass | 2 / 2 | 0 |
| desolace | 9 / 9 | 0 |
| dun-morogh | 19 / 19 | 1 |
| durotar | 13 / 13 | 1 |
| duskwood | 9 / 9 | 1 |
| dustwallow | 7 / 7 | 0 |
| eastern-plaguelands | 12 / 12 | 2 |
| elwynn | 15 / 15 | 1 |
| felwood | 6 / 6 | 0 |
| feralas | 6 / 6 | 0 |
| hillsbrad | 5 / 5 | 0 |
| hinterlands | 8 / 8 | 0 |
| loch-modan | 8 / 8 | 0 |
| moonglade | 5 / 5 | 1 |
| mulgore | 9 / 9 | 0 |
| peoples | 56 / 56 | 4 |
| redridge | 5 / 5 | 0 |
| searing-gorge | 3 / 3 | 0 |
| silithus | 9 / 9 | 0 |
| silverpine | 8 / 8 | 0 |
| stonetalon | 5 / 5 | 1 |
| stranglethorn | 12 / 12 | 0 |
| swamp-of-sorrows | 6 / 6 | 0 |
| tanaris | 7 / 7 | 0 |
| teldrassil | 8 / 8 | 1 |
| thousand-needles | 4 / 4 | 0 |
| tirisfal | 18 / 18 | 1 |
| ungoro-crater | 5 / 5 | 1 |
| western-plaguelands | 12 / 12 | 1 |
| westfall | 6 / 6 | 0 |
| wetlands | 11 / 11 | 2 |
| winterspring | 5 / 5 | 0 |
| zephras-isle | 9 / 9 | 2 |

## Readable coverage and source decisions

The source inventory contains 447 records. Of these, 394 have supplied German
page chains, which deduplicate to 391 catalog variants. Fourteen are documented
source exceptions. Another 39 have no English or German page chain in the
current imported databases. They are listed in the JSON companion. This does
not establish that every one is unobtainable or unreadable in the real game.
It is also not proof of complete coverage of every Forever-only readable.

No additional fully English fallback body was found in the German catalog.
The blank Magical Ledger page and image-only or nonverbal pages are not
mistranslations. English proper names and incomprehensible spirit text are
not English prose gaps.

The complete Green Hills book has its cover and all 29 body pages. One
recovered German sentence says the party returned cheerfully where the
English says solemnly. That discrepancy is inherited from the game-text
cache. Do not silently rewrite an authentic client transcript while still
calling it verbatim. Choose and record a policy if you prefer fidelity to the
English over fidelity to the German client wording.

The supplement provenance is useful and should remain. The 25 authored
translations should be presented honestly as supplemental translations.
A missing localized page on Wowhead does not prove that the client itself
has no localization.

## Runtime reproductions

These checks load the current `Text_deDE.lua`, `Locale.lua` and `Library.lua`
with a minimal mock client. They do not edit saved variables or source files.

| Input / client | Observed result |
| --- | --- |
| Classic, Cenarion Circle prose | Eight paragraphs gain double articles, plus the page title |
| Forever, same prose | No double-article paragraphs |
| English `Simple Letter` copy, German client | German title and body |
| French `Lettre simple` copy, German client | Original French title and body |
| English `Sealed Research Report` starting `Hello, Thorin...` | German title, English body |
| Same report with literal `$N` | Still fails matching |

French-to-German conversion is an existing limitation: the code explicitly
promises conversion of English copies only. It matters when describing what
happens to a player's existing Library after a language change, but should
not be presented as a new regression caused by the German translator.
Likewise, the personalized-report bug is shared localization infrastructure,
not bad German wording.

## Validation and next revision

`bun run check` passed, including Lua linting, generation consistency,
localization checks and both client simulations. The German result is
438/438 authored pages, zero stale pages, 206/206 interface keys and 45/45
chapters. Paragraph marker sequences, numeric literals and format arguments
match. The name checker passes, although its loose morphology matching and
advisory list are not a linguistic certification.

Fix the generated substitution at its tracked source, not only in
`classic.json`. A German `classic-by-hand.json` identity override is one
small durable option. Add matching regressions that use personalized English
reports and the actual locale transformation. Decide explicitly whether old
French Library copies should follow the German client language, and describe
that behavior accurately on the store page.

Then address the P2 prose notes and the selected P3 copy edits. Rebuild,
rerun the existing checks and read a few long pages and tooltips in the actual
client, including Classic and male/female characters. Keep the first-translation
label until a native German reader has reviewed the revised wording.
