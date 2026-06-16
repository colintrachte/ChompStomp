# Worm Wars — Name, Enemies, Weapons & Powerups (v2)

> Read `00_FAMILY_TRUTH.md` first. v2 adds property TAGS to the weapon roster (the bounded-emergence
> combo system), makes bosses scale solo↔co-op, and adds the comedic-loss bank.

The brief: a great name, enemies of genuinely different *kinds*, and weapons/powerups that aren't
the boring standard kit. The rule throughout: **cut anything you've seen in a hundred other games
(plain bomb, plain shield, plain speed-up, plain magnet), and replace it with something that only
makes sense because you are a segmented worm that eats and grows.** The worm's own nature is the
idea engine.

---

## 1. The Name

"Worm Wars" is a placeholder. The real name should capture the actual fun: building a goofy creature
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

## 2. The Bestiary (enemies of different *kinds*)

The arena is the third player — and in a solo-first game, it's most of the game most of the time.
The point of a roster is **behavioral variety, not skins** — each enemy forces a different reaction.
Grouped by the job they do. All sprite-animated, no shaders, within the object budget.

### Little pests (fill the arena, easy to smash, satisfying — the solo loop's bread and butter)
- **Crumbs** — tiny scuttling bugs that flee. Pure chase-and-pop snacks. Keep the screen busy.
- **Hoppers** — frogs that jump in arcs; time a chomp as they land. Teaches timing, no tutorial.
- **Stink Beetles** — pop them and they leave a cloud that makes you *sneeze* (a tiny random wiggle
  for 1 second). Annoying, funny, harmless.

### Thieves (create conflict, raise the stakes)
- **Gulls** — swoop, snatch a piece of food, try to fly off. In versus, both kids race the same
  gull; in solo, a sudden "stop it before it escapes" goal.
- **Pocket Moles** — pop up, swallow a powerup, burrow away. Chomp the mole fast → powerup back
  *plus* a bonus.

### Bullies (push you around, area denial)
- **Boulder Bugs** — armored roly-polys that charge straight and bowl worms over. Eaten only from
  the soft back end — outmaneuver, don't ram.
- **Spitters** — rooted plant-worms lobbing slow blobs you weave around. Turn an open arena into a
  dodge course.

### Chaos-makers (change the whole arena state)
- **Gloop** — a slow blob leaving sticky trails; touch one and you crawl slow a moment. Slowly
  paints the arena into a maze.
- **Magnet Mites** — metal bugs that drag loose food/powerups toward them. Pop them → everything
  they hoarded scatters at once.

### The bosses (scale SOLO ↔ CO-OP — daily solo staple AND the team-up moment)
Per `00_FAMILY_TRUTH.md`, **every boss is beatable by one worm and more fun with two.** Health and
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

## 3. Weapons (built from being a worm — and now they CARRY TAGS so they combine)

These replace the generic kit. Each only works because you're a long, segmented, eating creature.
**New in v2:** each carries one or two **property tags** (`fire`, `gas`, `mass`, `bounce` — start
with these four) so weapons **combine** via the bounded-emergence grid in §3.5. The kids think in
items; the engine resolves tags.

### Eating-based (you swallow, then weaponize it)
- **Chili Pepper Breath** — eat a pepper, breathe a cone of fire for a few seconds. (tags: **fire**)
- **Bubble Burp** — swallow a fizzy drink, burp a big bubble that traps the other worm a moment.
  Silly, low-precision, great catch-up tool. (tags: **gas**)
- **Boulder Swallow** — eat a rock, your head becomes a wrecking ball: smash walls, enemies, bounce
  the other worm. Slow but unstoppable. (tags: **mass**)
- **Spicy Hiccups** — eat something too spicy, involuntarily *spit pepper seeds* in random
  directions like a shotgun you can't aim. (tags: **fire**, light)

### Body-based (you ARE the weapon — uses the segments)
- **Tail Whip Slam** — crack your whole tail like a whip, knocking back an arc. Longer = bigger arc;
  growth *is* the upgrade. (tags: **mass**)
