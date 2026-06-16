# Worm Wars — Asset Generation (Sound & Graphics Without Being Good At Either)

The constraint: you are not a game artist or audio engineer, and you want asset creation to be procedural / AI-driven and either free or already part of Claude. Good news — for this specific game, the cheap procedural path is also the *correct* path aesthetically. Do not pay for AI asset generation. Here's the whole pipeline.

## Sound: procedural, embedded, free, offline

**Use the sfxr / bfxr2 procedural engine, not AI audio generation.** Here's why it wins for this game specifically:

- It generates exactly the palette a kids' game needs — chomps, pickups, zaps, explosions, jumps, pops — from math, instantly.
- It is **free and open source** (Apache 2.0 for the original bfxr), so the generator code can go *inside* your game. bfxr2 (March 2025) is a JavaScript reworking; sfxr has ports in C#, C++, and more.
- It runs **offline on the tablet** — no API, no cloud, no per-sound cost ever.
- It is **deterministic**: the same seed produces the same sound. This matters for your persistence/secret system and for keeping the build reproducible.
- The retro chiptune character is the perfect match for flat-shape kid graphics. AI-generated cinematic SFX would actually clash with the art.

AI sound generators, by contrast, are mostly freemium and cloud-dependent — wrong on cost and wrong on offline. Skip them.

### Two ways to use it
1. **Bake at build time (simplest):** Use the bfxr2 web app to generate each sound, export WAV/OGG, drop into `assets/audio/`. Free, zero code, you just click "explosion" and tweak until it's funny. Good enough to ship.
2. **Generate at runtime (the procedural dream):** Port the sfxr synthesis into the game (Godot can synthesize audio from a parameter set). Then each weapon/enemy carries a small parameter set or seed, and the sound is generated live. Infinite variation (every explosion slightly different), tiny storage (you store seeds, not WAV files), and it ties into the worm-builder idea — a kid's custom worm could even have a seed-derived voice. Build path #1 first; graduate to #2 if you want the variation.

### Music
For background music, the same philosophy: a simple procedural/generative chiptune loop (there are small open-source chiptune music libraries) beats licensing tracks. Keep it minimal — a calm loop for the Home screen, an up-tempo one for rounds. Lowest priority; do it last.

## Graphics: Claude generates flat SVG primitives, code does the rest

This is the part that is **already part of Claude** — you have the generator in this chat. The art spec (doc 04) already commits to flat colors, thick outlines, single shapes tinted in code. That is not a limitation that happens to be cheap; it is *exactly* what Claude produces well as SVG, for free, right now.

### Why this works
- A worm segment, a leaf, an apple, a chili pepper, a Boulder Bug, a victory burst — these are simple SVG paths. Claude can generate them on request.
- Because everything is **tinted in code** (doc 04), one SVG shape becomes all 14 colors. You generate the shape *once*.
- Because the worm and enemies are **built from combinable primitives** (a circle body + spikes + eyes + a face), Claude generates a *kit of parts* and the game assembles huge variety from a small set. That is the procedural generation you wanted, and it's native to how the Worm Builder already works.

### The pipeline
1. Ask Claude to generate each primitive as a flat SVG: segment shapes (rectangle, oval, circle, diamond, pentagon, triangle, star), faces, food, each enemy, weapon icons, the victory burst, effect frames.
2. Keep them as layered primitives, not finished art — body / eyes / mouth / spikes as separate pieces the game can mix.
3. Convert to the single sprite atlas (doc 02/04). SVGs rasterize cleanly to whatever tablet resolution you need.
4. Tint and combine in code. One shape set covers all colors and many creatures.
5. Animate with sprite frames (doc 02 forbids particle systems and gameplay shaders) — Claude can generate the 2-4 frames of an animation (e.g. a chomp open/closed, an explosion's grow/burst/fade) as a small SVG sequence.

### Procedural assembly = endless content for free
The combination of "primitives + code tinting + code assembly" means new enemies and worm parts cost almost nothing: a new creature is often just a new arrangement of existing primitives in a new color. The bestiary in doc 07 can grow indefinitely without new art commissions — you're recombining a kit, exactly the procedural approach you asked for.

## What you never have to do

- You never draw by hand.
- You never pay an AI image API.
- You never license a sound pack.
- You never become a game artist or audio engineer.

Sound comes from a free procedural engine that runs offline. Graphics come from Claude as flat SVG primitives that the game tints and assembles. Both are procedural, both are cheap-or-already-yours, and both are the right aesthetic rather than a compromise.

## How this feeds the build

When you reach art/audio in any stage prompt, add:

> Generate the graphics as flat SVG primitives I can tint and combine in code (per doc 04 and doc 09) — give me layered pieces (body, eyes, mouth, spikes) not finished art, so the game assembles variety from a small kit. For sound, use the bfxr2 / sfxr procedural approach (per doc 09): either baked WAV/OGG from the bfxr2 web app, or synthesized at runtime from a small parameter set per effect. Do not use any paid AI asset generation, and keep all audio offline-capable on the tablet.
