# Worm Wars — Foundation Package (v2, family-corrected)

> **Name is not final.** "Worm Wars" is a placeholder. The real name should be chosen by Chloe and
> Ryan from the candidates in `07_NAME_ENEMIES_WEAPONS.md` (lead pick: **WIGGLE RUMBLE**). Once they
> pick, swap it in everywhere.

> **READ `00_FAMILY_TRUTH.md` FIRST.** It is the result of an interview about what these two
> specific kids actually want, and it **overrides** any other doc where they disagree. The big
> correction: this is a **solo-first** game, not a versus-first one.

Everything needed to start building a local creature-brawler for two kids, with Claude.

## What's here

| File | What it is | Status |
|---|---|---|
| `00_FAMILY_TRUTH.md` | The interview result. Solo-first, the fairness linchpin, karma, bounded-emergence combos, comedic losses, hierarchy. **Overrides everything below.** | **NEW — read first** |
| `01_GAME_DESIGN.md` | The vision and design decisions. Body-is-the-scoreboard, Worm Builder, no-numbers, arena-as-mode, boss, combat, comeback. | Revised for solo-first |
| `02_TECHNICAL_SPEC.md` | Engine, performance budget, networking architecture, project structure, build order. | Revised: build order reordered, hardware floor updated |
| `03_BUILD_PROMPTS.md` | Ready-to-paste prompts for Claude/Claude Code, stage by stage. | Revised: solo hook first, networking later |
| `04_ART_AND_WORM_BUILDER.md` | Art spec + the Worm Builder, driven by Chloe's drawing. Her most-wanted feature. | Mostly unchanged; still ships first to the kids |
| `05_BORROWED_CODE_REFERENCES.md` | Vetted open-source to learn from/borrow; LAN-discovery pattern. | Unchanged (applies when networking arrives, later) |
| `06_DESTRUCTION_AND_FAIRNESS.md` | Ryan's half + the rules that keep it fun for the kid who's behind. | Revised: fairness filter + bounded-emergence combat |
| `07_NAME_ENEMIES_WEAPONS.md` | Name candidates, enemy bestiary, weapons/powerups — all "being a worm." | Revised: powerups carry tags; bosses scale solo/co-op |
| `08_THE_SECRET.md` | Creature-feeding, garden, blueprints, the persistence loop. | Revised: re-scoped to variety-not-power; outputs leak into brawl |
| `09_ASSET_GENERATION.md` | Cheap procedural sound (bfxr2) + Claude-generated flat SVG art. | Unchanged |

## The ideas the whole thing rests on (v2)

1. **It's solo-first.** The daily hook is one kid playing alone — eat, grow, fight baddies, beat a
   boss, unlock a part. That loop must beat Slither.io. Versus is the occasional reunion event.

2. **Grind buys breadth, never height.** Solo build-up unlocks *variety* (new parts, tools,
   creatures) — never *power that carries into a fight*. Both worms start a versus match equal.
   This is the rule that keeps sibling fights fair forever. The fairness filter is a hard guardrail.

3. **The body is the scoreboard.** The bigger, more-evolved worm visibly *is* the one ahead. Round
   wins are a victory *moment* (Smash's "GAME!" zoom), not a badge. And now: **loss is a moment too**
   — a bank of *hilarious* loss animations, because a funny loss teaches grace with no words.

4. **A non-reader knows the state in three seconds.** No scores, XP, currencies, or text menus on
   the kids' screens. Size, color, animation, sound, transformation.

5. **The Worm Builder is Chloe's headline want.** Per-segment color, shape, face. No networking
   needed — ship it to the kids first, week one.

6. **Ryan mixes ingredients, he doesn't get handed explosions.** Bounded-emergence combos: 4-6
   hidden property tags, items as the interface, every pair enumerable and safe-by-default. Powder
   Toy's surprise without Powder Toy's chaos.

7. **Catch-up is invisible AND karmic.** Hidden rubber-band (the trailing kid gets the big satisfying
   toys) *plus* a karma layer where care/cooperation quietly compound into delight that leaks into
   the brawl — never labeled, never power, always "just how the world works."

8. **The brawl is the game; the secret is the soul.** Brainless eat-everything beat-em-up is the
   dominant, on-screen experience. The creature/garden/karma layer is pervasive but recessive.

## How to build (v2 order)

1. Start a Godot 4 project (the spec describes the structure Claude will create).
2. Open Claude Code in the project folder. Drop all docs in, **doc 00 first**.
3. Paste the system/context prompt from `03_BUILD_PROMPTS.md`.
4. Work the stages in the **new** order: skeleton → **Worm Builder (to the kids week one)** →
   **the SOLO hook (eat/grow/fight/boss/unlock — this is "done enough")** → combination combat →
   then networking/versus → then the karma/secret layer.
5. **Networking is no longer first.** The solo hook doesn't need it, and it's the scariest part —
   so the kids are playing a fun game long before two tablets have to talk.
6. Test on the real tablet(s) after every stage.

## The one rule that saves you (v2)

Build the **hook** first, not the network. The daily loop is solo, so the first milestone is one
worm that's fun to play alone against the world. Prove *that* beats Slither.io before spending a
single weekend on LAN. Networking is real work, but it's now content-stage risk, not
does-this-project-even-exist risk.
