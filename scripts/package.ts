/**
 * Builds one package per game from addon/LorekeepersCodex:
 *   dist/classic/LorekeepersCodex  + dist/LorekeepersCodex-classic.zip   Classic Era, TBC Anniversary
 *   dist/forever/LorekeepersCodex  + dist/LorekeepersCodex-forever.zip   World of Warcraft: Forever
 * Each gets the shared code, its game's content file as Content.lua, and a TOC
 * claiming its game's interface versions. The source folder is not itself an
 * installable addon (its TOC has an @INTERFACE@ placeholder).
 *
 *   bun scripts/package.ts           both folders and zips
 *   bun scripts/package.ts --no-zip  folders only (to copy into a game)
 */
import { cpSync, existsSync, mkdirSync, readdirSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { join } from "node:path";
import { spawnSync } from "node:child_process";

const ROOT = join(import.meta.dir, "..");
const SRC = join(ROOT, "addon/LorekeepersCodex");
const DIST = join(ROOT, "dist");
const GAMES = [
  { name: "classic", content: "Content_Classic.lua", interface: "11509, 20506" },
  { name: "forever", content: "Content_Forever.lua", interface: "16001" },
];

const toc = readFileSync(join(SRC, "LorekeepersCodex.toc"), "utf8");
if (!toc.includes("@INTERFACE@")) throw new Error("LorekeepersCodex.toc: no @INTERFACE@ placeholder");

for (const game of GAMES) {
  const dir = join(DIST, game.name, "LorekeepersCodex");
  rmSync(join(DIST, game.name), { recursive: true, force: true });
  mkdirSync(dir, { recursive: true });
  for (const f of readdirSync(SRC)) {
    if (!f.endsWith(".lua") || f.startsWith("Content_")) continue;
    cpSync(join(SRC, f), join(dir, f));
  }
  cpSync(join(SRC, game.content), join(dir, "Content.lua"));
  writeFileSync(join(dir, "LorekeepersCodex.toc"), toc.replace("@INTERFACE@", game.interface));
  if (!process.argv.includes("--no-zip")) {
    const zip = join(DIST, `LorekeepersCodex-${game.name}.zip`);
    if (existsSync(zip)) rmSync(zip);
    const r = spawnSync("zip", ["-qr", zip, "LorekeepersCodex", "-x", "*.DS_Store"], { cwd: join(DIST, game.name), stdio: "inherit" });
    if (r.status !== 0) throw new Error(`zip failed for ${game.name}`);
  }
  console.log(`✓ ${game.name}: dist/${game.name}/LorekeepersCodex${process.argv.includes("--no-zip") ? "" : `, dist/LorekeepersCodex-${game.name}.zip`} (interface ${game.interface})`);
}
