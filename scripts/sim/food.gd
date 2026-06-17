class_name Food
extends Node2D

const EAT_RADIUS := 14.0

# 0 = leaf, 1 = flower, 2 = apple
var food_type: int = 0
var eaten: bool    = false

var _r    := 13.0
var _time := 0.0


func setup(pos: Vector2, kind: int) -> void:
	position  = pos
	food_type = kind
	_time     = randf() * TAU   # stagger pulse phases so items don't all bob in sync


func _process(delta: float) -> void:
	_time += delta
	var pulse := 1.0 + sin(_time * 3.8) * 0.09
	scale = Vector2(pulse, pulse)
	queue_redraw()


func _draw() -> void:
	match food_type:
		0: _draw_leaf()
		1: _draw_flower()
		2: _draw_apple()


func _draw_leaf() -> void:
	var pts := PackedVector2Array()
	for i in 20:
		var a := TAU * i / 20.0
		pts.append(Vector2(cos(a) * _r * 0.55, sin(a) * _r))
	draw_colored_polygon(pts, Color(0.15, 0.72, 0.18))
	draw_line(Vector2(0, _r * 0.85), Vector2(0, -_r * 0.85), Color(0.10, 0.50, 0.10), 1.5)
	draw_line(Vector2(0, _r), Vector2(0, _r * 1.6), Color(0.38, 0.25, 0.08), 2.0)


func _draw_flower() -> void:
	for i in 5:
		var a  := TAU * i / 5.0
		var cx := cos(a) * _r * 0.62
		var cy := sin(a) * _r * 0.62
		var pts := PackedVector2Array()
		for j in 14:
			var pa := TAU * j / 14.0
			pts.append(Vector2(cx + cos(pa) * _r * 0.40, cy + sin(pa) * _r * 0.40))
		draw_colored_polygon(pts, Color(1.0, 0.75, 0.88))
	draw_circle(Vector2.ZERO, _r * 0.36, Color(1.0, 0.88, 0.12))


func _draw_apple() -> void:
	var pts := PackedVector2Array()
	for i in 20:
		var a := TAU * i / 20.0
		var r := _r * (1.0 - 0.07 * absf(sin(a)))
		pts.append(Vector2(cos(a) * r * 0.86, sin(a) * r))
	draw_colored_polygon(pts, Color(0.92, 0.16, 0.16))
	draw_line(Vector2(0, -_r * 0.92), Vector2(0, -_r * 1.45), Color(0.38, 0.22, 0.08), 2.5)
	draw_circle(Vector2(-_r * 0.28, -_r * 0.22), _r * 0.18, Color(1, 1, 1, 0.26))
