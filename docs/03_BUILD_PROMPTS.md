# Worm Wars — Build Prompts for Claude (v2, solo-first)

Ready-to-paste prompts for building the game with Claude (Claude Code recommended — it writes the
real project files and runs the Godot CLI). Work through them in order. Each assumes Claude has
`00_FAMILY_TRUTH.md`, `01_GAME_DESIGN.md`, and `02_TECHNICAL_SPEC.md` available.

> **The order changed from v1.** This is a **solo-first** game (see `00_FAMILY_TRUTH.md`). The
> daily hook is one kid playing alone against the world; versus is the occasional reunion. So the
> **solo loop is built before networking**, and "done enough" = the solo loop beats Slither.io.
> Networking moves to the content stages, where it belongs, because it's the scariest part and the
> hook doesn't depend on it.

## How to use these

- **Claude Code** is the right tool — it creates the Godot tree, writes GDScript, iterates. Say
  "I'm using Claude Code" so it writes files instead of pasting code into chat.
- Feed it `00_FAMILY_TRUTH.md` first, then the foundation docs.
- Do the prompts **in order**. The first milestone that matters is the **solo hook** (Stage 3).
- After each stage, test on a real tablet before moving on.

---

## System prompt / project context (set once)

> You are helping me build a local creature-brawler for my two kids (Chloe, 10 — precision/builder;
> Ryan, 9 — loves Minecraft/Sonic/Powder Toy and combining ingredients to cause reactions), in
> Godot 4 (GDScript, 2D only). **Read `00_FAMILY_TRUTH.md` first — it overrides every other doc.**
> The full vision is in 01_GAME_DESIGN.md, technical constraints in 02_TECHNICAL_SPEC.md, art and
> the all-important Worm Builder in 04_ART_AND_WORM_BUILDER.md, code to borrow in
> 05_BORROWED_CODE_REFERENCES.md. The kids call it a "worm," not a snake; the body is chunky and
> segmented, not a thin line — use "worm" everywhere they can see.
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
> For assets follow 09_ASSET_GENERATION.md: generate graphics as flat SVG primitives I can tint and
> combine in code (layered pieces — body, eyes, mouth, spikes — not finished art), and use the
> bfxr2 / sfxr procedural approach for sound. Never use paid AI asset generation; keep audio
> offline-capable. Ask me before introducing any dependency or deviating from the spec. Do not use
> "/*" style comments in code.

---

## Stage 1 — Project skeleton + one worm at 30 Hz

> Set up the Godot 4 project skeleton matching 02_TECHNICAL_SPEC.md. Then implement one worm:
> touch/swipe steering, segment-following body, movement that advances only on a fixed 30 Hz physics
> tick (Engine.physics_ticks_per_second = 30), with render interpolation so it looks smooth at 60
> FPS. Placeholder colored rectangles for sprites. Give me a single test scene I can export to the
> Android tablet, and tell me exactly how to export and sideload the APK. Goal: confirm the worm
> moves smoothly on the real tablet before building anything else.

## Stage 1.5 — The Worm Builder (ship this to the kids FIRST)

> Build the Worm Builder screen from 04_ART_AND_WORM_BUILDER.md. No-reading, tap-only: tap a segment
> to select it, tap a color from a ~14-swatch palette to paint it, tap a shape (rectangle, oval,
> circle, diamond, pentagon, triangle, star) to change its form, tap a face for the head, big +/−
> icon buttons to add/remove segments. Also offer a few visible body types (speedy, or
> heavy/spiky/armored/robot) per 06_DESTRUCTION_AND_FAIRNESS.md — pictures, never text or stats —
> so one kid can choose fast and another tanky. IMPORTANT per 00_FAMILY_TRUTH.md: body types are a
> playstyle CHOICE, a sidegrade, never a power tier. Tint one flat shape sprite per shape in code
> from the fixed palette. Save each kid's worm locally. No networking — runs standalone so I can put
> it in front of my kids this week. Make it juicy: satisfying taps, sounds, a worm that wiggles.
> This is the feature they care about most; give it real polish.

## Stage 2 — Eating & evolution (the body is the scoreboard)

