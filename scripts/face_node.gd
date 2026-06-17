class_name FaceNode
extends Node2D

var fi := 4
var h  := 22.0

func set_face(face_idx: int, half: float) -> void:
	fi = face_idx; h = half; queue_redraw()

func _draw() -> void:
	var c  := Color(0.05, 0.05, 0.05, 0.90)
	var lw := maxf(h * 0.09, 1.5)
	match fi:
		0: _smile(c, lw)
		1: _sleepy(c, lw)
		2: _surprised(c, lw)
		3: _cat(c, lw)
		4: _bunny(c, lw)
		5: _silly(c, lw)

func _dot(c: Color, x: float, r: float) -> void:
	draw_circle(Vector2(x, -h * 0.14), r, c)

func _smile(c: Color, lw: float) -> void:
	_dot(c, -h*0.27, h*0.10); _dot(c, h*0.27, h*0.10)
	var pts := PackedVector2Array()
	for i in 9:
		var t := float(i) / 8.0
		pts.append(Vector2(lerp(-h*0.36, h*0.36, t), h*0.07 + sin(t * PI) * h*0.28))
	draw_polyline(pts, c, lw, true)

func _sleepy(c: Color, lw: float) -> void:
	draw_line(Vector2(-h*0.38,-h*0.12), Vector2(-h*0.14,-h*0.12), c, lw, true)
	draw_line(Vector2( h*0.14,-h*0.12), Vector2( h*0.38,-h*0.12), c, lw, true)
	draw_line(Vector2(-h*0.18, h*0.22), Vector2( h*0.18, h*0.22), c, lw*0.6, true)

func _surprised(c: Color, lw: float) -> void:
	draw_arc(Vector2(-h*0.26,-h*0.14), h*0.13, 0.0, TAU, 12, c, lw, true)
	draw_arc(Vector2( h*0.26,-h*0.14), h*0.13, 0.0, TAU, 12, c, lw, true)
	draw_arc(Vector2(0, h*0.26), h*0.16, 0.0, TAU, 12, c, lw, true)

func _cat(c: Color, lw: float) -> void:
	_dot(c, -h*0.27, h*0.09); _dot(c, h*0.27, h*0.09)
	draw_circle(Vector2(0, h*0.10), h*0.07, c)
	for s: float in [-1.0, 1.0]:
		draw_line(Vector2(s*h*0.06, h*0.14), Vector2(s*h*0.52, h*0.07), c, lw*0.8, true)
		draw_line(Vector2(s*h*0.06, h*0.21), Vector2(s*h*0.52, h*0.28), c, lw*0.8, true)

func _bunny(c: Color, lw: float) -> void:
	for s: float in [-1.0, 1.0]:
		var ep := PackedVector2Array()
		for i in 14:
			var a := TAU * i / 14.0
			ep.append(Vector2(s*h*0.26 + cos(a)*h*0.14, -h*0.65 + sin(a)*h*0.38))
		draw_colored_polygon(ep, c)
		var ip := PackedVector2Array()
		for i in 14:
			var a := TAU * i / 14.0
			ip.append(Vector2(s*h*0.26 + cos(a)*h*0.08, -h*0.65 + sin(a)*h*0.26))
		draw_colored_polygon(ip, Color(0.95, 0.58, 0.70, 0.9))
	_dot(c, -h*0.27, h*0.09); _dot(c, h*0.27, h*0.09)

func _silly(c: Color, lw: float) -> void:
	_dot(c, -h*0.27, h*0.10)
	draw_arc(Vector2(h*0.27,-h*0.12), h*0.14, 0.0, TAU, 12, c, lw, true)
	var tp := PackedVector2Array()
	for i in 12:
		var a := TAU * i / 12.0
		tp.append(Vector2(cos(a)*h*0.18, h*0.40 + sin(a)*h*0.22))
	draw_colored_polygon(tp, Color(0.95, 0.28, 0.28, 0.92))
