# Worm Wars — Game Design Document (v2, solo-first)

> Read `00_FAMILY_TRUTH.md` first. Where it disagrees with this doc, it wins. This v2 folds the big
> corrections in directly, but 00 is the canonical statement of *why*.

## Vision

Build the fastest, funniest, most replayable worm game for two specific kids. Optimize for a
**solo loop worth opening the tablet for alone**, with an occasional couch-versus reunion and the
sometimes-co-op boss fight. Short rounds, memorable moments, over graphics. The test for every
decision: **could a kid who can't read tell who's winning by looking at the screen for three
seconds?** — and now also: **would Chloe, bored of Slither.io, replay this ALONE?**

This is not a Snake clone. It's a snake-based creature-brawler that borrows from Sonic (speed feels
good), Mario Kart (catch-up keeps it close), Smash Bros (players want to fight, and losing is
funny), Minecraft (build freely, no inventory tedium), and Powder Toy (mix ingredients, discover
reactions). Snake movement is the foundation, not the whole game.

## The biggest design fact: SOLO-FIRST (corrects the original assumption)

The original package assumed couch-versus is the spine. For these kids it is not. **The daily loop
is solo:** a kid plays alone — explore, eat, grow, fight NPC baddies, beat a boss, unlock a part,
grow a creature. That loop is the hook and **must beat Slither.io.** Versus is the occasional
reunion; co-op boss fights happen sometimes. See `00_FAMILY_TRUTH.md` for the full reordering.
Consequence: networking is content-stage work, not the foundation — the first milestone is one
worm, solo, fun against the world.

## The fairness linchpin: grind buys breadth, never height

Solo play *feels* like building up — but solo progression unlocks **variety, never power.** New
parts and tools are **sidegrades** (the Smash roster is horizontal). A versus worm never starts
stronger because its kid grinded more; both start equal and grow only from in-match events. Power
progression lives only in PvE. The **fairness filter** is a hard guardrail: *does grinding this make
you stronger in a fight, or just different? If stronger, it can't be grind-locked.* Full reasoning,
including the diligent-kid tension, in `00_FAMILY_TRUTH.md`.

## Constraints that shape everything

Advantages, not limitations. Design around them on purpose.

- Family-only software. Two primary users. No third audience.
- You control the hardware and network. No app store, accounts, monetization, analytics.
- Solo PvE is the daily driver; LAN/hotspot versus is the occasional reunion.
- Hardware is a strong modern tablet — the old "potato-tier" floor does NOT apply, but treat the
  headroom as a budget to spend deliberately (flat art + 30 Hz sim kept; shaders/particles spent
  only on spectacle beats). See `00_FAMILY_TRUTH.md`.
- The kids ignore numbers, words, XP bars, currencies, and menus. Everything communicates through
  size, color, animation, sound, and transformation — the worm's own body shows the state, the way
  Smash and Mario Kart do.

## The spine: the body shows the state (no crown, no scoreboard)

Smash, Mario Kart, and Sonic never put a crown or "you're winning" badge on screen — the thing the
player is already looking at tells the whole story. So here: **who's doing well is shown by the worm
itself — bigger, more evolved, spikier, transformed.** A kid glancing sees a giant Dragon worm
bullying a small one and knows instantly who's ahead. No crown required, because the mega-worm
already *is* the crown.

No persistent "leader" status during play, deliberately — Smash isn't about holding first place,
it's about the next knockout. The fun is the moment-to-moment scramble, not a guarded status.

### How a non-reader knows who's winning
Through **size and evolution.** Eating and surviving grow and transform your worm through visible
stages (Tiny, Fast, Spiky, Dragon, Mega). That growth *is* the scoreboard — readable at a glance.

### How a round ends legibly — both winning AND losing are moments
Not with an object, with a **moment.** At time-up (or knockout), the bigger/more-evolved worm gets
a victory animation, the screen, and the music — Smash's "GAME!" zoom.

**And losing is its own moment, on purpose hilarious** (new in v2). A total loss must be possible —
Chloe must be able to genuinely, visibly lose — but it lands as *funny, never unfair*: the Smash
"blasted off the stage" principle. There is a **bank of comedic loss animations** (eaten-and-
popped-out, launched-off-screen, deflated-to-noodle, balloon-drift, scattered-beads, flattened-
reinflate, and more over time), fired situationally and semi-randomly so the loss surprises every
time. Ryan loves funny; a funny loss teaches Chloe grace with zero words. This is a content
category, not one asset.

