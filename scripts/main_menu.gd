extends Node2D

# Arena picker: the kid taps a picture of a place — no text labels on the cards.
# The picture IS the game mode. Tapping a card goes to the worm builder, then play.

var _t   := 0.0
var _vp  := Vector2.ZERO
var _hits: Array = []   # [{r: Rect2, fn: Callable}]

var _palette: Array[Color] = [
	Color(0.22, 0.47, 1.00), Color(1.00, 0.90, 0.08), Color(0.62, 0.18, 0.85),
	Color(0.18, 0.80, 0.22), Color(0.95, 0.52, 0.72), Color(1.00, 0.55, 0.08),
]


func _ready() -> void:
	_vp = get_viewport_rect().size
	RenderingServer.set_default_clear_color(Color(0.05, 0.08, 0.05))
	_build_hitboxes()


func _build_hitboxes() -> void:
	var card := _card_rect(0)
	_hits.append({"r": card, "fn": Callable(self, "_on_green_hill")})


func _process(delta: float) -> void:
	_t += delta
	queue_redraw()


func _input(event: InputEvent) -> void:
	var sp := Vector2(-1.0, -1.0)
	if event is InputEventScreenTouch and event.pressed:
		sp = event.position
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		sp = event.position
	if sp.x < 0.0:
		return
	for hit in _hits:
		if (hit.r as Rect2).has_point(sp):
			(hit.fn as Callable).call()
			return


func _on_green_hill() -> void:
	get_tree().change_scene_to_file("res://scenes/worm_builder.tscn")


func _draw() -> void:
	_draw_title()
	_draw_worm_preview()
	_draw_arena_card(0, false)   # Green Hill — active
	_draw_arena_card(1, true)    # Volcano  — locked/coming soon


# =============================================================================
# Layout helpers
# =============================================================================

func _card_rect(idx: int) -> Rect2:
	var cw   := _vp.x * 0.40
	var ch   := _vp.y * 0.42
	var gap  := _vp.x * 0.06
	var cy   := _vp.y * 0.50
	var total_w := cw * 2.0 + gap
	var cx0  := (_vp.x - total_w) * 0.5
	return Rect2(cx0 + float(idx) * (cw + gap), cy, cw, ch)


# =============================================================================
# Drawing
# =============================================================================

func _draw_title() -> void:
	var font := ThemeDB.fallback_font
	var fs   := int(_vp.x * 0.072)
	draw_string(font, Vector2(0.0, _vp.y * 0.12),
		"CHOMP  STOMP", HORIZONTAL_ALIGNMENT_CENTER, _vp.x, fs,
		Color(1.0, 0.95, 0.30))
	var sub_fs := int(_vp.x * 0.022)
	draw_string(font, Vector2(0.0, _vp.y * 0.178),
		"TAP A WORLD TO START", HORIZONTAL_ALIGNMENT_CENTER, _vp.x, sub_fs,
		Color(0.78, 0.92, 0.72, 0.60))


func _draw_worm_preview() -> void:
	# Animated worm bead chain — sinusoidal wiggle
	var bead_r  := _vp.x * 0.022
	var n       := 10
	var cx      := _vp.x * 0.5
	var cy      := _vp.y * 0.32
	var amp     := _vp.y * 0.055
	var wave_w  := _vp.x * 0.34

	for i in n:
		var frac := float(i) / float(n - 1)
		var bx   := cx - wave_w * 0.5 + frac * wave_w
		var by   := cy + sin(frac * TAU + _t * 2.2) * amp
		var col  := _palette[i % _palette.size()]
		draw_circle(Vector2(bx, by), bead_r, col)
		draw_circle(Vector2(bx - bead_r * 0.28, by - bead_r * 0.28),
			bead_r * 0.36, col.lightened(0.42))


