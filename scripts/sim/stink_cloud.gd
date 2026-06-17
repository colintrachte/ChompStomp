class_name StinkCloud
extends Node2D

const RADIUS   := 32.0
const LIFETIME := 2.2

var _age := 0.0


func _process(delta: float) -> void:
	_age += delta
	if _age >= LIFETIME:
		queue_free()
		return
	queue_redraw()


func _draw() -> void:
	var t     := _age / LIFETIME
	var alpha := (1.0 - t) * 0.50
	draw_circle(Vector2.ZERO, RADIUS * (0.8 + t * 0.4), Color(0.55, 0.88, 0.22, alpha))
	# Wiggly wavy inner blobs for visual interest
	for i in 3:
		var a := TAU * float(i) / 3.0 + _age * 1.8
		draw_circle(Vector2(cos(a) * RADIUS * 0.35, sin(a) * RADIUS * 0.35),
				RADIUS * 0.28, Color(0.65, 0.95, 0.30, alpha * 0.55))