- **Spike Mode** — every segment sprouts spikes; ramming hurts *them*, not you. (tags: **mass**)
- **Shed Skin** — drop your tail segments as a wall of obstacles, keep going shorter and faster. A
  real trade, not a button. (tags: **bounce** on the shed trail)
- **Coil Trap** — curl into a spring and launch in a straight line, a dash you aim by curling.
  Chloe's precision tool. (tags: **bounce**)

### Build-it weapons (from the Worm Builder body types — sidegrades, never power tiers)
- **Robot Arm Segment** — a builder part: one segment becomes a mechanical arm that grabs and yanks
  the other worm toward you. (tags: **mass**)
- **Booster Segment** — a rocket segment: a burst of speed on tap, overheats if spammed. (tags:
  **bounce**, **fire** exhaust)

### 3.5 — The combination grid (bounded emergence — see `00_FAMILY_TRUTH.md`)
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

## 4. Powerups (the absurd, memorable kind — standard kit deleted)

**Deleted on purpose:** plain speed-up, plain shield, plain invincibility star, plain magnet, plain
extra-points. Where an idea survives, it's twisted into something with a catch or a joke.

### Transformations (the worm becomes something ridiculous)
- **Slinky Mode** — super-bouncy and stretchy, flinging around like a rubber band. Briefly
  unkillable because unpredictable. (tags: **bounce**)
- **Balloon Worm** — inflate and float over hazards/walls — but a single chomp pops you. (tags:
  **gas**)
- **Train Mode** — segments separate into a steerable choo-choo convoy; ram the other worm to
  decouple *their* segments. (tags: **mass**)
- **Magneto-Worm** (twisted magnet) — pull the *other worm* toward you, not food. A grab attack.
  (tags: **mass**)

### Arena-changers (the powerup changes the world, not just you)
- **Gravity Flip** — arena gravity rotates; everyone slides to a new wall. Spectacle over advantage.
- **Lights Out** — arena goes dark except a glow around each worm. Hide-and-seek. Resets a runaway
  lead for free.
- **Food Rain** — it rains leaves, flowers, apples for a few seconds. Everyone feasts at once — a
  deliberate "catch-up by abundance" moment. (This is also exactly what a bloomed garden triggers —
  see karma leak, doc 08.)
- **Tiny Town** — everything shrinks; the arena feels huge and mazey. Pure novelty.

### The "behind kid" specials (catch-up disguised as awesome, per doc 06 — invisible)
Weight toward whoever's smaller/behind. Read as "I got the cool one," never a handicap.
- **Mega Munch** — your mouth becomes enormous; eat anything, including chunks of the other worm, in
  one gulp. The comeback dream. (Also a comedic-loss trigger — see §6.)
- **Copycat** — instantly copy whatever powerup the *leading* worm last used. Fairness as a power
  fantasy.
- **Underdog Roar** — a screen-shaking roar that stuns everything nearby and clears a path. Loud,
  dumb, satisfying — handed to whoever's losing.

### The Ultimate (one per worm, earned not picked up)
Fills from eating, landing hits, and taking damage (kid getting hit charges faster — invisible
catch-up). Body type flavors it:
- **Mega Worm** (tank) — a colossal kaiju worm; everything you touch explodes ~10s. Ryan's. (Spend
  the spectacle budget here.)
- **Sonic Coil** (speed) — blinding speed, a damaging light trail, pass through anything. Chloe's.
- **Swarm Split** (trickster) — split into several small worms, recombine when the timer ends. A
  third option so the choice isn't just "fast vs strong."

---

## 5. The comedic loss bank (NEW in v2 — content category, not one asset)

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
Pair each with a distinct bfxr2 sound (doc 09). These are the single best cheap investment in making
losing okay for the bossy kid.

---

## 6. The one principle to keep

When tempted to add a weapon or enemy, run it through: **"Could this exist in any game, or only in a
game about a segmented worm that eats and grows?"** Plain gun, plain shield → cut or twist. Shed your
tail, swallow a rock, split into a swarm → keep. And the v2 addition: **does this weapon carry a tag
so it can COMBINE?** If it's a one-off with no tag, ask whether giving it a tag would make it part of
Ryan's chemistry set. The combination grid is the well that never runs dry.