func _draw_arena_card(idx: int, locked: bool) -> void:
	var r   := _card_rect(idx)
	var pos := r.position
	var sz  := r.size
	var dim := 0.38 if locked else 1.0

	# Card background
	var bg_col := Color(0.10, 0.14, 0.12, dim)
	draw_rect(r, bg_col)

	match idx:
		0: _draw_green_hill_scene(pos, sz, dim)
		1: _draw_volcano_scene(pos, sz, dim)

	# Border — bright green for active, grey for locked
	var border_col: Color
	if locked:
		border_col = Color(0.35, 0.35, 0.38, 0.55)
	else:
		border_col = Color(0.22, 0.85, 0.30, 0.85) if fmod(_t, 1.6) < 1.3 else Color(0.50, 1.00, 0.55, 0.85)
	var bw := 4.0
	draw_line(pos,                              pos + Vector2(sz.x, 0),    border_col, bw)
	draw_line(pos + Vector2(sz.x, 0),           pos + sz,                  border_col, bw)
	draw_line(pos + sz,                         pos + Vector2(0, sz.y),    border_col, bw)
	draw_line(pos + Vector2(0, sz.y),           pos,                       border_col, bw)

	# Lock icon on the locked card
	if locked:
		var lc := pos + sz * 0.5
		draw_rect(Rect2(lc + Vector2(-sz.x * 0.10, -sz.x * 0.08), Vector2(sz.x * 0.20, sz.x * 0.18)),
			Color(0.30, 0.28, 0.35, 0.75))
		var shackle_c := lc + Vector2(0.0, -sz.x * 0.08)
		draw_arc(shackle_c, sz.x * 0.08, 0.0, PI, 12, Color(0.55, 0.52, 0.58, 0.80), 4.0, true)

	# Card name label at the bottom
	var font    := ThemeDB.fallback_font
	var name_fs := int(sz.x * 0.095)
	var name    := "GREEN HILL" if idx == 0 else "COMING SOON"
	var name_col := Color(1.0, 1.0, 0.90, 0.88 * dim)
	draw_string(font, pos + Vector2(0.0, sz.y * 0.97),
		name, HORIZONTAL_ALIGNMENT_CENTER, sz.x, name_fs, name_col)


func _draw_green_hill_scene(pos: Vector2, sz: Vector2, dim: float) -> void:
	# Sky
	draw_rect(Rect2(pos, sz), Color(0.35, 0.62, 0.90, dim))

	# Rolling hills — two overlapping ellipses
	var hill_y := pos.y + sz.y * 0.60
	var _draw_hill := func(hx: float, hw: float, hh: float, col: Color) -> void:
		var pts := PackedVector2Array()
		var steps := 20
		for i in steps + 1:
			var t  := float(i) / float(steps)
			var a  := PI + t * PI
			pts.append(pos + Vector2(hx + cos(a) * hw, hill_y + sin(a) * hh))
		pts.append(pos + Vector2(sz.x, sz.y))
		pts.append(pos + Vector2(0.0, sz.y))
		draw_colored_polygon(pts, col)

	_draw_hill.call(sz.x * 0.30, sz.x * 0.40, sz.y * 0.28, Color(0.12, 0.65, 0.18, dim))
	_draw_hill.call(sz.x * 0.72, sz.x * 0.38, sz.y * 0.32, Color(0.08, 0.55, 0.14, dim))

	# Speed pad chevrons in the scene
	var pad_cx := pos + Vector2(sz.x * 0.42, hill_y - sz.y * 0.10)
	var col_sp := Color(1.0, 0.92, 0.12, 0.85 * dim)
	for i in 3:
		var bx := pad_cx.x + float(i) * 14.0
		draw_line(Vector2(bx - 8.0, pad_cx.y + 8.0), Vector2(bx, pad_cx.y - 2.0), col_sp, 2.5)
		draw_line(Vector2(bx + 8.0, pad_cx.y + 8.0), Vector2(bx, pad_cx.y - 2.0), col_sp, 2.5)

	# Tiny worm silhouette
	var wc := pos + Vector2(sz.x * 0.22, hill_y - sz.y * 0.16)
	for i in 5:
		var bc := wc + Vector2(float(i) * 10.0, sin(float(i) * 0.8) * 4.0)
		draw_circle(bc, 5.5, Color(0.22, 0.47, 1.00, dim))


func _draw_volcano_scene(pos: Vector2, sz: Vector2, dim: float) -> void:
	# Sky: dark orange-red dusk
	draw_rect(Rect2(pos, sz), Color(0.28, 0.12, 0.08, dim))

	# Volcano cone
	draw_colored_polygon(PackedVector2Array([
		pos + Vector2(sz.x * 0.50, sz.y * 0.18),
		pos + Vector2(sz.x * 0.80, sz.y * 0.80),
		pos + Vector2(sz.x * 0.20, sz.y * 0.80),
	]), Color(0.38, 0.22, 0.14, dim))

	# Lava at top
	draw_circle(pos + Vector2(sz.x * 0.50, sz.y * 0.18), sz.x * 0.07,
		Color(1.00, 0.45, 0.08, dim))

	# Lava drips
	for i in 3:
		var dx := pos.x + sz.x * (0.40 + float(i) * 0.07)
		var dy := pos.y + sz.y * (0.22 + float(i) * 0.05)
		draw_line(Vector2(dx, dy - sz.y * 0.04), Vector2(dx, dy + sz.y * 0.06),
			Color(1.00, 0.55, 0.10, dim), 3.5)
