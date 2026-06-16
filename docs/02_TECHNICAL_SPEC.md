# Worm Wars — Technical Specification (v2)

> Read `00_FAMILY_TRUTH.md` first. v2 changes two things here: the hardware floor (real hardware is
> strong, so the budget is a deliberate spend not a survival constraint) and the **build order**
> (solo-first — the solo hook is proven before networking). The networking architecture itself is
> unchanged and still correct; it just happens later.

## Engine decision

**Godot 4 (latest stable 4.x), 2D only.** Do not use Godot 3.5 (end-of-life). GDScript for all
gameplay — it compiles into the project, no toolchain beyond the Godot editor, the path of least
resistance for a solo/family developer.

## Target hardware (the real device, not a potato)

The actual tablet is a strong modern device (12", octa-core, ~Android 16, lots of RAM, 2000×1200
FHD). The original "potato-tier 2 GB / Android 8 / Mali" floor does **NOT** apply.

- Android (recent), touch input, landscape, high-res FHD screen.
- Treat the performance headroom as a **budget to spend deliberately,** not license for sloppiness
  (see `00_FAMILY_TRUTH.md`): keep the cheap-and-correct defaults, and splurge only on spectacle.

## Performance budget (deliberate spend, not survival)

| Constraint | Limit | Why it stays / how it changed |
|---|---|---|
| Max active objects | < 200 normal play | Still a good discipline; cheap and keeps the sim legible. Spectacle beats may briefly exceed via short-lived sprite effects. |
| Texture budget | generous | No longer VRAM-starved; still use one gameplay atlas for tidiness and few state changes. |
| Sprite atlas | Single atlas for gameplay sprites | One texture bind, minimal state changes. Kept. |
| Shaders | **Allowed ONLY for sanctioned spectacle beats** | boss death, Mega ultimate, victory moment, big comedic losses. Frugal everywhere else. (Changed from "none.") |
| Particles | **Allowed ONLY for the same spectacle beats** | Otherwise still animated sprites. (Changed from "none.") |
| Simulation tick | Fixed 30 Hz | Deterministic, cheap, network-friendly. **Kept — this is for correctness, not performance.** |
| Render | 30 or 60 FPS (decouple from sim) | Let render float, keep sim fixed. |
| Network rate | 10-20 packets/sec | Snake is low-velocity; interpolate. (Applies once networked — later.) |

Treat the *defaults* as gates and the *spectacle exceptions* as a small, named budget. If a feature
wants to break the budget outside the sanctioned beats, the feature changes.

## Architecture

### Fixed-timestep simulation
Run game logic in `_physics_process` at 30 Hz (`Engine.physics_ticks_per_second = 30`). Render
interpolation handles smoothness. All gameplay state advances only on the sim tick — identical
behavior regardless of frame rate, which is also what makes networking sane later. **This holds for
solo play too:** the solo sim is the same fixed-step sim, just with no client attached.

### Solo-first means the sim is single-player-capable from day one
The host-authoritative model below is how versus works. But the **same simulation runs solo** with
zero networking — one worm, NPC baddies, a boss, all on one device. Build the sim so "number of
human players" is a parameter: 1 (solo, no net), or 2 (host + client over LAN). NPC baddies and
bosses are driven by the sim identically in both cases. This is what lets the solo hook ship before
any networking exists, and lets bosses scale solo↔co-op cleanly.

### Host / client LAN model (for the versus reunion — built later)
- One tablet is the **host** (authoritative), runs the full simulation.
- The other is the **client** — sends inputs, renders host state.
- Host owns all truth: worm positions, food, boss, powerups, collisions, who's bigger. Clients
  predict locally and reconcile.
- Godot high-level multiplayer (`MultiplayerAPI`) over ENet (UDP). Reliable channel for events,
  unreliable for the continuous position stream.
- **Fairness enforcement at match start:** both worms begin at equal baseline regardless of solo
  progression; only *variety* (chosen unlocked parts) carries in, never stats (see
  `00_FAMILY_TRUTH.md`).

### Networking detail (unchanged, applies at the versus stage)
- Host broadcasts snapshots at 10-20 Hz: each worm's head position, direction, length, evolution
  stage, boss state, active powerups.
- Client interpolates between snapshots (~100ms buffer).
- Client-side input prediction on its own worm; reconcile on snapshot.
- Tiny payload: quantize positions, send deltas where cheap.

### Connection flow (two paths — built at the versus/hotspot stages)
1. **Router LAN** — host opens a port, UDP-broadcasts presence, client auto-discovers. No IP typing.
2. **Hotspot** — host tablet creates a Wi-Fi hotspot, client joins, same UDP discovery. The "no
   router at grandma's" mode. Zero-typing for the kids: host taps Start, client taps Join.

## Project structure

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

## Build / dev environment

- Godot 4.x editor on the dev machine.
- Android export template installed; export APK, sideload to the tablet (no Play Store).
- The real tablet for testing — and a second tablet **when you reach the versus stage** for honest
  LAN/hotspot testing. The solo hook (the first milestone) needs only one device.
- Keep a `--server` headless launch flag for debugging the host from desktop later.

## Build order (v2 — de-risk by proving the HOOK first, not the network)

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