### How the trailing kid stays in it
Invisibly, the Mario Kart / Smash way — not a target to chase. The trailing kid's powerups skew to
the big satisfying destruction toys (full detail in `06_DESTRUCTION_AND_FAIRNESS.md`), and a karma
layer (below) quietly leaks delight into the brawl for kids who tend and cooperate.

## Catch-up is invisible AND karmic (both)

- **Invisible rubber-band:** the trailing worm gets the bigger, lower-precision, more satisfying
  toys. Never a visible "baby setting." Chloe must never see a handicap to resent.
- **Karma:** care and cooperation quietly compound into delight that surfaces during play — a
  hatched companion appears mid-brawl, a bloomed garden rains food (for both kids equally). Never
  labeled a reward for being good; reads as "just how the world works." **Leaks delight, never
  power** (fairness filter applies). The cause→effect link is never surfaced. Full detail in
  `08_THE_SECRET.md` and `00_FAMILY_TRUTH.md`.

## The secret/care layer: pervasive but recessive (re-scoped)

Beneath the brawl is a quiet game of care and cooperation — but for THIS family it is **not "the
real game."** The brainless eat-everything brawl is the dominant, on-screen hook. The care layer is
always present, never the thing on screen, never gating the core fun. A kid who only brawls has a
complete game; a kid who also tends gets a quietly richer one.

What it is: at round end, collected food feeds a **creature you're growing**, and *what you feed it
decides what it becomes* (metal→robot/Ryan, leaves→animal/Chloe, seeds→plant). **No inventory,
ever** — the kids live in Minecraft Creative; what they collect is never a bag to sort, it's food
for a transformation. Hatching permanently **unlocks blueprints** — new parts free to build with
forever. A shared **garden** blooms only if *both* kids tend it. Progress persists; neglect only
pauses (the creature sleeps, never dies). Re-scoped per the fairness filter: every output is
**variety/delight, never versus power.** Full detail in `08_THE_SECRET.md`.

## The Worm Builder (a core pillar, from Chloe's design)

The end user — Chloe — spent days drawing what she wants, and the headline feature is **building her
own worm**: choosing the color, shape, and face of each segment. A core pillar. Full detail in
`04_ART_AND_WORM_BUILDER.md`.

- The worm is **chunky and segmented**, not a thin line. The kids call it a "worm," not a snake.
- A no-reading builder lets a kid tap per-segment color (~14-swatch palette), per-segment shape
  (rectangle, oval, circle, diamond, pentagon, triangle, star), and a head face. It also offers
  **visible body types** — speedy, or heavy/spiky/armored/robot — so a kid chooses to be the fast
  one (Chloe) or the tanky bruiser (Ryan) on purpose. Body type is a playstyle **choice and a
  sidegrade, never a power tier** (fairness filter). See `06_DESTRUCTION_AND_FAIRNESS.md`.
- The worm they build is the worm they play. Saves locally per kid.
- No networking — ships to the kids in week one as a morale and feedback win.

## Core design pillars (v2)

1. **Solo-first fun.** The daily loop is one kid alone vs. the world, and it must beat Slither.io.
2. **60-second fun.** Rounds are 1-3 minutes, never long slither sessions.
3. **Constant interaction.** The arena is the third force — pests, thieves, bullies, bosses — so a
   solo kid always has something to do and a versus arena never feels empty.
4. **Grind buys breadth, never height.** Solo unlocks variety; versus worms start equal.
5. **Comeback built in, invisibly.** Catch-up is the Mario Kart / Smash way (trailing kid gets the
   best toys) plus the karma leak — never a visible "baby setting."
6. **Spectacular moments, win OR lose.** Boss explosions, mega-worm rampages, last-second size
   swings — and a bank of hilarious losses, because the funny loss is the grace lesson.

## The arena is the third player

