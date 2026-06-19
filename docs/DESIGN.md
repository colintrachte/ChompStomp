# IMPLEMENTATION_CONTRACT

# Project

Chomp Stomp

Godot 4.x

2D only

GDScript

---

# RULE 01: SOLO FIRST

Primary mode is solo PvE.

Networking is not required for initial milestones.

All core gameplay systems must function without networking.

---

# RULE 02: FAIRNESS FILTER

Persistent progression may unlock variety.

Persistent progression may not unlock combat power.

Forbidden persistent advantages:

* damage
* health
* speed
* armor
* starting size
* starting evolution
* cooldown reduction

Allowed unlocks:

* cosmetics
* sidegrades
* blueprints
* faces
* body styles
* companions
* transformations

---

# RULE 03: DELIGHT NOT POWER

Garden, creature, and karma systems may create:

* visual events
* companions
* alternate food
* cosmetic transformations
* environmental effects

They may not create:

* combat advantages
* stat increases
* starting bonuses

---

# RULE 04: NON-READER DESIGN

Gameplay screens must communicate through:

* size
* color
* shape
* animation
* sound

Avoid:

* text
* numbers
* XP bars
* currencies
* scoreboards

Parent-only screens are exempt.

---

# RULE 05: THE BODY IS THE SCOREBOARD

Winning is represented through:

* size
* evolution stage
* transformation

Never through crowns, badges, or score displays.

---

# RULE 06: LOSING IS FUNNY

Loss events should use a randomized animation bank.

Examples:

* balloon
* launch
* bead scatter
* flatten
* swallow and eject

Losses should feel comedic rather than punitive.

---

# RULE 07: CUSTOMIZATION IS A PILLAR

The Worm Builder is a core feature.

Every worm supports:

* per-segment color
* per-segment shape
* face selection
* body style selection

Supported shapes:

* rectangle
* oval
* circle
* diamond
* pentagon
* triangle
* star

---

# FACE ABILITIES

These are flavor abilities.

They exist primarily to reinforce identity and personalization.

| Face      | Effect                                |
| --------- | ------------------------------------- |
| Tongue    | Food becomes lollipops temporarily    |
| Orange    | Food becomes oranges temporarily      |
| Cat       | Food becomes paws temporarily         |
| Bunny     | Food becomes bunny treats temporarily |
| Fish Tank | Food becomes goldfish permanently     |
| Winking   | No effect                             |
| Egg       | Food becomes bacon temporarily        |
| Butterfly | No effect                             |
| Astronaut | Food becomes moons temporarily        |

These abilities must not violate the Fairness Filter.

---

# COMBINATION SYSTEM

Initial tags:

* fire
* gas
* mass
* bounce

Items carry one or more tags.

Combinations resolve using tag-pair rules.

Players interact with items.

Engine operates on tags.

Unhandled combinations:

* execute both effects
* never fail
* never crash

---

# ART DIRECTION

Flat colors.

Chunky worms.

Readable silhouettes.

High contrast.

One atlas.

Runtime tinting.

No realistic art.

No visual clutter.

---

# FOOD

Starter foods:

* leaf
* flower
* apple

Additional transformation foods:

* lollipop
* orange
* paw
* bunny treat
* goldfish
* bacon
* moon

---

# PERFORMANCE

Target:

* under 200 active objects
* fixed 30Hz simulation
* render decoupled from simulation

Particles and shaders reserved for:

* boss deaths
* ultimate attacks
* victory moments
* major loss animations

---

# BUILD ORDER

1. Project skeleton
2. Worm movement
3. Worm Builder
4. Food and growth
5. Evolution system
6. Enemy pests
7. Boss encounter
8. Blueprint unlocks
9. Combination combat
10. Additional arenas
11. Creature progression
12. LAN networking
13. Versus
14. Co-op bosses
15. Garden
16. Karma
17. Replay system
18. Bot fill
19. Tournament tracking

---

# SUCCESS CRITERIA

The game is successful when:

* a kid can build a worm
* a kid can recognize their worm instantly
* solo play is fun without networking
* bosses unlock new customization options
* progression creates identity rather than power
* a losing player still wants another round
