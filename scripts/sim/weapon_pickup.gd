class_name WeaponPickup
extends Node2D

# Kind maps 1:1 onto Combos tags: CHILI=FIRE, FIZZY=GAS, BOULDER=MASS, SPRING=BOUNCE
const CHILI   := 0   # red pepper      → fire
const FIZZY   := 1   # blue flask      → gas
const BOULDER := 2   # grey rock       → mass
const SPRING  := 3   # green coil      → bounce

const EAT_RADIUS := 20.0

var kind : int  = CHILI
var eaten: bool = false

var _time := 0.0


func setup(pos: Vector2, k: int) -> void:
	position = pos
	kind     = k
	_time    = randf() * TAU


func tag() -> int:
	match kind:
		CHILI:   return Combos.FIRE
		FIZZY:   return Combos.GAS
		BOULDER: return Combos.MASS
		SPRING:  return Combos.BOUNCE
	return Combos.NONE


func _process(delta: float) -> void:
	_time += delta
	var pulse := 1.0 + sin(_time * 3.5) * 0.10
	scale = Vector2(pulse, pulse)
	queue_redraw()


func _draw() -> void:
	match kind:
		CHILI:   _draw_chili()
		FIZZY:   _draw_fizzy()
		BOULDER: _draw_boulder()
		SPRING:  _draw_spring()


func _draw_chili() -> void:
	# Red elongated pepper + green stem — fire tag
	var pts := PackedVector2Array()
	for i in 20:
		var a := TAU * i / 20.0
		pts.append(Vector2(cos(a) * 7.0, sin(a) * 13.0))
	draw_colored_polygon(pts, Color(0.92, 0.10, 0.10))
	draw_line(Vector2(0.0, 13.0), Vector2(3.0, 19.0), Color(0.78, 0.06, 0.06), 3.0)
	draw_line(Vector2(0.0, -13.0), Vector2(0.0, -21.0), Color(0.15, 0.58, 0.10), 3.5)
	draw_line(Vector2(0.0, -17.0), Vector2(6.0, -23.0), Color(0.15, 0.58, 0.10), 2.0)
	draw_circle(Vector2(-2.5, -4.0), 3.5, Color(1.0, 0.50, 0.50, 0.35))


func _draw_fizzy() -> void:
	# Rounded blue flask with bubbles — gas tag
	var pts := PackedVector2Array()
	for i in 18:
		var a := TAU * i / 18.0
		pts.append(Vector2(cos(a) * 10.0, sin(a) * 12.0))
	draw_colored_polygon(pts, Color(0.18, 0.52, 0.96))
	draw_rect(Rect2(-4.0, -21.0, 8.0, 10.0), Color(0.18, 0.52, 0.96))
	draw_rect(Rect2(-5.5, -26.0, 11.0, 6.0), Color(0.85, 0.65, 0.15))
	draw_circle(Vector2(-3.0,  2.0), 3.2, Color(0.65, 0.85, 1.00, 0.65))
	draw_circle(Vector2( 4.0, -4.0), 2.4, Color(0.65, 0.85, 1.00, 0.65))
	draw_circle(Vector2(-1.0, -9.0), 1.8, Color(0.65, 0.85, 1.00, 0.65))


func _draw_boulder() -> void:
	# Rough dark-grey rock with cracks — mass tag
	var pts := PackedVector2Array()
	for i in 10:
		var a := TAU * i / 10.0
		var r := 14.0 + sin(a * 3.3 + 0.8) * 3.5
		pts.append(Vector2(cos(a) * r, sin(a) * r))
	draw_colored_polygon(pts, Color(0.40, 0.38, 0.44))
	draw_line(Vector2(-5.0, -5.0), Vector2( 3.0,  6.0), Color(0.22, 0.20, 0.24), 1.8)
	draw_line(Vector2( 4.0, -7.0), Vector2(-2.0,  3.0), Color(0.22, 0.20, 0.24), 1.4)
	draw_circle(Vector2(-5.0, -5.0), 4.5, Color(0.70, 0.68, 0.74, 0.38))


func _draw_spring() -> void:
	# Green zigzag coil — bounce tag
	var col := Color(0.18, 0.82, 0.30)
	var pts := [
		Vector2(-6.0, -18.0), Vector2( 8.0, -11.0),
		Vector2(-8.0,  -4.0), Vector2( 8.0,   3.0),
		Vector2(-8.0,  10.0), Vector2( 6.0,  18.0),
	]
	for i in pts.size() - 1:
		draw_line(pts[i], pts[i + 1], col, 4.5)
	draw_line(Vector2(-7.0, -18.0), Vector2(7.0, -18.0), col, 4.5)
	draw_line(Vector2(-7.0,  18.0), Vector2(7.0,  18.0), col, 4.5)
