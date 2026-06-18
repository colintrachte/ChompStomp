extends Node2D

const DURATION := 2.6

var _t     := 0.0
var _going := false

var _palette: Array[Color] = [
	Color(0.22, 0.47, 1.00), Color(1.00, 0.90, 0.08), Color(0.62, 0.18, 0.85),
	Color(0.18, 0.80, 0.22), Color(0.95, 0.52, 0.72), Color(1.00, 0.55, 0.08),
]


func _ready() -> void:
	RenderingServer.set_default_clear_color(Color(0.04, 0.06, 0.04))


func _process(delta: float) -> void:
	_t += delta
	queue_redraw()
	if _t >= DURATION and not _going:
		_advance()


func _input(event: InputEvent) -> void:
	var tapped := false
	if event is InputEventScreenTouch and event.pressed:
		tapped = true
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		tapped = true
	if tapped and _t > 0.4:
		_advance()


func _advance() -> void:
	if _going:
		return
	_going = true
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _draw() -> void:
	var vp   := get_viewport_rect().size
	var cx   := vp.x * 0.5
	var cy   := vp.y * 0.40
	var fade := clampf(_t / 0.55, 0.0, 1.0)

	var font := ThemeDB.fallback_font
	var fs   := int(vp.x * 0.075)

	# Title
	draw_string(font, Vector2(0.0, cy),
			"CHOMP  STOMP", HORIZONTAL_ALIGNMENT_CENTER, vp.x, fs,
			Color(1.0, 0.95, 0.30, fade))

	# Animated worm-bead row beneath title
	var bead_r  := vp.x * 0.022
	var spread  := bead_r * 2.8
	var count   := _palette.size()
	var bx0     := cx - spread * (count - 1) * 0.5
	var row_y   := cy + vp.y * 0.12
	for i in count:
		var bounce := sin(_t * 3.4 + float(i) * 1.05) * bead_r * 0.55
		var bx     := bx0 + float(i) * spread
		var col    := _palette[i]
		col.a      = fade
		draw_circle(Vector2(bx, row_y + bounce), bead_r, col)
		# Highlight sheen
		var hl := col.lightened(0.45)
		hl.a    = fade * 0.8
		draw_circle(Vector2(bx - bead_r * 0.28, row_y + bounce - bead_r * 0.28),
				bead_r * 0.38, hl)

	# "tap to continue" blink
	if _t > 1.0:
		var blink := (sin(_t * 5.5) * 0.5 + 0.5) * clampf((_t - 1.0) / 0.5, 0.0, 1.0)
		draw_string(font, Vector2(0.0, cy + vp.y * 0.30),
				"tap to continue", HORIZONTAL_ALIGNMENT_CENTER, vp.x,
				int(vp.x * 0.028), Color(1.0, 1.0, 1.0, blink * 0.70))