> Implement eating and evolution, the spine (see 01_GAME_DESIGN.md). Food (leaf, flower, apple —
> Chloe's three) spawns; a worm eats by touching it. Eating grows the worm and advances it through
> visible stages: Tiny → Fast → Spiky → Dragon → Mega, each a clear sprite and size change carrying
> the kid's chosen colors and face through every stage. NO numbers, no XP bar, no meter — the worm's
> own size and form is the only indicator. This stage is single-player for now; evolution state is
> authoritative (it'll be host state once networking lands). The point: a glance tells you who's
> doing well, nothing bolted on top.

## Stage 3 — THE SOLO HOOK: baddies + a boss + an unlock ("done enough" milestone)

> This is the milestone that must beat Slither.io. Build a complete single-player loop in one arena:
> (1) waves of simple NPC **pests** to chase and smash (from 07_NAME_ENEMIES_WEAPONS.md — Crumbs,
> Hoppers, Stink Beetles) — easy, satisfying, screen-filling fun; (2) a **boss** that a single worm
> can beat — destructible segments, telegraphed attacks readable by one kid alone, scales up later
> for co-op (design the scaling hook now, per 00_FAMILY_TRUTH.md: every boss is soloable AND
> co-opable); (3) beating the boss **unlocks a blueprint** — a new worm part that appears as a new
> option in the Worm Builder, permanently and freely (Creative-mode style). CRITICAL fairness rule
> (00_FAMILY_TRUTH.md): the unlocked part is a VARIETY sidegrade, never a power boost — apply the
> fairness filter. Add a couple of starter **comedic loss** animations for when the worm is beaten
> (eaten-and-popped-out, launched-off-screen) — losing must be funny, never grim. This whole loop is
> solo and needs no networking. The test: would Chloe, bored of Slither.io, replay this alone?

## Stage 4 — Combination combat (Ryan's Powder-Toy hook: bounded emergence)

> Implement the combination weapon system per 00_FAMILY_TRUTH.md and 07_NAME_ENEMIES_WEAPONS.md.
> Design it as BOUNDED EMERGENCE: a small fixed set of hidden property TAGS — start with exactly
> four: fire, gas, mass, bounce — and each weapon/ingredient carries one or two tags. Combinations
> resolve by pairwise rules on tags, not on specific items (e.g. fire+gas → big blast, mass+bounce →
> wrecking ball). The kids think in ITEMS (eat the pepper, then the fizzy drink); the engine thinks
> in TAGS. Build the full pairwise interaction grid as a single data table I can read on one page
> and eyeball for unfun/broken pairs. HARD RULE: every unhandled pair has a safe default (both
> effects just happen, no special combo) so there is never a broken/crashing state — worst case is
> "boring," never "broken." Implement the starter items from doc 07's eating-based and body-based
> weapons, each as a clear icon/shape, no text. Wide-area low-precision options skew to the trailing
> worm (invisible catch-up — never label it). Do NOT reintroduce the deleted generic kit (plain
> bomb/shield/speed/magnet). All explosions are sprite-frame animations, never particle systems
> (except you may spend a particle/shader splurge on the single biggest spectacle beat per
> 00_FAMILY_TRUTH.md). Keep the tag count at four until the kids are clearly hungry for a fifth.

## Stage 5 — The bestiary (behavioral variety) + arena picker

> Add the full enemy roster from 07_NAME_ENEMIES_WEAPONS.md, grouped by BEHAVIOR so each forces a
> different reaction: pests (already started), a thief (Gulls that snatch food), a bully (Boulder
> Bugs, eaten only from the soft back end), a chaos-maker (Gloop or Magnet Mites). Spawn pests
> frequently, thieves/bullies occasionally. Then build the main menu as an arena PICKER: the kid
> taps a picture of a place, no text, no rule selection — the arena bundles its rules invisibly.
> Build the first proper arena (Green Hill): loops, ramps, Sonic-style speed pads, one moving
> hazard. Confirm we're under 200 active objects and on the single atlas. Re-confirm framerate on
> the tablet.

## Stage 6 — More creature-feeding progression (the patient loop, still solo)

> Begin the patient progression from 08_THE_SECRET.md, re-scoped per 00_FAMILY_TRUTH.md. Add a calm
> Home screen (a place, not a menu) backed by persistent data/home_state.json storing, per kid, each
> creature's care level and diet-lean and which blueprints are unlocked — NEVER an item list, NO
> inventory of any kind. At round end, collected food is fed into the creature in ONE tap; what you
> feed determines what it becomes via a visible diet-lean: metal/scrap/electronics → ROBOT (Ryan),
> leaves/fruit/bugs → ANIMAL (Chloe), seeds/flowers → PLANT. The lean is a DRIFT not a lock — one
> wrong feed never ruins days of work. Care level rises when fed, slowly falls when ignored; the
> creature SLEEPS, never dies. Hatching unlocks a rare blueprint (a part/companion). FAIRNESS FILTER
> applies: everything the creature yields is VARIETY, never versus power. This runs alongside
> boss-womping (Stage 3) — both feed the same blueprint pool; boss-womping is the fast loop,
> creature-feeding the patient one. Still solo; no networking yet.

## Stage 7 — Two worms over LAN (the reunion mode — NOW we network)

> Now add two-player versus over LAN, host/client per 02_TECHNICAL_SPEC.md. Base LAN discovery on
> the GodotEasyLAN broadcast pattern (05_BORROWED_CODE_REFERENCES.md): host broadcasts its IP plus a
> room code over UDP to the subnet broadcast address; client listens, lists hosts, connects via
> Godot high-level multiplayer using the broadcast IP — nobody types an IP. Account for the
> 255.255.255.0 subnet requirement and known Android LAN quirks; we test on real tablets. Implement:
> (1) ENet host/client, host authoritative over all state; (2) host broadcasts snapshots at 15 Hz of
> each worm's head position, direction, length, evolution stage; (3) client interpolates with a
> ~100ms buffer; (4) client-side input prediction on its own worm with reconciliation. Keep the
> payload tiny. CRITICAL fairness enforcement (00_FAMILY_TRUTH.md): when a versus match starts, BOTH
> worms start at equal baseline power regardless of solo progression — the only things that carry in
> are VARIETY (which unlocked parts/tools each kid chose), never stats. Both worms must move smoothly
> on both tablets with no rubber-banding on the local worm. Walk me through testing with two real
> tablets. Get this rock solid before adding versus content.

## Stage 8 — Versus polish: comedic losses + victory moment + invisible catch-up

> Flesh out the versus reunion. Add the full comedic-loss BANK from 00_FAMILY_TRUTH.md (eaten,
> launched, deflated-to-noodle, balloon-drift, scattered-beads, flattened-reinflate) fired
> situationally and semi-randomly so loss is a funny surprise every time — Ryan loves funny, and a
> funny loss teaches Chloe grace with no words. Add the victory MOMENT (winning worm's animation,
> screen, music — like Smash's "GAME!" zoom), no scoreboard, no badge, no persistent leader status
> during the round. Implement the invisible catch-up: the trailing worm's powerup table skews to the
> big, low-precision, satisfying toys (06_DESTRUCTION_AND_FAIRNESS.md) — never a visible setting. Add
> the Ultimate meter that fills from eating, landing hits, AND taking damage (the kid getting hit
> charges faster — invisible catch-up); each body type flavors its ultimate: Mega Worm (tank), Sonic
> Coil (speed), Swarm Split (trickster). The fairness test, every time: would the kid who lost the
> last two rounds still want a third?

## Stage 9 — Co-op boss mode (shared bosses, where nobody loses)

> Add co-op: both kids team on a boss together over LAN. Reuse the soloable bosses from Stage 3/5
> but SCALE them up for two worms (more health, more/faster telegraphed attacks) per
> 00_FAMILY_TRUTH.md — every boss is soloable AND co-opable, so this is scaling existing encounters,
> not new ones. Dropping the boss rewards BOTH players (a blueprint unlock or shared food burst).
> This is the no-one-loses space and the place power progression is allowed (PvE only). Make it a
> "did you see that?!" moment through animation and sound — this is where you may spend the
> spectacle budget. Stay within the object budget; boss + segments count against the 200.

## Stage 10 — Hotspot mode (no router)

> Implement the no-router path: the host tablet creates a Wi-Fi hotspot, the client joins it, and the
> Stage 7 UDP discovery finds the host. Testable with no router present. Walk me through testing on
> two real tablets away from my home network. Handle failure cases (hotspot not up yet, client on
> wrong network) with kid-friendly VISUAL feedback, not error text.

## Stage 11 — The Garden + karma leak (cooperation, pervasive but recessive)

> Add the Garden from 08_THE_SECRET.md, re-scoped per 00_FAMILY_TRUTH.md. A shared plot on the Home
> screen; both kids plant/water with one tap each, no management. It only blooms if BOTH kids
> contributed since the last bloom — cooperation gated. A bloom does NOT stay quarantined on Home: it
> LEAKS INTO THE BRAWL — it rains rare food into the next match, FOR BOTH KIDS EQUALLY (karma leaks
> delight, never power; fairness filter applies). Also let a hatched companion (Stage 6) appear
> mid-match as ambient delight, not advantage. The cause→effect link is NEVER surfaced — no
> notification, no "you cooperated, here's a reward." It just happens; the kids feel the pattern over
> time. This is the karma layer: the world reliably rewards care and cooperation without ever saying
> so. Keep it pervasive but recessive — the brawl is still the dominant on-screen game.

## Stage 12 — Polish layer

> Add the remaining polish from 01_GAME_DESIGN.md, each a separate small task: (1) a replay buffer
> storing the last ~30 seconds; (2) bot fill so a single kid can play VERSUS an AI worm when the
> sibling's away (note: solo PvE already exists from Stage 3 — this is specifically an AI opponent
> for the versus mode); (3) a sticker book that fills as the kids discover worm parts and arenas
> (collection, no currency, no inventory); (4) a hidden parent screen — the one place text is allowed
> — showing wins, streaks, tournament history in data/tournament.json. Keep all of it off the kids'
> gameplay screens.

---

## Ongoing guardrail prompt (paste when Claude drifts)

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
