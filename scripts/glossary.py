#!/usr/bin/env python3
"""The names a translation must use (the kit's glossary, shared by the addons:
~/code/wow-addons/addon-kit/glossary.py, from wow-data's databases), with the
Codex's sources: its pages, their npc unlocks and portraits.

  python3 scripts/glossary.py frFR
  python3 scripts/glossary.py frFR --swaps   (classic.json alone, after editing
                                              a by-hand file)
"""
import os, subprocess, sys

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..")
from root import family_path  # noqa: E402  (scripts/root.py, the kit's copy: the family folder, from a worktree too)

KIT = family_path("addon-kit", "glossary.py")
args = [sys.executable, KIT, *sys.argv[1:]]
if "--swaps" not in sys.argv:
    args += ["--prose", "content", "--ids", "npc", "portrait"]
sys.exit(subprocess.call(args, cwd=ROOT))
