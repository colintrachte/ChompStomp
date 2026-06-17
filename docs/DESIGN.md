# Chomp Stomp — Complete Design Document

> **READ Part 1 (Family Truth) first.** It overrides any other section where they disagree. The big
> correction: this is a **solo-first** game, not a versus-first one.

Everything needed to start building a local creature-brawler for two kids, with Claude.

---

## Document Overview

| Section | What it is |
|---|---|
| Part 1: Family Truth | The interview result. Solo-first, the fairness linchpin, karma, bounded-emergence combos, comedic losses, hierarchy. **Overrides everything below.** |
| Part 2: Game Design | The vision and design decisions. Body-is-the-scoreboard, Worm Builder, no-numbers, arena-as-mode, boss, combat, comeback. |
| Part 3: Technical Specification | Engine, performance budget, networking architecture, project structure, build order. |
| Part 4: Build Prompts | Ready-to-paste prompts for Claude/Claude Code, stage by stage. |
| Part 5: Art & Asset Spec | Art spec + the Worm Builder, driven by Chloe's drawing. Her most-wanted feature. |
| Part 6: Borrowed Code & References | Vetted open-source to learn from/borrow; LAN-discovery pattern. |
| Part 7: Destruction Layer & Fair Fight | Ryan's half + the rules that keep it fun for the kid who's behind. |
| Part 8: Names, Enemies, Weapons & Powerups | Name candidates, enemy bestiary, weapons/powerups — all "being a worm." |
| Part 9: Care & Karma Layer | Creature-feeding, garden, blueprints, the persistence loop. |
| Part 10: Asset Generation | Cheap procedural sound (bfxr2) + Claude-generated flat SVG art. |
| Part 11: Android Export Setup | Getting from nothing to "APK running on the tablet" in one sitting. |

## The ideas the whole thing rests on

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
2. Open Claude Code in the project folder. Drop all docs in, **Part 1 (Family Truth) first**.
3. Paste the system/context prompt from the Build Prompts section.
4. Work the stages in the **new** order: skeleton → **Worm Builder (to the kids week one)** →
   **the SOLO hook (eat/grow/fight/boss/unlock — this is "done enough")** → combination combat →
   then networking/versus → then the karma/secret layer.
5. **Networking is no longer first.** The solo hook doesn't need it, and it's the scariest part —
   so the kids are playing a fun game long before two tablets have to talk.
6. Test on the real tablet(s) after every stage.

## The one rule that saves you

Build the **hook** first, not the network. The daily loop is solo, so the first milestone is one
worm that's fun to play alone against the world. Prove *that* beats Slither.io before spending a
single weekend on LAN. Networking is real work, but it's now content-stage risk, not
does-this-project-even-exist risk.

---

## Part 1: Family Truth (read this first; it overrides the rest)

This is the result of an interview about what these two specific kids actually want.
Where it disagrees with any other section, **this one wins**. The original package was a strong
generic design; this is that design corrected to the real family. The deltas below are not
preferences — they reorder the build.

### The two kids (the real ones, not the archetypes)

- **Chloe, 10.** Better balanced, more attentive, the precision/builder kid. Also **bossy**, and
  **hates losing to Ryan**. The bored-of-Slither.io kid — she has outgrown aimless solo slither.
  Her headline want is **building her own worm** (the drawing).
- **Ryan, 9.** The baby. Won't touch Slither.io at all. Loves **Minecraft, Sonic, and Powder Toy**.
  The key insight: Powder Toy means he doesn't want *explosions handed to him* — he wants
  **ingredients he combines to cause reactions**. Discovery, not a finished toy. He loves **funny**.

Chloe hating to lose is treated as **a character flaw to correct, not a constraint to design around.**
The game is, among other things, a tool for teaching grace — but it teaches by how the world
behaves, never by lecturing (see "karma," below).

### The single biggest correction: the game is SOLO-first

Every original doc assumes the couch-versus brawl is the spine and solo is a fallback.
**That is backwards for this family.**

- **Daily loop = SOLO PvE.** Each kid mostly plays **alone**: explore, eat, grow, fight NPC
  baddies, beat a boss, unlock something, grow their creature. This is the thing worth opening
  the tablet for when the sibling isn't around. **This is what must beat Slither.io** — not the
  versus mode. Chloe is bored of Slither.io precisely because solo slither has no bosses, no
  progression, nothing to build toward. The solo loop is the hook.
- **Reunion loop = VERSUS.** When both kids want to, they connect over the hotspot and brawl,
  bringing the worms and tools they each built up solo. Occasional, special, personal.
- **Co-op loop = SHARED BOSSES.** Sometimes they team on a big boss. The no-one-loses space.

Consequence: **networking is no longer on the critical path to the first thing they love.**
The scariest engineering (LAN/hotspot) moves *later*. The first milestone is one worm, solo,
fighting a boss and unlocking something, fun enough to replay alone.

Honest ratio from the parent: they will **mostly play alone**, build up their stuff, and come
together to fight **sometimes**. Treat solo PvE as the primary mode and a first-class citizen
from day one, not a bot-fill afterthought.

### The fairness linchpin: grind buys BREADTH, never HEIGHT

This is the rule that makes the whole solo-first design safe, and it is **ironclad**.

The contradiction it resolves: solo play must *feel* like it builds you up (or why grind?),
but the versus fight must be fair no matter who put in more hours (or solo becomes a
pay-to-win treadmill between siblings — explicitly refused).

**Resolution (the Smash Bros principle): solo progression unlocks VARIETY, never POWER.**
Unlocking a Smash character gives you a new *way to play*, not a *stronger* character. The
roster is horizontal. Everything you grind for is a **sidegrade**.

- Solo play unlocks **blueprints** — new worm parts, shapes, ability-*flavors*, creature forms,
  comedic stuff. Every unlock is a **lateral choice, not a stat boost.**
- **No persistent stat growth carries into versus.** The creature you grew and the parts you
  unlocked never make your versus worm hit harder, move faster, or take more hits than baseline.
  In a versus match **both worms start equal** and grow *only* from what happens *in that match*
  (in-round eating, in-round ultimate meter). Solo build-up changes **what your worm is**, never
  **how strong it starts**.
- **Power progression lives entirely in PvE.** Solo and co-op boss fights *can* get easier as you
  unlock things — there's no sibling to be unfair to. Only **variety** crosses into PvP.
  Clean line: **grinding makes you stronger against the world, only broader against your sibling.**

#### THE FAIRNESS FILTER (a hard guardrail, alongside the no-reading test)

> For any unlockable: **does grinding this make you stronger in a fight, or just different?**
> If *stronger* → it cannot be grind-locked; it must be available to both kids equally, in-match.
> If *different* → it can be a solo unlock.

#### The diligent-kid tension (acknowledged on purpose)

Fair-to-the-lazy-kid can feel unfair-to-the-diligent-kid: someday the kid who ground fifty boss
fights will want that to *translate into a win*. The game's answer: **your effort shows up as a
worm nobody else has and a toolbox full of options you chose — it is visible, personal, and
yours — it just doesn't tilt the fight.** The reward for grinding is identity and mastery of more
tools, not a damage number. (This is also the mirror of correcting Chloe: we don't enable the
bossy kid's need to win, and we don't enable the grinder's need to win either — both learn the
fight is about the moment, not the ledger.)

### Catch-up: invisible rubber-band AND karma, together

Both, not either/or.

- **Invisible catch-up stays invisible.** The trailing worm quietly gets the bigger, lower-precision,
  more satisfying toys. Never a visible "baby setting." Chloe must never see a handicap to
  resent. This is unchanged from the original design and still correct.
- **Karma layer (new framing).** Good habits — cooperation, care, tending — quietly compound into
  advantages that **surface during play without ever being labeled a reward for being good.** Like
  real karma: there is no notification, no "you were nice, here's a prize." The kid just experiences
  "huh, the garden rained food this round" or "Ryan's companion showed up and did something cool" —
  consequences that trace back to tending and cooperating but read as *just how the world works*.
  The habit is taught by the world **reliably** rewarding it, never by anyone pointing it out.
  - **The karma layer's outputs LEAK INTO THE BRAWL.** A hatched companion appears mid-match; a
    bloomed garden seeds the arena. The secret layer does **not** stay quarantined on the Home screen.
  - **Karma leaks DELIGHT, never POWER** (fairness filter still applies). A garden bloom that rains
    food rains it **for both kids equally**. A companion is *fun*, not an *advantage*. The trace is
    **fully ambient** — the cause→effect link is for the kids to feel over time, never surfaced.

### Loss must be possible, frequent-ish, and HILARIOUS

A total loss is on the table — Chloe must be able to genuinely, visibly lose. But it lands as
**funny, never unfair** (the Smash "blasted off the stage" move: losing is a spectacle you laugh
at, not a verdict on you). This is the mechanism that teaches grace with zero words: when loss is
a slot machine of funny, Chloe laughs instead of stewing, and Ryan (who loves funny) is delighted
to be on the receiving end.

**Many comedic losses, not one** (Ryan loves funny; Smash stays funny because there are dozens of
ways to go down). This is a **content category**, fired situationally and semi-randomly so the loss
is a surprise each time. Starter bank:
- Eaten-and-popped-out (winner Mega-Munches loser, loser pops out the far end dizzy)
- Launched-off-screen with a comedy whistle (Team-Rocket "blasting off again")
- Deflated to a tiny confused noodle while the winner balloons up
- Turned into a confused balloon that drifts off
- Segments scattered like dropped beads
- Flattened-then-reinflates with a pop

Grow this bank over time. The loss animation is something it's *fun to be on the receiving end of.*

### The combination system: bounded emergence

Ryan gets Powder Toy's *feeling* (mix things, get surprised, nobody memorized a recipe book)
without Powder Toy's *reality* (open chemistry, infinite edge cases, broken states).

**Emergent in combination, bounded in primitives.**

- A small fixed set of **property tags** — **start at 4**, cap at 5-6 ever. The boundary *is* this
  number. Recommended starting four: `fire`, `gas`, `mass`, `bounce`. (Candidates for the 5th/6th
  if the kids are hungry: `electric`, `sticky`.) **You can always add a tag; you can never cleanly
  remove one once a beloved combo uses it. Start tight.**
- Each ingredient/powerup carries one or two tags. Chili breath = `fire`. Bubble burp = `gas`.
  Boulder swallow = `mass`. Booster = `bounce`.
- Combinations resolve by **pairwise rules on tags**, not on specific items: `fire + gas` → big
  blast; `mass + bounce` → wrecking ball; etc. Because rules are on 4-6 tags, the **entire
  interaction grid is small and fully enumerable** — put every pair on one page, eyeball it for
  "is any of these unfun or broken?" before it ships.
- **The kids think in ITEMS; the engine thinks in TAGS.** Ryan doesn't know "fire+gas"; he knows
  "I ate the pepper then the fizzy drink and the screen exploded." Same magic, closed grid
  underneath. The items are the interface; the tags are hidden. → simple on its face, emergent in
  feel, fully controlled in fact.
