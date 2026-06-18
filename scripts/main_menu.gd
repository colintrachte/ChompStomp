extends Node2D

var _t     := 0.0
var _vp    := Vector2.ZERO
var _hits  : Array = []   # [{r: Rect2, fn: Callable}]

var _palette: Array[Color] = [
	Color(0.22, 0.47, 1.00), Color(1.00, 0.90, 0.08), Color(0.62, 0.18, 0.85),
	Color(0.18, 0.80, 0.22), Color(0.95, 0.52, 0.72), Color(1.00, 0.55, 0.08),
]


func _ready() -> void:
	_vp = get_viewport_rect().size
	RenderingServer.set_default_clear_color(Color(0.05, 0.08, 0.05))
	_build_ui()


func _build_ui() -> void:
	var cx := _vp.x * 0.5

	# Big play button — lower third of screen
	var btn_w  := _vp.x * 0.40
	var btn_h  := _vp.y * 0.18
	var btn_x  := cx - btn_w * 0.5
	var btn_y  := _vp.y * 0.68

	var btn := Polygon2D.new()
	btn.polygon = PackedVector2Array([
		Vector2(btn_x, btn_y),
		Vector2(btn_x + btn_w, btn_y),
		Vector2(btn_x + btn_w, btn_y + btn_h),
		Vector2(btn_x, btn_y + btn_h),
	])
	btn.color = Color(0.14, 0.68, 0.28)
	add_child(btn)

	# Play triangle inside button
	var tri_h  := btn_h * 0.50
	var tri_cx := cx
	var tri_cy := btn_y + btn_h * 0.5
	var tri := Polygon2D.new()
	tri.polygon = PackedVector2Array([
		Vector2(tri_cx - tri_h * 0.72, tri_cy - tri_h * 0.6),
		Vector2(tri_cx + tri_h * 0.72, tri_cy),
		Vector2(tri_cx - tri_h * 0.72, tri_cy + tri_h * 0.6),
	])
	tri.color = Color(0.92, 1.00, 0.92)
	add_child(tri)

	_hits.append({"r": Rect2(btn_x, btn_y, btn_w, btn_h), "fn": Callable(self, "_on_play")})


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


func _on_play() -> void:
	get_tree().change_scene_to_file("res://scenes/worm_builder.tscn")


func _draw() -> void:
	var vp   := get_viewport_rect().size
	var cx   := vp.x * 0.5
	var font := ThemeDB.fallback_font
	var fs   := int(vp.x * 0.072)

	# Title
	draw_string(font, Vector2(0.0, vp.y * 0.14),
			"CHOMP  STOMP", HORIZONTAL_ALIGNMENT_CENTER, vp.x, fs,
			Color(1.0, 0.95, 0.30))

	# Animated worm preview — sinusoidal chain of beads following a wave path
	var bead_r   := vp.x * 0.025
	var n_beads  := 10
	var wave_cx  := cx
	var wave_cy  := vp.y * 0.42
	var wave_amp := vp.y * 0.09
	var wave_w   := vp.x * 0.38

	for i in n_beads:
		var frac := float(i) / float(n_beads - 1)
		var bx   := wave_cx - wave_w * 0.5 + frac * wave_w
		var by   := wave_cy + sin(frac * TAU + _t * 2.2) * wave_amp
		var ci   := i % _palette.size()
		var col  := _palette[ci]

		# Base circle
		draw_circle(Vector2(bx, by), bead_r, col)
		# Sticker: small dark polygon for variety
		var si := i % 4   # rotate through a few shapes for visual interest
		var sv := _mini_shape(si, bead_r * 0.60)
		var verts := PackedVector2Array()
		for v in sv:
			verts.append(Vector2(bx, by) + v)
		draw_colored_polygon(verts, col.darkened(0.28))
		# Highlight sheen
		draw_circle(Vector2(bx - bead_r * 0.28, by - bead_r * 0.28),
				bead_r * 0.36, col.lightened(0.45))

	# "BUILD YOUR WORM" small label above play button
	draw_string(font, Vector2(0.0, vp.y * 0.64),
			"BUILD  ·  PLAY", HORIZONTAL_ALIGNMENT_CENTER, vp.x,
			int(vp.x * 0.026), Color(0.70, 0.82, 0.68, 0.75))


func _mini_shape(si: int, r: float) -> PackedVector2Array:
	match si:
		0:   # rect
			return PackedVector2Array([
				Vector2(-r, -r * 0.72), Vector2(r, -r * 0.72),
				Vector2(r,  r * 0.72), Vector2(-r,  r * 0.72),
			])
		1:   # diamond
			return PackedVector2Array([
				Vector2(0, -r), Vector2(r * 0.65, 0),
				Vector2(0,  r), Vector2(-r * 0.65, 0),
			])
		2:   # pentagon (5 verts)
			var v := PackedVector2Array()
			for j in 5:
				var a := TAU * j / 5.0 - PI * 0.5
				v.append(Vector2(cos(a) * r, sin(a) * r))
			return v
		_:   # triangle
			return PackedVector2Array([
				Vector2(0, -r), Vector2(r * 0.82, r * 0.65), Vector2(-r * 0.82, r * 0.65),
			])
