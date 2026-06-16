# Worm Wars — Art & Asset Spec (The Worm Builder)

This spec is driven by Chloe's design drawing. She spent days on it, and it is the clearest statement of what the kids actually want. Her headline request is not the gameplay — it's **building their own worm**. That feature is a core pillar of the game.

Note on naming: Chloe calls it a **worm**, not a snake. Use "worm" everywhere the kids can see. The body should be **chunky and segmented**, not a thin line.

## What Chloe asked for (decoded from the drawing)

1. **"The worms eat"** — food is a leaf, a flower, and an apple. Use those three as the starter food sprites.
2. **"Can you make it look like this"** — a fat, segmented worm body with a simple face on the head. Chunky segments, visible divisions between them.
3. **"And can you make it so that we can make the worm how we like it"** — the Worm Builder. The kids assemble a worm from parts they choose.
4. **COLORS** — a palette grid of about 14 colors to paint segments.
5. **Shapes** — segments come in different shapes: star, circle, oval, diamond, pentagon, triangle, rectangle.
6. **FACES** — a row of selectable faces for the head.
7. The big scribble is labeled "don't mind this." Respected and ignored.

## The Worm Builder screen (new core feature)

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

## Asset list (single atlas, simple readable shapes)

Per the performance budget: one sprite atlas, no shaders, no particles, under 200 active objects. Everything below is a simple flat shape a non-reader can tell apart instantly.

### Food (start with Chloe's three)
- Leaf (green)
- Flower (yellow)
- Apple (red)
- Boss Food (giant version of any — watermelon/cake later)

### Feed-type collectibles (for the secret's diet system, doc 08)
These also appear in arenas; *what the kids collect most* decides what their creature becomes. Each is a clear flat shape, no text:
- **Animal feed** (Chloe's path): the leaf/flower/apple above, plus bugs and berries.
- **Robot feed** (Ryan's path): bolts, scrap metal, batteries, circuit bits.
- **Plant feed**: seeds, acorns, sprouts.
Generate them as the same flat-primitive style; they double as ordinary in-round food and as the diet signal for the creature at Home.

### Worm segment shapes (the builder palette)
- Rectangle (Chloe's most-used)
- Oval
- Circle
- Diamond
- Pentagon
- Triangle
- Star (she drew it in the shape row)
Each shape is a single flat sprite, tinted at runtime by the chosen color, so one sprite covers all 14 colors. This keeps the atlas tiny.

### Color palette (about 14, matching her grid)
blue, yellow, purple, green, white, black, red, brown, pink, orange, grey, dark-blue, teal, magenta. Tint segments in code from this fixed palette so the swatches and the worm always match.

### Faces (the head)
A row of simple faces, each a tiny flat sprite overlaid on the head segment:
- sleepy / content (eyes closed, drawn first)
- surprised (open mouth)
- cat (whiskers + ears)
- bunny (long ears)
- plain smile
- silly / tongue-out
Keep them to single-color line faces so they read at tablet size.

### The victory moment (not a crown)
There is no crown sprite. Round wins are shown as a moment, not an object: the winning worm needs a **victory animation** (a celebratory wiggle/pose), a burst of celebratory sprite-frame effects, and a "winner" splash that fills the screen with that worm — its colors and face front and center. This is the Smash "GAME!" zoom equivalent. No badge sits on the worm during play.

### Evolution stages (visible transformations)
Tiny → Fast → Spiky → Dragon → Mega. Each stage is a size step plus an added feature sprite (spikes, wings) layered on the existing segments, so the kid's chosen colors/face carry through every evolution.

## Art production rules

- Flat colors, thick outlines, high contrast. It must read on a cheap tablet screen in a bright room.
- Every gameplay object distinguishable by **silhouette alone**, so a non-reader tells them apart even if colors wash out.
- Animate with sprite frames, never particle systems or shaders (budget rule).
- One atlas. Tint shapes in code rather than drawing every color variant.

## Why this matters for the build order

The Worm Builder can be built early and independently — it doesn't need networking. It's a perfect **Stage 1.5**: a self-contained, high-joy screen you can put in front of Chloe and her sibling within the first week to get them excited and gather feedback, while the scary networking work proceeds in parallel. Shipping her the builder first is both good morale and good product sense.