- **Safety valve:** every unhandled pair has a default ("both effects just happen, no special
  combo"). There is **never a broken state** — worst case is "that combo was boring," never "that
  combo crashed." This caps the boundless-error risk.

### Solo progression: BOTH creature-feeding AND boss-womping

Two parallel progression flavors, both wanted:

1. **Boss-womping (fast loop):** beat an NPC baddie wave or a boss → directly unlock a part /
   blueprint, Sonic/Minecraft style. Immediate, punchy, the daily satisfaction.
2. **Creature-feeding (patient loop):** across rounds, what you collect feeds a creature; what you
   feed decides what it becomes (metal→robot/Ryan, leaves→animal/Chloe, seeds→plant); it hatches
   into a rare part or companion over many rounds — outputs are variety/delight, never versus power.

Both feed the same blueprint pool. Both are subject to the fairness filter. Boss-womping is the
hook that competes with Slither.io *today*; creature-feeding is the depth that keeps them past the
first week.

### Hierarchy (do not lose this)

**Brainless beat-em-up / eat-everything is the DOMINANT gameplay** — that's the hook, the thing
that competes with Slither.io and Sonic. The secret/karma/creature layer is **pervasive but
recessive**: always present, never the thing on screen, never gating the core fun. A kid who only
ever brawls has a complete, great game. A kid who also tends gets a quietly richer one.

### Hardware: a budget to spend carefully, not a floor to fear

Real hardware is a 12" Android tablet, octa-core, ~Android 16, lots of RAM, 2000×1200 FHD. The
original "potato-tier 2GB/Android-8" floor does NOT apply. But treat the headroom as a **budget to
spend deliberately**, not license to be sloppy:
- **Keep:** fixed 30 Hz deterministic sim (it's for networking correctness, not performance), flat
  silhouette-readable art (an aesthetic + legibility rule, not a compromise).
- **Spend selectively:** allow shaders/particles **for the spectacle beats specifically** — boss
  death, the Mega ultimate, the victory moment, the big comedic losses. Frugal everywhere else.
  Spend the budget on "did you see that?!", nowhere else.

### Bosses must scale: soloable AND co-opable

Because solo is primary but they sometimes team up, **every boss must be beatable by one worm and
more fun with two.** Health/attack scale with player count; telegraphs must be readable by a single
kid alone.

### What "done enough" means

**Competitive with Slither.io** — specifically, the *solo* loop fun enough that Chloe would pick it
over the game she's bored of. That milestone is **one worm, solo, eat/grow/evolve, fight baddies,
beat a boss, unlock a part** — smooth, on the couch. Versus, creature, garden, blueprints-at-scale
all come *after* that line. The karma/secret data model is designed in from the start; the secret
features are built only once the solo hook beats the baseline.

---

## Part 2: Game Design (v2, solo-first)

### Vision

Build the fastest, funniest, most replayable worm game for two specific kids. Optimize for a
**solo loop worth opening the tablet for alone**, with an occasional couch-versus reunion and the
sometimes-co-op boss fight. Short rounds, memorable moments, over graphics. The test for every
decision: **could a kid who can't read tell who's winning by looking at the screen for three
seconds?** — and now also: **would Chloe, bored of Slither.io, replay this ALONE?**

This is not a Snake clone. It's a snake-based creature-brawler that borrows from Sonic (speed feels
good), Mario Kart (catch-up keeps it close), Smash Bros (players want to fight, and losing is
funny), Minecraft (build freely, no inventory tedium), and Powder Toy (mix ingredients, discover
reactions). Snake movement is the foundation, not the whole game.

### Constraints that shape everything

Advantages, not limitations. Design around them on purpose.

- Family-only software. Two primary users. No third audience.
- You control the hardware and network. No app store, accounts, monetization, analytics.
- Solo PvE is the daily driver; LAN/hotspot versus is the occasional reunion.
- Hardware is a strong modern tablet — the old "potato-tier" floor does NOT apply, but treat the
  headroom as a budget to spend deliberately (flat art + 30 Hz sim kept; shaders/particles spent
  only on spectacle beats).
- The kids ignore numbers, words, XP bars, currencies, and menus. Everything communicates through
  size, color, animation, sound, and transformation — the worm's own body shows the state, the way
  Smash and Mario Kart do.

### The spine: the body shows the state (no crown, no scoreboard)

Smash, Mario Kart, and Sonic never put a crown or "you're winning" badge on screen — the thing the
player is already looking at tells the whole story. So here: **who's doing well is shown by the worm
itself — bigger, more evolved, spikier, transformed.** A kid glancing sees a giant Dragon worm
bullying a small one and knows instantly who's ahead. No crown required, because the mega-worm
already *is* the crown.

No persistent "leader" status during play, deliberately — Smash isn't about holding first place,
it's about the next knockout. The fun is the moment-to-moment scramble, not a guarded status.

#### How a non-reader knows who's winning
Through **size and evolution.** Eating and surviving grow and transform your worm through visible
stages (Tiny, Fast, Spiky, Dragon, Mega). That growth *is* the scoreboard — readable at a glance.

#### How a round ends legibly — both winning AND losing are moments
Not with an object, with a **moment.** At time-up (or knockout), the bigger/more-evolved worm gets
a victory animation, the screen, and the music — Smash's "GAME!" zoom.

**And losing is its own moment, on purpose hilarious.** A total loss must be possible — Chloe must
be able to genuinely, visibly lose — but it lands as *funny, never unfair*: the Smash "blasted off
the stage" principle. There is a **bank of comedic loss animations** (eaten-and-popped-out,
launched-off-screen, deflated-to-noodle, balloon-drift, scattered-beads, flattened-reinflate, and
more over time), fired situationally and semi-randomly so the loss surprises every time. Ryan loves
funny; a funny loss teaches Chloe grace with zero words. This is a content category, not one asset.

#### How the trailing kid stays in it
Invisibly, the Mario Kart / Smash way — not a target to chase. The trailing kid's powerups skew to
the big satisfying destruction toys, and a karma layer quietly leaks delight into the brawl for kids
who tend and cooperate.

### Catch-up is invisible AND karmic (both)

- **Invisible rubber-band:** the trailing worm gets the bigger, lower-precision, more satisfying
  toys. Never a visible "baby setting." Chloe must never see a handicap to resent.
- **Karma:** care and cooperation quietly compound into delight that surfaces during play — a
  hatched companion appears mid-brawl, a bloomed garden rains food (for both kids equally). Never
  labeled a reward for being good; reads as "just how the world works." **Leaks delight, never
  power** (fairness filter applies). The cause→effect link is never surfaced.

### The secret/care layer: pervasive but recessive (re-scoped)

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
**variety/delight, never versus power.**

### The Worm Builder (a core pillar, from Chloe's design)

The end user — Chloe — spent days drawing what she wants, and the headline feature is **building her
own worm**: choosing the color, shape, and face of each segment. A core pillar.

- The worm is **chunky and segmented**, not a thin line. The kids call it a "worm," not a snake.
- A no-reading builder lets a kid tap per-segment color (~14-swatch palette), per-segment shape
  (rectangle, oval, circle, diamond, pentagon, triangle, star), and a head face. It also offers
  **visible body types** — speedy, or heavy/spiky/armored/robot — so a kid chooses to be the fast
  one (Chloe) or the tanky bruiser (Ryan) on purpose. Body type is a playstyle **choice and a
  sidegrade, never a power tier** (fairness filter).
- The worm they build is the worm they play. Saves locally per kid.
- No networking — ships to the kids in week one as a morale and feedback win.

### Core design pillars (v2)

1. **Solo-first fun.** The daily loop is one kid alone vs. the world, and it must beat Slither.io.
2. **60-second fun.** Rounds are 1-3 minutes, never long slither sessions.
3. **Constant interaction.** The arena is the third force — pests, thieves, bullies, bosses — so a
   solo kid always has something to do and a versus arena never feels empty.
4. **Grind buys breadth, never height.** Solo unlocks variety; versus worms start equal.
5. **Comeback built in, invisibly.** Catch-up is the Mario Kart / Smash way (trailing kid gets the
   best toys) plus the karma leak — never a visible "baby setting."
6. **Spectacular moments, win OR lose.** Boss explosions, mega-worm rampages, last-second size
   swings — and a bank of hilarious losses, because the funny loss is the grace lesson.

### The arena is the third player

Two worms (or one worm) alone isn't enough interaction. The arena is the opponent that fills the
space. Essentials:

- Constant little **pests** to chase and smash (easy fun, the solo loop's bread and butter).
- Occasional **thieves and bullies** that make the kid(s) react.
- Moving hazards: lava, conveyor belts, ice slides, low-gravity zones.
- **Bosses** that **scale solo↔co-op** (Robo-Worm, the Gobbler, Granny Centipede) — beatable by one
  worm, more fun with two. The strongest differentiator, and a daily solo staple, not just a co-op
  moment.
- A giant **Boss Food** to race toward; whoever eats it evolves.

### Arena is the mode (no menus)

The kid never picks rules from a menu — they tap a picture of a place. The arena bundles its rules
invisibly. Green Hill (race-y), Volcano (chaotic lava), Ice (sliding), Factory (conveyors), Space
Station (low-gravity). One tap, no reading. The picture *is* the game mode.

### Replacing scores (the kids ignore numbers)

- **Score becomes size and evolution.** The bigger, more-transformed worm is visibly winning.
- **XP becomes Evolution.** Tiny → Fast → Spiky → Dragon → Mega — visible transformations, no levels.
- **Currency becomes a Sticker Book.** Find things, unlock things, fill pages. No inventory.
- **Match result becomes a victory moment** — and **a loss becomes a comedic moment**, never a
  number or badge.
- Hidden stats (wins, streaks) live on a separate **parent screen** only.

### Combat & destruction (Smash + Ryan's half + Powder Toy)

Players want to fight, and Ryan specifically wants to **mix ingredients to cause reactions** (Powder
Toy), not be handed finished explosions. So combat is a **bounded-emergence** system: a few hidden
property tags (start at four: fire, gas, mass, bounce), items carry tags, combinations resolve by
pairwise rules, the kids think in items while the engine thinks in tags, every pair is enumerable
and safe-by-default. The boring standard kit (plain bomb/shield/speed/magnet) is deleted.

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

### Growth that stays fun

Classic snake punishes growth. Invert it. Food increases mass, health, and attack strength — not
necessarily length. Let the player pick a direction: Longer / Faster / Tougher / More Boosts. Growth
is a visible power-up, never a handicap. (And remember: this in-round growth is fine to be
"stronger" — it's the *persistent solo grind* that must never carry power into versus.)

### Features worth designing in early

- **Family Tournament Mode** — track wins/streaks/championships locally (parent screen only).
- **Replay System** — store the last ~30 seconds.
- **Bot Fill** — an AI opponent for VERSUS when a sibling's away (solo PvE already exists as the main
  mode; this is specifically a versus stand-in).
- **LAN Hotspot Mode** — no router required, for the reunion fights. Designed for, not bolted on —
  but built at the content stage, since solo is the hook.

### Out of scope (deliberately)

Retention loops, monetization, ads, internet matchmaking, accounts, leaderboards, social features,
text-heavy menus, in-game numbers, and **any inventory/management screen**. None of it.

---

## Part 3: Technical Specification (v2)

### Engine decision

**Godot 4 (latest stable 4.x), 2D only.** Do not use Godot 3.5 (end-of-life). GDScript for all
gameplay — it compiles into the project, no toolchain beyond the Godot editor, the path of least
resistance for a solo/family developer.

### Target hardware (the real device, not a potato)

The actual tablet is a strong modern device (12", octa-core, ~Android 16, lots of RAM, 2000×1200
FHD). The original "potato-tier 2 GB / Android 8 / Mali" floor does **NOT** apply.

- Android (recent), touch input, landscape, high-res FHD screen.
- Treat the performance headroom as a **budget to spend deliberately,** not license for sloppiness:
  keep the cheap-and-correct defaults, and splurge only on spectacle.

### Performance budget (deliberate spend, not survival)

| Constraint | Limit | Why it stays / how it changed |
|---|---|---|
| Max active objects | < 200 normal play | Still a good discipline; cheap and keeps the sim legible. Spectacle beats may briefly exceed via short-lived sprite effects. |
| Texture budget | generous | No longer VRAM-starved; still use one gameplay atlas for tidiness and few state changes. |
| Sprite atlas | Single atlas for gameplay sprites | One texture bind, minimal state changes. Kept. |
| Shaders | **Allowed ONLY for sanctioned spectacle beats** | boss death, Mega ultimate, victory moment, big comedic losses. Frugal everywhere else. |
| Particles | **Allowed ONLY for the same spectacle beats** | Otherwise still animated sprites. |
| Simulation tick | Fixed 30 Hz | Deterministic, cheap, network-friendly. **Kept — this is for correctness, not performance.** |
| Render | 30 or 60 FPS (decouple from sim) | Let render float, keep sim fixed. |
| Network rate | 10-20 packets/sec | Snake is low-velocity; interpolate. (Applies once networked — later.) |

Treat the *defaults* as gates and the *spectacle exceptions* as a small, named budget. If a feature
wants to break the budget outside the sanctioned beats, the feature changes.

### Architecture

#### Fixed-timestep simulation
Run game logic in `_physics_process` at 30 Hz (`Engine.physics_ticks_per_second = 30`). Render
interpolation handles smoothness. All gameplay state advances only on the sim tick — identical
behavior regardless of frame rate, which is also what makes networking sane later. **This holds for
solo play too:** the solo sim is the same fixed-step sim, just with no client attached.

#### Solo-first means the sim is single-player-capable from day one
The host-authoritative model below is how versus works. But the **same simulation runs solo** with
zero networking — one worm, NPC baddies, a boss, all on one device. Build the sim so "number of
human players" is a parameter: 1 (solo, no net), or 2 (host + client over LAN). NPC baddies and
bosses are driven by the sim identically in both cases. This is what lets the solo hook ship before
any networking exists, and lets bosses scale solo↔co-op cleanly.

#### Host / client LAN model (for the versus reunion — built later)
- One tablet is the **host** (authoritative), runs the full simulation.
- The other is the **client** — sends inputs, renders host state.
- Host owns all truth: worm positions, food, boss, powerups, collisions, who's bigger. Clients
  predict locally and reconcile.
- Godot high-level multiplayer (`MultiplayerAPI`) over ENet (UDP). Reliable channel for events,
  unreliable for the continuous position stream.
- **Fairness enforcement at match start:** both worms begin at equal baseline regardless of solo
  progression; only *variety* (chosen unlocked parts) carries in, never stats.

#### Networking detail (unchanged, applies at the versus stage)
- Host broadcasts snapshots at 10-20 Hz: each worm's head position, direction, length, evolution
  stage, boss state, active powerups.
- Client interpolates between snapshots (~100ms buffer).
- Client-side input prediction on its own worm; reconcile on snapshot.
- Tiny payload: quantize positions, send deltas where cheap.

#### Connection flow (two paths — built at the versus/hotspot stages)
1. **Router LAN** — host opens a port, UDP-broadcasts presence, client auto-discovers. No IP typing.
2. **Hotspot** — host tablet creates a Wi-Fi hotspot, client joins, same UDP discovery. The "no
   router at grandma's" mode. Zero-typing for the kids: host taps Start, client taps Join.

### Project structure

```
worm-wars/
  project.godot
  scenes/
    main_menu.tscn        # arena picker (pictures, no text)
    worm_builder.tscn     # Chloe's headline screen (ships first)
    arena_base.tscn
    arenas/
      green_hill.tscn
      volcano.tscn
      ice.tscn
    worm.tscn
    boss_worm.tscn
    powerup.tscn
    home.tscn             # the calm care/karma screen (later)
  scripts/
    sim/                  # all fixed-timestep gameplay logic (solo AND versus)
      game_state.gd       # authoritative state, 30 Hz, runs with 1 or 2 players
      worm.gd
      evolution.gd        # size/stage transformations, the visible scoreboard
      enemies.gd          # NPC baddies (the solo loop's third player)
      boss.gd             # scales solo <-> co-op
      powerups.gd
      combos.gd           # the bounded-emergence tag grid (4 tags, safe default)
      collision.gd
      loss_anims.gd       # the comedic-loss bank
    net/                  # built at the versus stage, not first
      net_host.gd
      net_client.gd
      discovery.gd        # UDP broadcast + hotspot handling
      snapshot.gd
    care/                 # the karma layer (latest)
      creature.gd         # diet-lean, care level, hatching -> blueprint
      garden.gd           # cooperation-gated bloom -> karma leak
      blueprints.gd       # unlocked variety options, never power
    ui/
      arena_picker.gd
      parent_screen.gd    # hidden stats, the only text-heavy screen
  assets/
    atlas.png
    audio/
  data/
    tournament.json       # local-only win/streak tracking
    home_state.json       # per-creature diet-lean + care level, unlocked blueprints, garden
                          # state. NO item inventory, ever.
```

### Build / dev environment

- Godot 4.x editor on the dev machine.
- Android export template installed; export APK, sideload to the tablet (no Play Store).
- The real tablet for testing — and a second tablet **when you reach the versus stage** for honest
  LAN/hotspot testing. The solo hook (the first milestone) needs only one device.
- Keep a `--server` headless launch flag for debugging the host from desktop later.

### Build order (v2 — de-risk by proving the HOOK first, not the network)

The v1 order put networking first because it assumed versus was the spine. It isn't — solo is. The
scary networking is real, but it's no longer on the path to the first thing the kids love. So:
**prove the solo hook beats Slither.io, THEN network.**

1. One worm moving on a fixed 30 Hz tick, rendered smoothly, on the real tablet. Confirm framerate.
2. **Worm Builder** — Chloe's headline want. Standalone, no networking. Put it in front of the kids
   this week.
3. Eating + evolution: food spawns, eating grows the worm through visible stages (Tiny → Fast →
   Spiky → Dragon → Mega). The body is the scoreboard.
4. **THE SOLO HOOK (the "done enough" milestone):** NPC pests + a soloable boss + beating it unlocks
   a blueprint, plus starter comedic-loss animations. Single device. Must beat Slither.io.
5. Combination combat: the bounded-emergence tag system (4 tags, enumerable grid, safe default).
6. Bestiary (behavioral variety) + arena picker + first full arena with a hazard. Re-confirm budget.
7. Creature-feeding (the patient solo progression; Home screen; persistent state; no inventory).
8. **Two worms over LAN** (the versus reunion) — host/client, UDP discovery, interpolation, input
   prediction. Equal-start fairness enforced. *Now* the second tablet is needed. Get it rock solid.
9. Versus polish: full comedic-loss bank, victory moment, invisible catch-up, ultimate meter.
10. Co-op boss mode (scale the soloable bosses up for two).
11. Hotspot path, tested on two real tablets with no router.
12. The Garden + karma leak (cooperation-gated bloom rains food into the brawl).
13. Polish: replay buffer, versus bot-fill, sticker book, parent screen, tournament tracking.

Steps 1-4 are the new "does this project exist" risk — and none of them need networking. Step 8 is
the old scary part, now safely after the kids already love the game.

---

## Part 4: Build Prompts for Claude (v2, solo-first)

Ready-to-paste prompts for building the game with Claude (Claude Code recommended — it writes the
real project files and runs the Godot CLI). Work through them in order.

> **The order changed from v1.** This is a **solo-first** game. The daily hook is one kid playing
> alone against the world; versus is the occasional reunion. So the **solo loop is built before
> networking**, and "done enough" = the solo loop beats Slither.io. Networking moves to the content
> stages, where it belongs, because it's the scariest part and the hook doesn't depend on it.

### How to use these

- **Claude Code** is the right tool — it creates the Godot tree, writes GDScript, iterates. Say
  "I'm using Claude Code" so it writes files instead of pasting code into chat.
- Feed it Part 1 (Family Truth) first, then the foundation docs.
- Do the prompts **in order**. The first milestone that matters is the **solo hook** (Stage 3).
- After each stage, test on a real tablet before moving on.

---

### System prompt / project context (set once)

> You are helping me build a local creature-brawler for my two kids (Chloe, 10 — precision/builder;
> Ryan, 9 — loves Minecraft/Sonic/Powder Toy and combining ingredients to cause reactions), in
> Godot 4 (GDScript, 2D only). **Read the Family Truth section first — it overrides every other
> doc.** The kids call it a "worm," not a snake; the body is chunky and segmented, not a thin line
> — use "worm" everywhere they can see.
>
> **This game is SOLO-FIRST.** The daily loop is one kid alone: eat, grow, fight NPC baddies, beat a
> boss, unlock a part. That loop is the hook and must beat Slither.io. Versus over LAN is an
> occasional reunion event, built later. Do not treat single-player as a fallback — it is the
> primary mode and a first-class citizen from day one.
>
> **The fairness linchpin (ironclad):** solo progression unlocks VARIETY, never POWER. Grinding
> bosses/creatures unlocks new parts and tools (sidegrades), never a versus worm that hits harder,
> moves faster, or takes more hits than baseline. In a versus match both worms start equal and grow
> only from in-match events. Power progression lives only in PvE; only variety crosses into PvP.
> Apply the FAIRNESS FILTER to every unlockable: does grinding it make you stronger in a fight, or
> just different? If stronger, it cannot be grind-locked.
>
> Non-negotiables: fixed 30 Hz simulation; under 200 active objects in normal play; single sprite
> atlas for gameplay; the kids can't read, so everything communicates through size, color,
> animation, sound, and transformation — the worm's own body shows who's winning, the way Smash and
> Mario Kart do, with no scoreboard and no "winner" badge. No scores, XP bars, currencies, or text
> menus in gameplay. The hardware is a strong modern tablet, so the "potato-tier" floor does NOT
> apply — but treat the headroom as a budget to spend deliberately: keep flat silhouette-readable
> art and the 30 Hz sim, and spend shaders/particles ONLY on spectacle beats (boss death, Mega
> ultimate, victory moment, big comedic losses), frugal everywhere else.
>
> For assets: generate graphics as flat SVG primitives I can tint and combine in code (layered
> pieces — body, eyes, mouth, spikes — not finished art), and use the bfxr2 / sfxr procedural
> approach for sound. Never use paid AI asset generation; keep audio offline-capable. Ask me before
> introducing any dependency or deviating from the spec. Do not use "/*" style comments in code.

---

### Stage 1 — Project skeleton + one worm at 30 Hz

> Set up the Godot 4 project skeleton matching the technical spec. Then implement one worm:
> touch/swipe steering, segment-following body, movement that advances only on a fixed 30 Hz physics
> tick (Engine.physics_ticks_per_second = 30), with render interpolation so it looks smooth at 60
> FPS. Placeholder colored rectangles for sprites. Give me a single test scene I can export to the
> Android tablet, and tell me exactly how to export and sideload the APK. Goal: confirm the worm
> moves smoothly on the real tablet before building anything else.

### Stage 1.5 — The Worm Builder (ship this to the kids FIRST)

> Build the Worm Builder screen per the Art & Asset Spec. No-reading, tap-only: tap a segment
> to select it, tap a color from a ~14-swatch palette to paint it, tap a shape (rectangle, oval,
> circle, diamond, pentagon, triangle, star) to change its form, tap a face for the head, big +/−
> icon buttons to add/remove segments. Also offer a few visible body types (speedy, or
> heavy/spiky/armored/robot) — pictures, never text or stats — so one kid can choose fast and
> another tanky. IMPORTANT: body types are a playstyle CHOICE, a sidegrade, never a power tier.
> Tint one flat shape sprite per shape in code from the fixed palette. Save each kid's worm locally.
> No networking — runs standalone so I can put it in front of my kids this week. Make it juicy:
> satisfying taps, sounds, a worm that wiggles. This is the feature they care about most; give it
> real polish.

### Stage 2 — Eating & evolution (the body is the scoreboard)

> Implement eating and evolution, the spine. Food (leaf, flower, apple — Chloe's three) spawns; a
> worm eats by touching it. Eating grows the worm and advances it through visible stages: Tiny →
> Fast → Spiky → Dragon → Mega, each a clear sprite and size change carrying the kid's chosen colors
> and face through every stage. NO numbers, no XP bar, no meter — the worm's own size and form is
> the only indicator. This stage is single-player for now; evolution state is authoritative (it'll
> be host state once networking lands). The point: a glance tells you who's doing well, nothing
> bolted on top.

### Stage 3 — THE SOLO HOOK: baddies + a boss + an unlock ("done enough" milestone)

> This is the milestone that must beat Slither.io. Build a complete single-player loop in one arena:
> (1) waves of simple NPC **pests** to chase and smash (Crumbs, Hoppers, Stink Beetles) — easy,
> satisfying, screen-filling fun; (2) a **boss** that a single worm can beat — destructible segments,
> telegraphed attacks readable by one kid alone, scales up later for co-op (design the scaling hook
> now: every boss is soloable AND co-opable); (3) beating the boss **unlocks a blueprint** — a new
> worm part that appears as a new option in the Worm Builder, permanently and freely (Creative-mode
> style). CRITICAL fairness rule: the unlocked part is a VARIETY sidegrade, never a power boost —
> apply the fairness filter. Add a couple of starter **comedic loss** animations for when the worm
> is beaten (eaten-and-popped-out, launched-off-screen) — losing must be funny, never grim. This
> whole loop is solo and needs no networking. The test: would Chloe, bored of Slither.io, replay
> this alone?

### Stage 4 — Combination combat (Ryan's Powder-Toy hook: bounded emergence)

> Implement the combination weapon system. Design it as BOUNDED EMERGENCE: a small fixed set of
> hidden property TAGS — start with exactly four: fire, gas, mass, bounce — and each
> weapon/ingredient carries one or two tags. Combinations resolve by pairwise rules on tags, not on
> specific items (e.g. fire+gas → big blast, mass+bounce → wrecking ball). The kids think in ITEMS
> (eat the pepper, then the fizzy drink); the engine thinks in TAGS. Build the full pairwise
> interaction grid as a single data table I can read on one page and eyeball for unfun/broken pairs.
> HARD RULE: every unhandled pair has a safe default (both effects just happen, no special combo) so
> there is never a broken/crashing state — worst case is "boring," never "broken." Implement the
> starter items per the Names/Enemies/Weapons section, each as a clear icon/shape, no text.
> Wide-area low-precision options skew to the trailing worm (invisible catch-up — never label it).
> Do NOT reintroduce the deleted generic kit (plain bomb/shield/speed/magnet). All explosions are
> sprite-frame animations, never particle systems (except you may spend a particle/shader splurge on
> the single biggest spectacle beat). Keep the tag count at four until the kids are clearly hungry.

### Stage 5 — The bestiary (behavioral variety) + arena picker

> Add the full enemy roster grouped by BEHAVIOR so each forces a different reaction: pests (already
> started), a thief (Gulls that snatch food), a bully (Boulder Bugs, eaten only from the soft back
> end), a chaos-maker (Gloop or Magnet Mites). Spawn pests frequently, thieves/bullies occasionally.
> Then build the main menu as an arena PICKER: the kid taps a picture of a place, no text, no rule
> selection — the arena bundles its rules invisibly. Build the first proper arena (Green Hill):
> loops, ramps, Sonic-style speed pads, one moving hazard. Confirm we're under 200 active objects
> and on the single atlas. Re-confirm framerate on the tablet.

### Stage 6 — More creature-feeding progression (the patient loop, still solo)

> Begin the patient progression. Add a calm Home screen (a place, not a menu) backed by persistent
> data/home_state.json storing, per kid, each creature's care level and diet-lean and which
> blueprints are unlocked — NEVER an item list, NO inventory of any kind. At round end, collected
> food is fed into the creature in ONE tap; what you feed determines what it becomes via a visible
> diet-lean: metal/scrap/electronics → ROBOT (Ryan), leaves/fruit/bugs → ANIMAL (Chloe),
> seeds/flowers → PLANT. The lean is a DRIFT not a lock — one wrong feed never ruins days of work.
> Care level rises when fed, slowly falls when ignored; the creature SLEEPS, never dies. Hatching
> unlocks a rare blueprint (a part/companion). FAIRNESS FILTER applies: everything the creature
> yields is VARIETY, never versus power. This runs alongside boss-womping (Stage 3) — both feed the
> same blueprint pool; boss-womping is the fast loop, creature-feeding the patient one. Still solo;
> no networking yet.

### Stage 7 — Two worms over LAN (the reunion mode — NOW we network)

> Now add two-player versus over LAN, host/client per the technical spec. Base LAN discovery on
> the GodotEasyLAN broadcast pattern: host broadcasts its IP plus a room code over UDP to the
> subnet broadcast address; client listens, lists hosts, connects via Godot high-level multiplayer
> using the broadcast IP — nobody types an IP. Account for the 255.255.255.0 subnet requirement and
> known Android LAN quirks; we test on real tablets. Implement: (1) ENet host/client, host
> authoritative over all state; (2) host broadcasts snapshots at 15 Hz of each worm's head
> position, direction, length, evolution stage; (3) client interpolates with a ~100ms buffer;
> (4) client-side input prediction on its own worm with reconciliation. Keep the payload tiny.
> CRITICAL fairness enforcement: when a versus match starts, BOTH worms start at equal baseline
> power regardless of solo progression — the only things that carry in are VARIETY (which unlocked
> parts/tools each kid chose), never stats. Both worms must move smoothly on both tablets with no
> rubber-banding on the local worm. Walk me through testing with two real tablets. Get this rock
> solid before adding versus content.

### Stage 8 — Versus polish: comedic losses + victory moment + invisible catch-up

> Flesh out the versus reunion. Add the full comedic-loss BANK (eaten, launched, deflated-to-noodle,
> balloon-drift, scattered-beads, flattened-reinflate) fired situationally and semi-randomly so loss
> is a funny surprise every time — Ryan loves funny, and a funny loss teaches Chloe grace with no
> words. Add the victory MOMENT (winning worm's animation, screen, music — like Smash's "GAME!"
> zoom), no scoreboard, no badge, no persistent leader status during the round. Implement the
> invisible catch-up: the trailing worm's powerup table skews to the big, low-precision, satisfying
> toys — never a visible setting. Add the Ultimate meter that fills from eating, landing hits, AND
> taking damage (the kid getting hit charges faster — invisible catch-up); each body type flavors its
> ultimate: Mega Worm (tank), Sonic Coil (speed), Swarm Split (trickster). The fairness test, every
> time: would the kid who lost the last two rounds still want a third?

### Stage 9 — Co-op boss mode (shared bosses, where nobody loses)

> Add co-op: both kids team on a boss together over LAN. Reuse the soloable bosses from Stage 3/5
> but SCALE them up for two worms (more health, more/faster telegraphed attacks) — every boss is
> soloable AND co-opable, so this is scaling existing encounters, not new ones. Dropping the boss
> rewards BOTH players (a blueprint unlock or shared food burst). This is the no-one-loses space and
> the place power progression is allowed (PvE only). Make it a "did you see that?!" moment through
> animation and sound — this is where you may spend the spectacle budget. Stay within the object
> budget; boss + segments count against the 200.

### Stage 10 — Hotspot mode (no router)

> Implement the no-router path: the host tablet creates a Wi-Fi hotspot, the client joins it, and
> the Stage 7 UDP discovery finds the host. Testable with no router present. Walk me through testing
> on two real tablets away from my home network. Handle failure cases (hotspot not up yet, client on
> wrong network) with kid-friendly VISUAL feedback, not error text.

### Stage 11 — The Garden + karma leak (cooperation, pervasive but recessive)

> Add the Garden. A shared plot on the Home screen; both kids plant/water with one tap each, no
> management. It only blooms if BOTH kids contributed since the last bloom — cooperation gated. A
> bloom does NOT stay quarantined on Home: it LEAKS INTO THE BRAWL — it rains rare food into the
> next match, FOR BOTH KIDS EQUALLY (karma leaks delight, never power; fairness filter applies).
> Also let a hatched companion appear mid-match as ambient delight, not advantage. The cause→effect
> link is NEVER surfaced — no notification, no "you cooperated, here's a reward." It just happens;
> the kids feel the pattern over time. This is the karma layer: the world reliably rewards care and
> cooperation without ever saying so. Keep it pervasive but recessive — the brawl is still the
> dominant on-screen game.

### Stage 12 — Polish layer

> Add the remaining polish, each a separate small task: (1) a replay buffer storing the last ~30
> seconds; (2) bot fill so a single kid can play VERSUS an AI worm when the sibling's away (note:
> solo PvE already exists from Stage 3 — this is specifically an AI opponent for the versus mode);
> (3) a sticker book that fills as the kids discover worm parts and arenas (collection, no currency,
> no inventory); (4) a hidden parent screen — the one place text is allowed — showing wins, streaks,
> tournament history in data/tournament.json. Keep all of it off the kids' gameplay screens.

---

### Ongoing guardrail prompt (paste when Claude drifts)

> Check this against the spec before continuing:
> - Still under 200 active objects, single atlas, no gameplay shaders/particles except the sanctioned
>   spectacle beats, fixed 30 Hz sim, host-authoritative (once networked)?
> - Everything on the kids' screen readable by a non-reader through size/color/animation/sound alone,
>   no numbers or text menus?
> - **FAIRNESS FILTER:** does anything a kid unlocked through solo grinding make their VERSUS worm
>   stronger (more damage/speed/health/start-size) rather than just different? If yes, that's a
>   violation — solo unlocks must be variety sidegrades; versus worms start equal. Fix it.
> - **Catch-up test:** would the kid who lost the last two rounds still want a third — does the
>   trailing kid get the most fun toys, with all catch-up invisible?
> - **Karma test:** do care/cooperation outputs leak DELIGHT into the brawl (never power), with the
>   cause→effect link never surfaced?
> - **Hierarchy test:** is the brainless eat-everything brawl still the dominant on-screen game, with
>   the creature/garden/karma layer present but recessive?
> If any answer is wrong, fix it before adding more.

---

## Part 5: Art & Asset Spec (The Worm Builder)

This spec is driven by Chloe's design drawing. She spent days on it, and it is the clearest statement of what the kids actually want. Her headline request is not the gameplay — it's **building their own worm**. That feature is a core pillar of the game.

Note on naming: Chloe calls it a **worm**, not a snake. Use "worm" everywhere the kids can see. The body should be **chunky and segmented**, not a thin line.

### What Chloe asked for (decoded from the drawing)

1. **"The worms eat"** — food is a leaf, a flower, and an apple. Use those three as the starter food sprites.
2. **"Can you make it look like this"** — a fat, segmented worm body with a simple face on the head. Chunky segments, visible divisions between them.
3. **"And can you make it so that we can make the worm how we like it"** — the Worm Builder. The kids assemble a worm from parts they choose.
4. **COLORS** — a palette grid of about 14 colors to paint segments.
5. **Shapes** — segments come in different shapes: star, circle, oval, diamond, pentagon, triangle, rectangle.
6. **FACES** — a row of selectable faces for the head.
7. The big scribble is labeled "don't mind this." Respected and ignored.

### The Worm Builder screen (new core feature)

A no-reading screen where a kid builds a worm by tapping. This is the most-wanted feature in the whole project — give it real polish.

How it works:
- A worm sits in the middle of the screen, made of stackable segments.
- Tap a segment to select it. Tap a **color** from the palette to paint it. Tap a **shape** to change its form. Tap a **face** to set the head.
- Add or remove segments with big + / − buttons (icons, no text).
- The worm they build is the worm they play as. It saves locally per kid.
- Everything is tap-only. No sliders, no text, no numbers.

Chloe drew two finished worms as examples:
- **Worm A (mixed):** rounded face-head, then orange rectangle, black rectangle, blue oval, red diamond, green pentagon, brown triangle, magenta base. Mixed shapes per segment.
- **Worm B (rainbow):** horizontal rainbow stripes down a uniform body.

Both styles must be buildable, so support **per-segment shape AND per-segment color**.

### Asset list (single atlas, simple readable shapes)

Per the performance budget: one sprite atlas, no shaders, no particles, under 200 active objects. Everything below is a simple flat shape a non-reader can tell apart instantly.

#### Food (start with Chloe's three)
- Leaf (green)
- Flower (yellow)
- Apple (red)
- Boss Food (giant version of any — watermelon/cake later)

#### Feed-type collectibles (for the diet system)
These also appear in arenas; *what the kids collect most* decides what their creature becomes. Each is a clear flat shape, no text:
- **Animal feed** (Chloe's path): the leaf/flower/apple above, plus bugs and berries.
- **Robot feed** (Ryan's path): bolts, scrap metal, batteries, circuit bits.
- **Plant feed**: seeds, acorns, sprouts.
Generate them as the same flat-primitive style; they double as ordinary in-round food and as the diet signal for the creature at Home.

#### Worm segment shapes (the builder palette)
- Rectangle (Chloe's most-used)
- Oval
- Circle
- Diamond
- Pentagon
- Triangle
- Star (she drew it in the shape row)
Each shape is a single flat sprite, tinted at runtime by the chosen color, so one sprite covers all 14 colors. This keeps the atlas tiny.

#### Color palette (about 14, matching her grid)
blue, yellow, purple, green, white, black, red, brown, pink, orange, grey, dark-blue, teal, magenta. Tint segments in code from this fixed palette so the swatches and the worm always match.

#### Faces (the head)
A row of simple faces, each a tiny flat sprite overlaid on the head segment:
- sleepy / content (eyes closed, drawn first)
- surprised (open mouth)
- cat (whiskers + ears)
- bunny (long ears)
- plain smile
- silly / tongue-out
Keep them to single-color line faces so they read at tablet size.

#### The victory moment (not a crown)
There is no crown sprite. Round wins are shown as a moment, not an object: the winning worm needs a **victory animation** (a celebratory wiggle/pose), a burst of celebratory sprite-frame effects, and a "winner" splash that fills the screen with that worm — its colors and face front and center. This is the Smash "GAME!" zoom equivalent. No badge sits on the worm during play.

#### Evolution stages (visible transformations)
Tiny → Fast → Spiky → Dragon → Mega. Each stage is a size step plus an added feature sprite (spikes, wings) layered on the existing segments, so the kid's chosen colors/face carry through every evolution.

### Art production rules

- Flat colors, thick outlines, high contrast. It must read on a cheap tablet screen in a bright room.
- Every gameplay object distinguishable by **silhouette alone**, so a non-reader tells them apart even if colors wash out.
- Animate with sprite frames, never particle systems or shaders (budget rule).
- One atlas. Tint shapes in code rather than drawing every color variant.

### Why this matters for the build order

The Worm Builder can be built early and independently — it doesn't need networking. It's a perfect **Stage 1.5**: a self-contained, high-joy screen you can put in front of Chloe and her sibling within the first week to get them excited and gather feedback, while the scary networking work proceeds in parallel. Shipping her the builder first is both good morale and good product sense.

---

## Part 6: Borrowed Code & References (vetted)

The networking is the hard part, and someone already solved the exact zero-IP-typing problem for a snake game. Borrow that pattern. For everything else, learn the structure but write fresh, because the best-matching full game is GPL (see below).

### Reference table

| Project | What to take | License | Verdict |
|---|---|---|---|
| **GodotEasyLAN** (perons / Henrique Alves) | The LAN auto-discovery pattern: host broadcasts UDP packets with its IP + a room code to the broadcast address; clients listen and build a host list; connect via Godot high-level multiplayer. This is *exactly* the "host taps Start, client taps Join, no IP typing" flow in the spec. | Check the repo (addon, permissive-leaning) — verify before pasting | **Borrow the pattern, ideally the code.** Same author wrote a versus-snake game with it, so it's proven for this use case. |
| **SnakePro** (mar511n) | Architecture reference only: Godot 4.3, LAN over IPv4, Android export, touchscreen controls, in-game items, replays, multiple maps. Closest existing thing to your game. | **GPL v3** | **Learn from, do NOT copy.** GPL would force you to license your whole game GPL. Study how they structure items/replays/maps, then write your own. |
| **Thunder Plugins LAN Multiplayer for Godot 4** | A server-browser plugin with an explicit Android-fix history (v1.4 "Now Fixes Android Issues"). | Check itch listing | **Use as a cross-check.** Even if you don't use it, its changelog tells you Android LAN has real gotchas — read it before debugging blind. |
| **amitkumarraikwar/snake-game-using-godot-engine** | Clean beginner reference for grid movement, dynamic segment instancing (PackedScene), food spawning, collision. Good scaffolding to read. | **MIT** | **Free to borrow.** But note: it's grid-based. Chloe wants a chunky free-moving worm, so use it for segment-instancing patterns, not movement feel. |
| **henriquelalves WebRTC versus-snake** (DEV article + GitHub) | Conceptual: how to structure two snakes in a versus match, host-authoritative vs peer thinking. | Check repo | **Read the article.** It walks through the exact architectural fork (authoritative server vs P2P) you face. Good background even though you'll use LAN/ENet, not WebRTC. |

### The one thing to copy carefully: LAN discovery

Every other approach found online makes the user **type an IP address** — a dealbreaker for kids. GodotEasyLAN's broadcast pattern is the answer. The mechanism, in plain terms:

- Host opens a UDP socket and repeatedly sends a small packet (its IP + a room code) to the subnet broadcast address.
- Clients open a UDP socket, listen for those packets, and assemble a list of available hosts.
- When a client picks one, it uses the broadcast-supplied IP to open the real ENet connection via Godot's high-level multiplayer API.
- Host stops broadcasting once the match starts.

Two warnings the forum posts surfaced, worth baking into the build:
1. **Subnet mask gotcha.** Broadcast works cleanly on a 255.255.255.0 subnet (typical home/hotspot). On wider subnets it can fail. Your hotspot mode will be 255.255.255.0, so you're fine, but test it.
2. **Android LAN quirks are real.** Multiple plugins ship explicit "Android fixes." Expect to debug Android-specific networking behavior, and test on the actual tablets early (Stage 2), not just the desktop.

### License rule of thumb for this project

- **MIT / permissive** → free to copy into your code.
- **GPL (SnakePro)** → learn from, don't paste, unless you're willing to GPL the whole game.
- **Unsure** → treat as "read and reimplement," which is what you'd do for most of this anyway. For a non-distributed family project the legal risk is near zero, but staying clean now keeps options open if you ever share it with other families.

### How this feeds the build prompts

When you reach **Stage 7 (networking)**, add this to the prompt:

> Base the LAN discovery on the GodotEasyLAN broadcast pattern: host broadcasts its IP plus a room code over UDP to the subnet broadcast address; client listens, lists hosts, and connects via high-level multiplayer using the broadcast IP. Account for the 255.255.255.0 subnet requirement and known Android LAN quirks — we are testing on real Android tablets. Do not require anyone to type an IP address.

That single addition turns the riskiest stage from "invent it" into "adapt a proven pattern."

---

## Part 7: The Destruction Layer & Fair Fight (v2, Ryan's half)

Chloe defined how the worm looks and how you build it. Ryan defines how it *fights*. But the v1
version of this doc slightly mis-cast him. Correcting that is the heart of v2.

### The correction: Ryan mixes ingredients, he is not handed explosions

Ryan loves **Powder Toy** — and Powder Toy is not about big dumb explosions handed to you. It's
about **combining ingredients to cause reactions you discover.** v1 gave Ryan a flat list of
finished area weapons (a bomb with a big radius). That's the right *aesthetic* but the wrong
*verb*. The verb is **mix and discover.**

So Ryan's combat is a **bounded-emergence** system (full spec in Part 1):
- A few hidden **property tags** — start at exactly four: `fire`, `gas`, `mass`, `bounce`.
- Weapons/ingredients carry tags. Chili breath = fire; bubble burp = gas; boulder swallow = mass;
  booster = bounce.
- Combinations resolve by **pairwise tag rules** (fire+gas → big blast; mass+bounce → wrecking
  ball). The kids think in **items**; the engine thinks in **tags.**
- The whole interaction grid is **enumerable on one page** and **safe-by-default** (unhandled pair =
  both effects just happen, never a crash). Powder Toy's surprise, none of its chaos.

This gives Ryan the thing he actually wants — "I combined these and something new happened" — while
staying simple on its face and fully controlled underneath.

### The fairness linchpin (the most important constraint in the project)

The differences between the two kids drive the single most important rule: **the game must stay fun
for the kid who is behind — AND the build-up to a versus fight must be fair regardless of who put in
more hours.**

**Grind buys breadth, never height.** Solo progression unlocks **variety** (new parts, tools,
creature forms) — never **power that carries into a fight.** In a versus match both worms start
equal; they grow only from in-match events. Power progression lives only in PvE. The **fairness
filter** gates every unlockable:

> Does grinding this make you stronger in a fight, or just different?
> If *stronger* → not grind-lockable; available to both equally, in-match.
> If *different* → fine as a solo unlock.

This protects the fight from becoming a pay-to-win treadmill between siblings.

### The core tension (and why it's the solution)

Ryan wants to be the one destroying, but he's the baby (9 to Chloe's 10) and burns out if she can
dunk on him repeatedly. A game about *precise* combat would be a machine for making Ryan lose. So
the design gives him destruction that **doesn't require precision**, and catch-up that is
**invisible** — kids smell a pity handicap, and a visible "baby setting" stings worse than losing.

The elegant part: **Ryan's aesthetic IS the comeback mechanic.** Catch-up works the Mario Kart way —
the kid who's behind invisibly gets the better, bigger, more satisfying toys. Make those toys the
mixable destruction Ryan loves. He never feels slow, because falling behind hands him exactly the
toys he wants.

> Note on Chloe: she hates losing to Ryan, and per Part 1 that's **a flaw to correct, not enable.**
> We do NOT solve it by letting her always win or by making catch-up visible so she approves of it.
> We solve it by (a) keeping catch-up invisible so there's nothing to resent, (b) making loss
> *hilarious* so it stings less, and (c) letting the karma/care layer quietly reward grace and
> cooperation. The game teaches grace by how the world behaves, never by lecturing.

### Design rules that protect the slower kid (without announcing it)

#### 1. Wide-area, low-precision weapons skew to whoever's behind
The trailing worm's powerup table favors big-blast-radius bombs, spike walls/armor you ram, robot
stomps that hit everything nearby, radiating shockwaves. Chloe's precision advantage matters less
when the weapon forgives bad aim. Mario Kart's blue-shell logic, reskinned as Ryan's mixing
fantasy. **Invisible — never a labeled setting.**

#### 2. Destruction is its own reward, separate from winning
Ryan breaks stuff, sets off reactions, smashes the arena **whether or not he's ahead.** "Did I blow
things up / discover a cool combo?" is a different axis from "did I win?" A round where Ryan's worm
was smaller but he chained three reactions and wrecked a wall was a good round *for him.* Decoupling
joy from victory is the actual burnout fix.

#### 3. The boss is the shared-win space — AND a solo staple
Co-op against a boss is the one mode where neither sibling loses. But **bosses also scale down to
solo** — Ryan fights them alone constantly as the daily loop, and they scale up when the two team.
Make boss encounters frequent. This is where Ryan is the hero with no downside.

#### 4. "Slow" becomes a build, not a deficiency
The Worm Builder lets a kid grow toward Faster / Tougher / More Boosts. Let Ryan build a **heavy,
tanky, explosive bruiser** — slow but hard to kill, hits like a truck. Slowness is a playstyle he
*chose*, not a thing he *is*. Smash runs entirely on this — nobody calls Bowser the "bad at games"
character. Surface it in the builder as a visible body type. **Crucially (fairness filter): a body
type is a sidegrade, never a power tier** — the tank isn't *better*, it's *different*, and it does
not start a versus match stronger.

### Ryan's art & asset additions

All follow the budget rules (single atlas; sprite-animation explosions, not GPU particles — except
the sanctioned spectacle splurge).

#### Weapons & destruction (each carries property tags)
- **Bomb** — round bomb sprite, big sprite-animation blast. (tags: fire)
- **Spike armor / spike ball** — spikes layered on the body. (tags: mass)
- **Gun / blaster** — a "fancy gun" segment firing a simple projectile. (tags: fire)
- **Robot parts** — a robot worm skin (mechanical segments, glowing eyes) for the builder.
- **Shockwave ring** — expanding ring sprite. (tags: bounce)
The tags are what make these *combine* — that's the Powder-Toy layer.

#### Breakables in the arena
Crates, walls, pillars, barrels that explode; destructible boss segments; "smashable" props that pop
with a sprite animation and a sound. A whole layer of fun that doesn't depend on beating Chloe
(feeds rule #2).

#### The "Mega" ultimate is his moment
The Mega Worm ultimate (gigantic, crushes everything, explosions everywhere for ~10s) is tailor-made
for Ryan. Low precision, maximum spectacle. The meter fills partly from *taking* damage, so the kid
getting hit charges faster — invisible catch-up that reads as "awesome," not "assistance." This is a
fine place to spend the spectacle budget (shaders/particles allowed here specifically).

### The fairness test (guardrails)

Alongside the no-reading test, every combat/catch-up/unlock decision must pass BOTH:

> 1. Would the slower kid still want a third round after losing the first two? If a mechanic only
>    feels good when you're winning, it's wrong. The trailing kid must have the most fun toys.
> 2. Does anything a kid unlocked through solo grinding make their VERSUS worm stronger rather
>    than just different? If yes, it's a violation — fix it. Versus worms start equal.

### How this changes the two kids' roles

- **Chloe** — speed, precision, the builder, out-evolving you. The finesse player.
- **Ryan** — destruction, mixing/combining reactions, the tank build, boss-smashing, the Mega
  rampage. The power player and the chemist.
- **Together** — the boss worm (scaled up), where both win at once.
- **Apart** — each fights bosses and baddies solo as the daily loop; they reunite to brawl.

That asymmetry is the game. Two playstyles that need each other — and that, by the fairness filter,
meet as equals whenever they fight.

---

## Part 8: Names, Enemies, Weapons & Powerups (v2)

The brief: a great name, enemies of genuinely different *kinds*, and weapons/powerups that aren't
the boring standard kit. The rule throughout: **cut anything you've seen in a hundred other games
(plain bomb, plain shield, plain speed-up, plain magnet), and replace it with something that only
makes sense because you are a segmented worm that eats and grows.** The worm's own nature is the
idea engine.

---

### 1. The Name

"Chomp Stomp" is a placeholder. The real name should capture the actual fun: building a goofy creature
out of weird parts and then wrecking your sibling — or a boss — with it. Cute and violent at once.
Candidates, best first:

- **WIGGLE RUMBLE** — captures both halves: silly cute movement (Chloe) and the brawl (Ryan). Reads
  great out loud; a 9-year-old can say it and wants to.
- **NOODLE SMASH** — a chunky segmented worm *is* a noodle; inherently funny, owns the cute-and-
  violent contradiction. Loud, fun to yell.
- **CHOMP CITY** — eating-forward, big, silly.
- **SEGMENTS** — clean, hints the worm is made of parts you assemble. Quieter; maybe too grown-up.
- **GUTS & GLORY** — leans hard into Ryan's half; possibly too edgy for the cute side.

**Recommendation:** lead with **WIGGLE RUMBLE**, **NOODLE SMASH** runner-up. But this is the one
decision the kids make. Say all five out loud and watch which one they repeat back unprompted —
that's the name.

---

### 2. The Bestiary (enemies of different *kinds*)

The arena is the third player — and in a solo-first game, it's most of the game most of the time.
The point of a roster is **behavioral variety, not skins** — each enemy forces a different reaction.
Grouped by the job they do. All sprite-animated, no shaders, within the object budget.

#### Little pests (fill the arena, easy to smash, satisfying — the solo loop's bread and butter)
- **Crumbs** — tiny scuttling bugs that flee. Pure chase-and-pop snacks. Keep the screen busy.
- **Hoppers** — frogs that jump in arcs; time a chomp as they land. Teaches timing, no tutorial.
- **Stink Beetles** — pop them and they leave a cloud that makes you *sneeze* (a tiny random wiggle
  for 1 second). Annoying, funny, harmless.

#### Thieves (create conflict, raise the stakes)
- **Gulls** — swoop, snatch a piece of food, try to fly off. In versus, both kids race the same
  gull; in solo, a sudden "stop it before it escapes" goal.
- **Pocket Moles** — pop up, swallow a powerup, burrow away. Chomp the mole fast → powerup back
  *plus* a bonus.

#### Bullies (push you around, area denial)
- **Boulder Bugs** — armored roly-polys that charge straight and bowl worms over. Eaten only from
  the soft back end — outmaneuver, don't ram.
- **Spitters** — rooted plant-worms lobbing slow blobs you weave around. Turn an open arena into a
  dodge course.

#### Chaos-makers (change the whole arena state)
- **Gloop** — a slow blob leaving sticky trails; touch one and you crawl slow a moment. Slowly
  paints the arena into a maze.
- **Magnet Mites** — metal bugs that drag loose food/powerups toward them. Pop them → everything
  they hoarded scatters at once.

#### The bosses (scale SOLO ↔ CO-OP — daily solo staple AND the team-up moment)
Per Part 1, **every boss is beatable by one worm and more fun with two.** Health and
attack scale with player count; telegraphs must be readable by a single kid alone. Beating a boss
**unlocks a blueprint** (a variety sidegrade, per the fairness filter).
- **Robo-Worm** — the arena-sized mechanical worm. Destructible segments, telegraphed attacks, power
  cells to collect. The flagship "did you see that?!" fight, and Ryan's favorite solo grind.
- **The Gobbler** — a giant mouth in the floor that tries to swallow everything. Feed it enough junk
  enemies to make it burp and retreat. Solo: bait-and-feed puzzle. Co-op: feed it together.
- **Granny Centipede** — a fast, long, segmented boss that chases. Make her crash into her own body
  (classic snake death). Solo: cut her off with your own trail; co-op: pincer her together.

**Design note:** spawn pests constantly (easy fun and Ryan's smash-fodder), thieves and bullies
occasionally (make the kids react), a boss as the mid-session spectacle and the unlock gate.
Variety of *behavior* is what makes the arena feel full whether one worm or two are in it.

---

### 3. Weapons (built from being a worm — and now they CARRY TAGS so they combine)

These replace the generic kit. Each only works because you're a long, segmented, eating creature.
Each carries one or two **property tags** (`fire`, `gas`, `mass`, `bounce` — start with these four)
so weapons **combine** via the bounded-emergence grid below. The kids think in items; the engine
resolves tags.

#### Eating-based (you swallow, then weaponize it)
- **Chili Pepper Breath** — eat a pepper, breathe a cone of fire for a few seconds. (tags: **fire**)
- **Bubble Burp** — swallow a fizzy drink, burp a big bubble that traps the other worm a moment.
  Silly, low-precision, great catch-up tool. (tags: **gas**)
- **Boulder Swallow** — eat a rock, your head becomes a wrecking ball: smash walls, enemies, bounce
  the other worm. Slow but unstoppable. (tags: **mass**)
- **Spicy Hiccups** — eat something too spicy, involuntarily *spit pepper seeds* in random
  directions like a shotgun you can't aim. (tags: **fire**, light)

#### Body-based (you ARE the weapon — uses the segments)
- **Tail Whip Slam** — crack your whole tail like a whip, knocking back an arc. Longer = bigger arc;
  growth *is* the upgrade. (tags: **mass**)
- **Spike Mode** — every segment sprouts spikes; ramming hurts *them*, not you. (tags: **mass**)
- **Shed Skin** — drop your tail segments as a wall of obstacles, keep going shorter and faster. A
  real trade, not a button. (tags: **bounce** on the shed trail)
- **Coil Trap** — curl into a spring and launch in a straight line, a dash you aim by curling.
  Chloe's precision tool. (tags: **bounce**)

#### Build-it weapons (from the Worm Builder body types — sidegrades, never power tiers)
- **Robot Arm Segment** — a builder part: one segment becomes a mechanical arm that grabs and yanks
  the other worm toward you. (tags: **mass**)
- **Booster Segment** — a rocket segment: a burst of speed on tap, overheats if spammed. (tags:
  **bounce**, **fire** exhaust)

#### The combination grid (bounded emergence)
Combinations resolve on **tags, not items.** Start with four tags and this enumerable grid (build it
as a single data table; this is the starting point, tune by playtest):

| combo | result |
|---|---|
| fire + gas | big blast (gas ignites) — the signature Ryan moment |
| fire + mass | molten ram: the wrecking ball leaves a burning trail |
| fire + bounce | flaming dash / fireball skip across the arena |
| gas + mass | the heavy thing floats briefly then SLAMS (gas lift + drop) |
| gas + bounce | a bouncing bubble that ricochets and traps on contact |
| mass + bounce | wrecking ball that bounces off walls — pinball of doom |
| same + same (e.g. fire+fire) | amplify: bigger/longer version of that single effect |
| any unhandled pair | **SAFE DEFAULT: both effects just happen, no special combo** |

Hard rule: the safe default means there is **never a broken/crashing state** — worst case is "that
combo was boring." Keep the tag count at four until the kids are clearly hungry; adding a 5th
(`electric`?) or 6th (`sticky`?) multiplies the grid, so add deliberately and re-eyeball the whole
table for unfun pairs.

---

### 4. Powerups (the absurd, memorable kind — standard kit deleted)

**Deleted on purpose:** plain speed-up, plain shield, plain invincibility star, plain magnet, plain
extra-points. Where an idea survives, it's twisted into something with a catch or a joke.

#### Transformations (the worm becomes something ridiculous)
- **Slinky Mode** — super-bouncy and stretchy, flinging around like a rubber band. Briefly
  unkillable because unpredictable. (tags: **bounce**)
- **Balloon Worm** — inflate and float over hazards/walls — but a single chomp pops you. (tags:
  **gas**)
- **Train Mode** — segments separate into a steerable choo-choo convoy; ram the other worm to
  decouple *their* segments. (tags: **mass**)
- **Magneto-Worm** (twisted magnet) — pull the *other worm* toward you, not food. A grab attack.
  (tags: **mass**)

#### Arena-changers (the powerup changes the world, not just you)
- **Gravity Flip** — arena gravity rotates; everyone slides to a new wall. Spectacle over advantage.
- **Lights Out** — arena goes dark except a glow around each worm. Hide-and-seek. Resets a runaway
  lead for free.
- **Food Rain** — it rains leaves, flowers, apples for a few seconds. Everyone feasts at once — a
  deliberate "catch-up by abundance" moment. (This is also exactly what a bloomed garden triggers —
  see the Care & Karma section.)
- **Tiny Town** — everything shrinks; the arena feels huge and mazey. Pure novelty.

#### The "behind kid" specials (catch-up disguised as awesome, per Part 7 — invisible)
Weight toward whoever's smaller/behind. Read as "I got the cool one," never a handicap.
- **Mega Munch** — your mouth becomes enormous; eat anything, including chunks of the other worm, in
  one gulp. The comeback dream. (Also a comedic-loss trigger — see §6.)
- **Copycat** — instantly copy whatever powerup the *leading* worm last used. Fairness as a power
  fantasy.
- **Underdog Roar** — a screen-shaking roar that stuns everything nearby and clears a path. Loud,
  dumb, satisfying — handed to whoever's losing.

#### The Ultimate (one per worm, earned not picked up)
Fills from eating, landing hits, and taking damage (kid getting hit charges faster — invisible
catch-up). Body type flavors it:
- **Mega Worm** (tank) — a colossal kaiju worm; everything you touch explodes ~10s. Ryan's. (Spend
  the spectacle budget here.)
- **Sonic Coil** (speed) — blinding speed, a damaging light trail, pass through anything. Chloe's.
- **Swarm Split** (trickster) — split into several small worms, recombine when the timer ends. A
  third option so the choice isn't just "fast vs strong."

---

### 5. The comedic loss bank (content category, not one asset)

A total loss must be possible and must be **funny, never unfair** (Smash's "blasted off the stage").
Fire one situationally / semi-randomly so loss surprises every time. Ryan loves funny; a funny loss
teaches Chloe grace with no words. Each is a sprite-animated moment, fun to be on the receiving end
of. Starter bank (grow it over time):
- **Eaten & popped out** — winner Mega-Munches the loser; loser pops out the far end dizzy.
- **Blasted off** — a final hit launches the worm spinning off-screen with a comedy whistle.
- **Deflate** — loser sputters and shrinks to a tiny confused noodle while the winner balloons up.
- **Balloon drift** — loser inflates and floats helplessly off the top of the screen.
- **Scattered beads** — segments pop apart and scatter like dropped beads, then reassemble dizzily.
- **Pancake** — flattened with a *pop*, then springs back up flat and blinking.
Pair each with a distinct bfxr2 sound (see Asset Generation section). These are the single best cheap investment in making
losing okay for the bossy kid.

---

### 6. The one principle to keep

When tempted to add a weapon or enemy, run it through: **"Could this exist in any game, or only in a
game about a segmented worm that eats and grows?"** Plain gun, plain shield → cut or twist. Shed your
tail, swallow a rock, split into a swarm → keep. And the v2 addition: **does this weapon carry a tag
so it can COMBINE?** If it's a one-off with no tag, ask whether giving it a tag would make it part of
Ryan's chemistry set. The combination grid is the well that never runs dry.

---

## Part 9: The Care & Karma Layer (v2, formerly "The Secret")

This is the **soul** of the game — deliberately the opposite of the surface. The visible game is
Smash/Sonic/Mario Kart/Powder Toy: fight, go fast, mix things, win the round. This layer is that the
best *variety* and the warmest *delight* come not from fighting but from working together and taking
patient care of something across many rounds.

But for THIS family, a correction to v1's framing: most kids play the loud frantic game, and **that
is fine and correct.** v1 called this layer "the real game." It is not — the brawl is the game and
the daily hook. This layer is the soul that makes the world feel alive and quietly teaches good
habits. A kid who only ever brawls has a complete, great game. A kid who also tends gets a quietly
richer one.

### Karma, not a secret quest

There's no hidden quest to find, there's a world that **reliably rewards care and cooperation without
ever announcing it.** No tutorial, no menu, no notification, no "you were nice, here's a prize." The
kid just experiences, over time, that tending their creature and watering the garden with their
sibling makes good things happen — a companion shows up mid-brawl, the garden rains food. The
cause→effect link is **never surfaced**; it's for them to feel. That's what makes it a *habit*
rather than a *transaction*.

Because the game is solo-first, the creature-growing and blueprint-unlocking are **not hidden from
the kids** the way v1 implied — grinding a boss to unlock a robot part is a thing Ryan does on
purpose, as the main solo loop. What stays unspoken is the *karmic* part: that care and cooperation
specifically pay off. The mechanics are visible; the lesson is ambient.

### Why this matters

It's the deepest anti-burnout mechanic. The catch-up toys keep a losing round bearable.
This goes further: it makes the round score *not the whole game.* When Chloe out-brawls Ryan five
rounds straight, Ryan has been growing a creature about to become something neither has seen, and
unlocking parts that are *his.* The frantic layer and the patient layer run in parallel.

It teaches the opposite of what the surface teaches — cooperation and care beat aggression and
speed — **without lecturing,** and without a single word a non-reader can't read. The lesson is in
the mechanics. (And it teaches Chloe grace from a second direction: the garden she refuses to tend
with Ryan simply doesn't bloom, and she feels the difference. The world, not Dad, makes the point.)

### The fairness filter governs every output

Everything this layer produces must pass: **does it make a versus worm stronger, or just different?**
- A hatched **companion** is *fun*, not an *advantage* — it does cute/chaotic things, it doesn't add
  damage or health to its owner's versus worm.
- A **garden bloom** rains food into the next match **for BOTH kids equally** — abundance, not edge.
- An **unlocked blueprint** is a *variety sidegrade* — a new part to *choose*, never a stat boost.
- The creature's growth changes *what your worm can be*, never *how strong it starts a fight.*

Power progression is allowed only in PvE (solo/co-op bosses can get easier as you unlock). Only
variety and delight cross into PvP.

### The karma leak (outputs reach the brawl)

- A **bloomed garden** triggers a Food Rain (see Part 8) early in the next match — both kids feast.
- A **hatched companion** can appear mid-match doing something delightful (a little buddy that bonks
  a pest, scatters confetti, cheers) — ambient joy, never an edge.
- A well-tended **creature** might wave from the Home background, or its motif appears in the
  victory/loss animations — flavor, not power.
All of it un-narrated. The kids feel "good things happen when we take care of stuff," never told.

### The loop

Persistence across rounds, minus the tedium (carrying/losing a bag), keeping only the magic (what
you did last round shapes this one).
- A calm **Home** screen between rounds — not a menu, a little place the worms live.
- At round end, what you collected isn't stored in a bag — it's **fed straight into the thing you're
  growing.** No slots, no sorting, no carrying capacity. One happy tap.
- What you fed it carries forward as *what it's becoming.*
- **Neglect costs you but never wipes you out** — the thing you ignored *sleeps / wilts a little*,
  it doesn't die. Care compounds; neglect only stalls.

### No inventory. Ever. (a hard rule)

Inventory management is the enemy — slots, weight limits, "bag full," dragging between grids. The
kids voted against it by living in Minecraft **Creative.** They don't enjoy *having stuff*; they
enjoy **watching something become something** based on what they put in. So: persistence with **no
inventory screen, no resource counts, no management of any kind.** What you collect is never a pile
to organize; it's food for a transformation. The reward loop is *unlocking blueprints* and *growing
creatures*, not accumulating and sorting. If a feature starts to feel like managing a bag, it's
wrong — cut it.

### The three persistent things to tend

#### 1. The Creature — what you feed it decides what it becomes (the heart)
Grow a creature across rounds by feeding what you collect — and **what you feed determines what it
grows into,** with obvious visible variety:
- **metal, scrap, electronics, batteries** → a **ROBOT** (Ryan's love)
- **leaves, fruit, bugs, living things** → an **ANIMAL** (Chloe's love)
- **seeds, flowers, roots** → a **PLANT**
- weirder mixes → stranger hybrids, secret types to discover

The kid is never managing a pantry — they're *choosing what their creature becomes* by what they
chase. A robot worm looks nothing like an animal worm, so a non-reader sees the result of their
choices at a glance. Tend it long enough and it **hatches/evolves into a rare worm part or a
companion** you can't get any other way (a variety sidegrade — fairness filter).

**Safety rule:** the diet is a *lean*, not a lock. The creature drifts toward whatever you've fed it
most; what it becomes reflects the dominant diet over time. One off feed never ruins it. A kid
who's made a robot for five rounds and accidentally feeds an apple still has a robot.

Neglect → it **sleeps** until you return. Reversible, kind.

#### 2. The Garden (cooperation gated — needs BOTH kids)
- A shared plot on Home. Both kids plant and water — one tap each, no management.
- It only flourishes if **both** tend it. One kid alone can't make it bloom — the reward is locked
  behind genuine cooperation.
- A bloom **rains rare food into the next match** (the karma leak), helping them both — including
  the rarer feed-types that unlock special creature paths.
- The explicit "you have to work together" reward. Ryan smashing and Chloe racing can't unlock it;
  only the two of them caring for the same thing can. This is Chloe's grace lesson, delivered by the
  world.

#### 3. Blueprints (unlocked, not collected)
- As creatures grow and hatch, the kids **unlock blueprints** — new worm parts, creature types,
  arenas.
- Once unlocked, a blueprint is *theirs forever* and simply appears as a new option in the Worm
  Builder. No crafting queue, no materials, no inventory — unlocking is the reward, using it is free
  (Creative-mode style).
- Replaces every "collect N to craft" loop with "you grew something cool, now you can always build
  with it." **Every blueprint is a variety sidegrade** (fairness filter) — it never makes a versus
  worm start stronger.

### How rare rewards gate (behind care/cooperation, NOT behind winning brawls)

The rarest, coolest **variety** — the parts and creatures the kids most want — is reachable through
the quiet game, never by winning versus:
- The best worm parts come from creatures grown and hatched over many rounds (solo, patient).
- The best robot/animal/plant forms come from sustained deliberate feeding in one direction.
- The best companions and some arenas come from cooperation (the garden) or extended care.
- Some blueprints unlock only after the two kids have cooperated N times.

The loud game stays fun, frantic, and **fair** (the things gated here are variety, not power, so a
kid who only fights isn't *weaker* — just has fewer cosmetic/option choices). The aspirational layer
rewards exactly the values worth teaching.

### What to build, and when

A **later** layer — needs the core solo game working first. But design the data model for
persistence from the start so nothing has to be retrofitted:
- The Home screen + a persistent per-kid state file (`data/home_state.json`). It stores *what each
  creature is becoming* and *which blueprints are unlocked* — never an item list.
- A feed step at round end: collected food → creature in one tap, nudging its diet-lean. No bag.
- The Creature first (care level rises when fed, slowly falls when ignored — sleeps, never dies; a
  diet-lean weighting that determines what it hatches into at a threshold).
- The Garden second (the cooperation check: did both kids contribute since last bloom?).
- The karma leak throughout (bloom → Food Rain; companion → mid-match cameo).
- Blueprints throughout (hatching/evolving unlocks Worm Builder options, permanently and freely).

Build order: **after** the solo hook beats Slither.io and the versus reunion works — creature-feeding
starts at Stage 6, garden+karma at Stage 11. The data model is designed in from day one; the
features come once the frantic game is solid.

### The principle

The surface says: be fast, fight, mix, win. The soul says: the best variety and the warmest delight
come to those who take care of something, and who help each other — and it says it with zero tedium
(no inventory, just collect-and-feed-and-watch-it-grow) and zero words (the world rewards care
reliably, and never explains why). Build it so the kids *feel* it themselves — because a lesson you
feel is one you keep. But never let it crowd out the brawl: the brawl is the game; this is its soul.

---

## Part 10: Asset Generation (Sound & Graphics Without Being Good At Either)

The constraint: you are not a game artist or audio engineer, and you want asset creation to be procedural / AI-driven and either free or already part of Claude. Good news — for this specific game, the cheap procedural path is also the *correct* path aesthetically. Do not pay for AI asset generation. Here's the whole pipeline.

### Sound: procedural, embedded, free, offline

**Use the sfxr / bfxr2 procedural engine, not AI audio generation.** Here's why it wins for this game specifically:

- It generates exactly the palette a kids' game needs — chomps, pickups, zaps, explosions, jumps, pops — from math, instantly.
- It is **free and open source** (Apache 2.0 for the original bfxr), so the generator code can go *inside* your game. bfxr2 (March 2025) is a JavaScript reworking; sfxr has ports in C#, C++, and more.
- It runs **offline on the tablet** — no API, no cloud, no per-sound cost ever.
- It is **deterministic**: the same seed produces the same sound. This matters for your persistence/secret system and for keeping the build reproducible.
- The retro chiptune character is the perfect match for flat-shape kid graphics. AI-generated cinematic SFX would actually clash with the art.

AI sound generators, by contrast, are mostly freemium and cloud-dependent — wrong on cost and wrong on offline. Skip them.

#### Two ways to use it
1. **Bake at build time (simplest):** Use the bfxr2 web app to generate each sound, export WAV/OGG, drop into `assets/audio/`. Free, zero code, you just click "explosion" and tweak until it's funny. Good enough to ship.
2. **Generate at runtime (the procedural dream):** Port the sfxr synthesis into the game (Godot can synthesize audio from a parameter set). Then each weapon/enemy carries a small parameter set or seed, and the sound is generated live. Infinite variation (every explosion slightly different), tiny storage (you store seeds, not WAV files), and it ties into the worm-builder idea — a kid's custom worm could even have a seed-derived voice. Build path #1 first; graduate to #2 if you want the variation.

#### Music
For background music, the same philosophy: a simple procedural/generative chiptune loop (there are small open-source chiptune music libraries) beats licensing tracks. Keep it minimal — a calm loop for the Home screen, an up-tempo one for rounds. Lowest priority; do it last.

### Graphics: Claude generates flat SVG primitives, code does the rest

This is the part that is **already part of Claude** — you have the generator in this chat. The art spec commits to flat colors, thick outlines, single shapes tinted in code. That is not a limitation that happens to be cheap; it is *exactly* what Claude produces well as SVG, for free, right now.

#### Why this works
- A worm segment, a leaf, an apple, a chili pepper, a Boulder Bug, a victory burst — these are simple SVG paths. Claude can generate them on request.
- Because everything is **tinted in code**, one SVG shape becomes all 14 colors. You generate the shape *once*.
- Because the worm and enemies are **built from combinable primitives** (a circle body + spikes + eyes + a face), Claude generates a *kit of parts* and the game assembles huge variety from a small set. That is the procedural generation you wanted, and it's native to how the Worm Builder already works.

#### The pipeline
1. Ask Claude to generate each primitive as a flat SVG: segment shapes (rectangle, oval, circle, diamond, pentagon, triangle, star), faces, food, each enemy, weapon icons, the victory burst, effect frames.
2. Keep them as layered primitives, not finished art — body / eyes / mouth / spikes as separate pieces the game can mix.
3. Convert to the single sprite atlas. SVGs rasterize cleanly to whatever tablet resolution you need.
4. Tint and combine in code. One shape set covers all colors and many creatures.
5. Animate with sprite frames (budget rule: no particle systems and no gameplay shaders) — Claude can generate the 2-4 frames of an animation (e.g. a chomp open/closed, an explosion's grow/burst/fade) as a small SVG sequence.

#### Procedural assembly = endless content for free
The combination of "primitives + code tinting + code assembly" means new enemies and worm parts cost almost nothing: a new creature is often just a new arrangement of existing primitives in a new color. The bestiary can grow indefinitely without new art commissions — you're recombining a kit, exactly the procedural approach you asked for.

### What you never have to do

- You never draw by hand.
- You never pay an AI image API.
- You never license a sound pack.
- You never become a game artist or audio engineer.

Sound comes from a free procedural engine that runs offline. Graphics come from Claude as flat SVG primitives that the game tints and assembles. Both are procedural, both are cheap-or-already-yours, and both are the right aesthetic rather than a compromise.

### How this feeds the build

When you reach art/audio in any stage prompt, add:

> Generate the graphics as flat SVG primitives I can tint and combine in code — give me layered pieces (body, eyes, mouth, spikes) not finished art, so the game assembles variety from a small kit. For sound, use the bfxr2 / sfxr procedural approach: either baked WAV/OGG from the bfxr2 web app, or synthesized at runtime from a small parameter set per effect. Do not use any paid AI asset generation, and keep all audio offline-capable on the tablet.

---

## Part 11: Android Export Setup

This guide gets you from nothing to "APK running on the tablet" in one sitting.
Do the steps in order — the order matters.

**Target device:** 12" octa-core tablet, ~Android 16, 2000×1200 FHD, plenty of RAM.

The Android export side of things requires four things lined up:
- Export templates that match your exact Godot version
- JDK 17 (not newer)
- The Android SDK (platform-tools, build-tools, an SDK platform, the NDK)
- A debug keystore to sign test builds

Steps 1–2 establish the project. Steps 3–8 are machine-wide setup (do once, applies
to every future Godot project). Steps 9–10 are the repeating loop.


### Step 1 — Create the GitHub repo and clone it locally

1. Go to github.com and sign in. Click **New repository**.
2. Name it `ChompStomp`. Set it to Private. Check "Add a README file" so the repo
   isn't empty. Click **Create repository**.
3. On the repo page, click the green **Code** button and copy the HTTPS URL.
4. Open **VS Code**. Press `Ctrl+Shift+P` to open the command palette, type
   `Git: Clone`, and paste the URL. Choose a local parent folder (e.g. `D:\Git`).
   VS Code clones the repo into `D:\Git\ChompStomp` and offers to open it — say yes.
5. You now have `D:\Git\ChompStomp` on disk, tracked by git, open in VS Code.
   The terminal in VS Code (`Ctrl+`\``) is how you'll run git commands going forward.


### Step 2 — Download Godot and create the project inside the repo

1. Go to the Godot download page and download the **standard (GDScript) version** for
   this project — not the .NET version. Download the 64-bit zip.
2. Unzip it somewhere stable, e.g. `C:\Godot\`. The executable is `Godot_v4.x.x.exe`
   — no installer, just run the exe directly.
3. Launch Godot. The **Project Manager** opens (a list of projects; it's empty on
   first run).
4. Note your exact version number — it's in the title bar or at **Help → About**.
   Write it down (e.g. `4.4.1`). You'll need it exactly in Step 3.
5. Click **New Project**.
   - **Project Name:** `ChompStomp`
   - **Project Path:** browse to `D:\Git\ChompStomp` (the folder you cloned in Step 1)
   - **Renderer:** leave on **Compatibility** — widest Android driver support, correct
     for a 2D mobile game
6. Click **Create & Edit**. Godot creates `project.godot` inside your repo folder and
   opens the editor.
7. Back in VS Code, you'll see `project.godot` and other Godot files appear. Commit
   them: in the VS Code terminal run:
   ```
   git add .
   git commit -m "init: add Godot project"
   git push
   ```


### Step 3 — Install the export templates

This is the easiest step and the one people skip.

Godot's top menu bar has five menus: **Scene · Project · Debug · Editor · Help**.
"Editor" is its own menu — the fourth one, easy to miss.

1. Click **Editor** in the top menu bar.
2. Near the bottom of that dropdown, click **Manage Export Templates…**
3. A small window opens. If it says no templates are installed, click
   **Download and Install**. Godot downloads the templates for your exact editor
   version automatically. Wait for the progress bar to finish.

No files to move — that's it. If the download fails, there's a "Download from"
dropdown with mirror options; pick another and retry.

> **Can't find the option?** Alternative path: **Project → Export → Add… → Android**.
> If templates are missing, a yellow warning at the bottom has a link to install them.


### Step 4 — Install JDK 17

Use version 17. Not 21, not 11. Godot 4's Gradle build is pinned to 17, and a
newer JDK throws cryptic errors.

1. Go to adoptium.net/temurin/releases/
2. Set filters: **Version = 17**, **Operating System = Windows**,
   **Architecture = x64**, **Package Type = JDK**.
3. Download the `.msi` installer.
4. Run it. On the options screen, turn **ON** "Set JAVA_HOME variable" and
   "Add to PATH" if offered.
5. Note the install path, typically:
   `C:\Program Files\Eclipse Adoptium\jdk-17.x.x-hotspot\`
   You'll paste this into Godot in Step 8.

Verify: open a fresh PowerShell window and run:
```
java -version
```
You should see `openjdk version "17.…`. If it says 21 or "not recognized," reboot
and try again, or just note the install folder for Step 7.


### Step 5 — Install Python and SCons

The Android export build chain requires Python and SCons.

1. Go to python.org/downloads/ and download the latest Python 3.x installer for Windows.
2. Run the installer. On the first screen, check **"Add Python to PATH"** before
   clicking Install — this is easy to miss and skipping it means nothing works.
3. Once installed, open a fresh PowerShell window and install SCons:
   ```powershell
   python -m pip install scons
   ```
4. Verify both:
   ```powershell
   python --version
   scons --version
   ```
   Both should print version numbers. If either says "not recognized," reboot and
   try again — the PATH update from the installer requires a fresh session.


### Step 6 — Install the Android SDK

#### Part A — Install Android Studio to get sdkmanager

1. Download Android Studio from developer.android.com/studio and install
   with default options.
2. Launch it. The first-run setup wizard will run — accept defaults, let it download
   the base SDK, accept all license agreements. Then close Android Studio.

   Its only job here is to put `sdkmanager` and the base SDK on disk. You won't
   use its GUI again.

#### Part B — Set the ANDROID_HOME environment variable

Tools like `sdkmanager` and `adb` look for this variable to find the SDK. Set it
permanently so you never have to think about it again.

1. Press **Win + R**, type `sysdm.cpl`, press Enter.
2. Go to **Advanced → Environment Variables**.
3. Under **User variables**, click **New**:
   - **Variable name:** `ANDROID_HOME`
   - **Variable value:** paste the output of this PowerShell line:
     ```powershell
     "$env:LOCALAPPDATA\Android\Sdk"
     ```
4. Click OK through all dialogs.
5. **Close and reopen PowerShell** so it picks up the new variable.

#### Part C — Find sdkmanager and install all required packages

1. First, find where Android Studio put the command-line tools:
   ```powershell
   ls "$env:LOCALAPPDATA\Android\Sdk\cmdline-tools\"
   ```
   You'll see a version-numbered folder (e.g. `16.0`) or a folder called `latest`.
   Note the name — replace `latest` in the next command if yours is different.

2. Run the installer. This is one long command — paste the whole thing at once,
   do not break it across lines:
   ```powershell
   & "$env:LOCALAPPDATA\Android\Sdk\cmdline-tools\latest\bin\sdkmanager.bat" "platform-tools" "build-tools;35.0.1" "platforms;android-35" "cmdline-tools;latest" "cmake;3.10.2.4988404" "ndk;28.1.13356709"
   ```
   The tool prints license agreements as it goes — type `y` and Enter each time.
   It downloads and installs everything in one pass.

#### Verify

```powershell
ls "$env:LOCALAPPDATA\Android\Sdk\ndk\28.1.13356709\"
```
If that folder lists files, all packages are installed.


### Step 7 — Create the debug keystore

Signs your test builds. Run this in PowerShell, all on one line. (If `keytool`
isn't found, replace it with the full path:
`"C:\Program Files\Eclipse Adoptium\jdk-17.x.x-hotspot\bin\keytool.exe"`)

```powershell
keytool -keyalg RSA -genkeypair -alias androiddebugkey -keypass android -keystore "D:\Godot\debug.keystore" -storepass android -dname "CN=Android Debug,O=Android,C=US" -validity 9999 -deststoretype pkcs12
```

Creates `D:\Godot\debug.keystore`. Alias is `androiddebugkey`, both passwords are
`android`. Remember those for Step 8.


### Step 8 — Point Godot at everything (one time)

1. In Godot: **Editor → Editor Settings**.
2. In the search box, type `android`. You'll land on **Export → Android**.
3. Fill in:
   - **Java SDK Path** → the specific JDK subfolder, not the Adoptium parent.
     Point it at the folder that contains a `bin\` directory with `java.exe` inside.
     It looks like `C:\Program Files\Eclipse Adoptium\jdk-17.0.x.x-hotspot` — the
     version numbers in the folder name will match whatever you installed.
     To find the exact path, run in PowerShell:
     ```powershell
     ls "C:\Program Files\Eclipse Adoptium\"
     ```
     Copy the full name of the `jdk-17...` folder shown and prepend
     `C:\Program Files\Eclipse Adoptium\` to it.
   - **Android SDK Path** → SDK location from Step 6.
     Godot's path field doesn't expand environment variables, so run this in
     PowerShell to print the exact string to copy-paste:
     ```powershell
     "$env:LOCALAPPDATA\Android\Sdk"
     ```
   - **Debug Keystore** → `D:\Godot\debug.keystore`
   - **Debug Keystore User** → `androiddebugkey`
   - **Debug Keystore Pass** → `android`

Close Editor Settings. A wrong path shows as a red warning when you try to export.


### Step 9 — Install the Android Build Template into the project

Per-project, not per-machine. Do this once for ChompStomp.

1. With ChompStomp open in Godot: **Project → Install Android Build Template**.
2. Confirm. Godot unpacks Gradle build files into an `android/` folder inside your
   project. Commit that folder to git — it's part of the project.
   (Redo this only if you upgrade Godot versions.)


### Step 10 — Configure the export preset and build

1. **Project → Export**.
2. Click **Add…** and choose **Android**.
3. The preset opens. With Steps 3–9 done, there should be no red error text at the
   bottom. (If there is, it names the missing piece.)
4. Set SDK versions to match the tablet:
   - **Min SDK** — 26 (Android 8+)
   - **Target SDK** — 35; bump to 36 once available and the tablet confirms Android 16
5. Set screen orientation to **Landscape**.
6. The 2000×1200 FHD display is handled automatically — no special export setting needed.
7. Click **Export Project**, name the file `chomp-stomp.apk`, leave
   "Export With Debug" checked for all test builds.

The first build is slow (Gradle downloads dependencies). Later builds are fast.


### Step 11 — Get it onto the tablet

1. On the tablet: **Settings → About → tap "Build number" seven times** to unlock
   Developer Options. Then in Developer Options, turn on **USB debugging**.
2. Plug the tablet into the PC. Accept the "Allow USB debugging?" prompt on the tablet.
3. In PowerShell, verify the tablet is visible:
   ```powershell
   & "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe" devices
   ```
4. Install the APK:
   ```powershell
   & "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe" install -r "D:\path\to\chomp-stomp.apk"
   ```

The `-r` flag means reinstall/replace — run it again after every new build.

That's the loop: **Export Project** in Godot → `adb install -r` → play on the tablet.


### Quick troubleshooting

| Symptom | Fix |
|---|---|
| "A valid Java SDK path is required" | Java SDK Path in Editor Settings points at the wrong folder or at JDK 21. Repoint it at the JDK 17 folder from Step 4. |
| Wall of red Gradle text | Version mismatch. Confirm editor version == templates version (Step 3), and JDK is 17 (Step 4). |
| Export button greyed out | Templates not installed (redo Step 3) or build template missing from project (redo Step 9). |
| `adb` not recognized | Use the full path to `adb.exe` as shown in Step 11, or add the `platform-tools` folder to your PATH. |
| Tablet not in `adb devices` | USB debugging off, bad cable, or missed the "Allow" prompt. Unplug, replug, watch the tablet screen. |
| Build crashes on tablet at launch | Target SDK mismatch (Step 10). A wrong target SDK can cause instant crashes on Android 15/16. |


### Once this works

Steps 1–9 are done forever. You only ever repeat Steps 10 and 11. When Claude Code
builds a new stage of the game, this pipeline turns it into something Chloe and Ryan
can hold within a couple of minutes.