Two worms (or one worm) alone isn't enough interaction. The arena is the opponent that fills the
space. Full bestiary — pests, thieves, bullies, chaos-makers, scaling co-op/solo bosses — grouped
by *behavior* so each forces a different reaction, in `07_NAME_ENEMIES_WEAPONS.md`. Essentials:

- Constant little **pests** to chase and smash (easy fun, the solo loop's bread and butter).
- Occasional **thieves and bullies** that make the kid(s) react.
- Moving hazards: lava, conveyor belts, ice slides, low-gravity zones.
- **Bosses** that **scale solo↔co-op** (Robo-Worm, the Gobbler, Granny Centipede) — beatable by one
  worm, more fun with two. The strongest differentiator, and a daily solo staple, not just a co-op
  moment.
- A giant **Boss Food** to race toward; whoever eats it evolves.

## Arena is the mode (no menus)

The kid never picks rules from a menu — they tap a picture of a place. The arena bundles its rules
invisibly. Green Hill (race-y), Volcano (chaotic lava), Ice (sliding), Factory (conveyors), Space
Station (low-gravity). One tap, no reading. The picture *is* the game mode.

## Replacing scores (the kids ignore numbers)

- **Score becomes size and evolution.** The bigger, more-transformed worm is visibly winning.
- **XP becomes Evolution.** Tiny → Fast → Spiky → Dragon → Mega — visible transformations, no levels.
- **Currency becomes a Sticker Book.** Find things, unlock things, fill pages. No inventory.
- **Match result becomes a victory moment** — and **a loss becomes a comedic moment**, never a
  number or badge.
- Hidden stats (wins, streaks) live on a separate **parent screen** only.

## Combat & destruction (Smash + Ryan's half + Powder Toy)

Players want to fight, and Ryan specifically wants to **mix ingredients to cause reactions** (Powder
Toy), not be handed finished explosions. So combat is a **bounded-emergence** system: a few hidden
property tags (start at four: fire, gas, mass, bounce), items carry tags, combinations resolve by
pairwise rules, the kids think in items while the engine thinks in tags, every pair is enumerable
and safe-by-default. Full detail in `00_FAMILY_TRUTH.md` and `07_NAME_ENEMIES_WEAPONS.md`. Fairness
rules in `06_DESTRUCTION_AND_FAIRNESS.md`. The boring standard kit (plain bomb/shield/speed/magnet)
is deleted.

The shape of it:
- **Body-based weapons** using the segments: tail-whip slam, spike mode, shed-skin trap, coil-dash.
- **Eating-based weapons** loaded by swallowing: chili breath (fire), bubble burp (gas), boulder
  wrecking-ball (mass), spicy-hiccup seed-spit — and these **combine** by their tags.
- **Wide-area, low-precision options favor whoever's behind** (invisible catch-up).
- **Absurd transformation powerups** (Slinky, Balloon, Train, Magneto) and **arena-changers**
  (gravity flip, lights-out, food rain) over generic pickups.
- **Ultimate** per worm, flavored by body type: Mega Worm (tank), Sonic Coil (speed), Swarm Split
  (trickster). Fills partly from taking damage, so the kid getting hit charges faster.

Chloe is speed/precision/builder; Ryan is destruction/tank/mixer/boss-smasher. The boss is where
they both win at once — and the place each of them also plays solo.

## Growth that stays fun

Classic snake punishes growth. Invert it. Food increases mass, health, and attack strength — not
necessarily length. Let the player pick a direction: Longer / Faster / Tougher / More Boosts. Growth
is a visible power-up, never a handicap. (And remember: this in-round growth is fine to be
"stronger" — it's the *persistent solo grind* that must never carry power into versus.)

## Features worth designing in early

- **Family Tournament Mode** — track wins/streaks/championships locally (parent screen only).
- **Replay System** — store the last ~30 seconds.
- **Bot Fill** — an AI opponent for VERSUS when a sibling's away (solo PvE already exists as the main
  mode; this is specifically a versus stand-in).
- **LAN Hotspot Mode** — no router required, for the reunion fights. Designed for, not bolted on —
  but built at the content stage, since solo is the hook.

## Out of scope (deliberately)

Retention loops, monetization, ads, internet matchmaking, accounts, leaderboards, social features,
text-heavy menus, in-game numbers, and **any inventory/management screen**. None of it.
