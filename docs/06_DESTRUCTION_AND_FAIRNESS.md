# Worm Wars — The Destruction Layer & Fair Fight (v2, Ryan's half)

> Read `00_FAMILY_TRUTH.md` first. This v2 folds in the fairness linchpin and the Powder-Toy
> correction to Ryan's combat.

Chloe defined how the worm looks and how you build it. Ryan defines how it *fights*. But the v1
version of this doc slightly mis-cast him. Correcting that is the heart of v2.

## The correction: Ryan mixes ingredients, he is not handed explosions

Ryan loves **Powder Toy** — and Powder Toy is not about big dumb explosions handed to you. It's
about **combining ingredients to cause reactions you discover.** v1 gave Ryan a flat list of
finished area weapons (a bomb with a big radius). That's the right *aesthetic* but the wrong
*verb*. The verb is **mix and discover.**

So Ryan's combat is a **bounded-emergence** system (full spec in `00_FAMILY_TRUTH.md`):
- A few hidden **property tags** — start at exactly four: `fire`, `gas`, `mass`, `bounce`.
- Weapons/ingredients carry tags. Chili breath = fire; bubble burp = gas; boulder swallow = mass;
  booster = bounce.
- Combinations resolve by **pairwise tag rules** (fire+gas → big blast; mass+bounce → wrecking
  ball). The kids think in **items**; the engine thinks in **tags.**
- The whole interaction grid is **enumerable on one page** and **safe-by-default** (unhandled pair =
  both effects just happen, never a crash). Powder Toy's surprise, none of its chaos.

This gives Ryan the thing he actually wants — "I combined these and something new happened" — while
staying simple on its face and fully controlled underneath.

## The fairness linchpin (the most important constraint in the project)

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

This protects the fight from becoming a pay-to-win treadmill between siblings. Full reasoning,
including the diligent-kid tension, in `00_FAMILY_TRUTH.md`.

## The core tension (and why it's the solution)

Ryan wants to be the one destroying, but he's the baby (9 to Chloe's 10) and burns out if she can
dunk on him repeatedly. A game about *precise* combat would be a machine for making Ryan lose. So
the design gives him destruction that **doesn't require precision**, and catch-up that is
**invisible** — kids smell a pity handicap, and a visible "baby setting" stings worse than losing.

The elegant part: **Ryan's aesthetic IS the comeback mechanic.** Catch-up works the Mario Kart way —
the kid who's behind invisibly gets the better, bigger, more satisfying toys. Make those toys the
mixable destruction Ryan loves. He never feels slow, because falling behind hands him exactly the
toys he wants.

> Note on Chloe: she hates losing to Ryan, and per `00_FAMILY_TRUTH.md` that's **a flaw to correct,
> not enable.** We do NOT solve it by letting her always win or by making catch-up visible so she
> approves of it. We solve it by (a) keeping catch-up invisible so there's nothing to resent, (b)
> making loss *hilarious* so it stings less, and (c) letting the karma/care layer quietly reward
> grace and cooperation. The game teaches grace by how the world behaves, never by lecturing.

## Design rules that protect the slower kid (without announcing it)

### 1. Wide-area, low-precision weapons skew to whoever's behind
The trailing worm's powerup table favors big-blast-radius bombs, spike walls/armor you ram, robot
stomps that hit everything nearby, radiating shockwaves. Chloe's precision advantage matters less
when the weapon forgives bad aim. Mario Kart's blue-shell logic, reskinned as Ryan's mixing
fantasy. **Invisible — never a labeled setting.**

### 2. Destruction is its own reward, separate from winning
Ryan breaks stuff, sets off reactions, smashes the arena **whether or not he's ahead.** "Did I blow
things up / discover a cool combo?" is a different axis from "did I win?" A round where Ryan's worm
was smaller but he chained three reactions and wrecked a wall was a good round *for him.* Decoupling
joy from victory is the actual burnout fix.

### 3. The boss is the shared-win space — AND a solo staple
Co-op against a boss is the one mode where neither sibling loses. But per `00_FAMILY_TRUTH.md`,
**bosses also scale down to solo** — Ryan fights them alone constantly as the daily loop, and they
scale up when the two team. Make boss encounters frequent. This is where Ryan is the hero with no
downside.

### 4. "Slow" becomes a build, not a deficiency
The Worm Builder lets a kid grow toward Faster / Tougher / More Boosts. Let Ryan build a **heavy,
tanky, explosive bruiser** — slow but hard to kill, hits like a truck. Slowness is a playstyle he
*chose*, not a thing he *is*. Smash runs entirely on this — nobody calls Bowser the "bad at games"
character. Surface it in the builder as a visible body type. **Crucially (fairness filter): a body
type is a sidegrade, never a power tier** — the tank isn't *better*, it's *different*, and it does
not start a versus match stronger.

## Ryan's art & asset additions

All follow the budget rules (single atlas; sprite-animation explosions, not GPU particles — except
the sanctioned spectacle splurge per `00_FAMILY_TRUTH.md`).

### Weapons & destruction (each carries property tags)
- **Bomb** — round bomb sprite, big sprite-animation blast. (tags: fire)
- **Spike armor / spike ball** — spikes layered on the body. (tags: mass)
- **Gun / blaster** — a "fancy gun" segment firing a simple projectile. (tags: fire)
- **Robot parts** — a robot worm skin (mechanical segments, glowing eyes) for the builder.
- **Shockwave ring** — expanding ring sprite. (tags: bounce)
The tags are what make these *combine* — that's the Powder-Toy layer.

### Breakables in the arena
Crates, walls, pillars, barrels that explode; destructible boss segments; "smashable" props that pop
with a sprite animation and a sound. A whole layer of fun that doesn't depend on beating Chloe
(feeds rule #2).

### The "Mega" ultimate is his moment
The Mega Worm ultimate (gigantic, crushes everything, explosions everywhere for ~10s) is tailor-made
for Ryan. Low precision, maximum spectacle. The meter fills partly from *taking* damage, so the kid
getting hit charges faster — invisible catch-up that reads as "awesome," not "assistance." This is a
fine place to spend the spectacle budget (shaders/particles allowed here specifically).

## The fairness test (guardrails)

Alongside the no-reading test, every combat/catch-up/unlock decision must pass BOTH:

> 1. Would the slower kid still want a third round after losing the first two? If a mechanic only
>    feels good when you're winning, it's wrong. The trailing kid must have the most fun toys.
> 2. (v2) Does anything a kid unlocked through solo grinding make their VERSUS worm stronger rather
>    than just different? If yes, it's a violation — fix it. Versus worms start equal.

## How this changes the two kids' roles

- **Chloe** — speed, precision, the builder, out-evolving you. The finesse player.
- **Ryan** — destruction, mixing/combining reactions, the tank build, boss-smashing, the Mega
  rampage. The power player and the chemist.
- **Together** — the boss worm (scaled up), where both win at once.
- **Apart** — each fights bosses and baddies solo as the daily loop; they reunite to brawl.

That asymmetry is the game. Two playstyles that need each other — and that, by the fairness filter,
meet as equals whenever they fight.
