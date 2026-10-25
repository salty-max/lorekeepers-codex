/**
 * The addon's package: the family's (scripts/package-lib.ts, the kit's copy):
 * addon/LorekeepersCodex as it is, one zip for every game, each game loading its own
 * TOC; its TOCs checked.
 *
 *   bun scripts/package.ts           dist/LorekeepersCodex and dist/LorekeepersCodex-<version>.zip
 *   bun scripts/package.ts --no-zip  the folder only (to copy into a game)
 *   bun scripts/package.ts --check   the TOCs only
 */
import { join } from "node:path";
import { run } from "./package-lib";

// (each game's own files: the pages: each game's own, TBC Anniversary reading Classic Era's)
run({ root: join(import.meta.dir, ".."), name: "LorekeepersCodex", games: { classic: ["Content_Classic.lua"], tbc: ["Content_Classic.lua"], forever: ["Content_Forever.lua"] } });
