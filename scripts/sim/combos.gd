class_name Combos

# Tag IDs — the engine thinks in these; kids think in items
const NONE   := 0
const FIRE   := 1
const GAS    := 2
const MASS   := 3
const BOUNCE := 4

# Combo result IDs
const DEFAULT        := 0   # safe fallback: both effects just happen, no special combo
const FIRE_GAS       := 1   # big blast — Ryan's signature moment
const FIRE_MASS      := 2   # molten ram: smash through things with burning trail
const FIRE_BOUNCE    := 3   # flaming dash: burst of speed with fire
const GAS_MASS       := 4   # lift + slam: float then crash shockwave
const GAS_BOUNCE     := 5   # freeze bubble: traps pests in a radius
const MASS_BOUNCE    := 6   # pinball: wrecking ball zooms and kills
const AMPLIFY_FIRE   := 7   # fire + fire: mega blast
const AMPLIFY_GAS    := 8   # gas + gas: long freeze
const AMPLIFY_MASS   := 9   # mass + mass: extended ram
const AMPLIFY_BOUNCE := 10  # bounce + bounce: super speed

# How long (seconds) a loaded tag keeps the worm "charged" before expiring
const TAG_WINDOW := 4.5


# Full pairwise interaction grid — 6 unique pairs + 4 amplify + safe default
# tags in:  fire gas mass bounce    result
# fire  + gas    = FIRE_GAS
# fire  + mass   = FIRE_MASS
# fire  + bounce = FIRE_BOUNCE
# gas   + mass   = GAS_MASS
# gas   + bounce = GAS_BOUNCE
# mass  + bounce = MASS_BOUNCE
# X     + X      = AMPLIFY_X
# any unhandled  = DEFAULT (never crashes)
static func resolve(a: int, b: int) -> int:
	if a == b:
		match a:
			FIRE:   return AMPLIFY_FIRE
			GAS:    return AMPLIFY_GAS
			MASS:   return AMPLIFY_MASS
			BOUNCE: return AMPLIFY_BOUNCE
	var lo := mini(a, b)
	var hi := maxi(a, b)
	if lo == FIRE   and hi == GAS:    return FIRE_GAS
	if lo == FIRE   and hi == MASS:   return FIRE_MASS
	if lo == FIRE   and hi == BOUNCE: return FIRE_BOUNCE
	if lo == GAS    and hi == MASS:   return GAS_MASS
	if lo == GAS    and hi == BOUNCE: return GAS_BOUNCE
	if lo == MASS   and hi == BOUNCE: return MASS_BOUNCE
	return DEFAULT


static func tag_color(tag: int) -> Color:
	match tag:
		FIRE:   return Color(1.0, 0.42, 0.08)
		GAS:    return Color(0.30, 0.88, 0.28)
		MASS:   return Color(0.62, 0.52, 0.72)
		BOUNCE: return Color(0.18, 0.62, 1.00)
	return Color.WHITE
