extends Node2D

func _ready() -> void:
	# canvas_items + expand: viewport adapts to the real screen, so this is always correct.
	var vp := get_viewport_rect().size
	var margin := 20.0
	var arena := Rect2(Vector2(margin, margin), vp - Vector2(margin * 2.0, margin * 2.0))

	_add_poly_rect(Rect2(Vector2.ZERO, vp), Color(0.07, 0.11, 0.07))
	_draw_border(arena, 4.0, Color(0.25, 0.45, 0.22))

	var worm := Worm.new()
	add_child(worm)
	worm.setup(vp / 2.0, 8, arena)


func _draw_border(r: Rect2, t: float, color: Color) -> void:
	# top, bottom, left, right border strips
	_add_poly_rect(Rect2(r.position.x - t, r.position.y - t, r.size.x + t * 2.0, t), color)
	_add_poly_rect(Rect2(r.position.x - t, r.end.y, r.size.x + t * 2.0, t), color)
	_add_poly_rect(Rect2(r.position.x - t, r.position.y, t, r.size.y), color)
	_add_poly_rect(Rect2(r.end.x, r.position.y, t, r.size.y), color)


func _add_poly_rect(r: Rect2, color: Color) -> void:
	var poly := Polygon2D.new()
	poly.polygon = PackedVector2Array([
		r.position,
		Vector2(r.end.x, r.position.y),
		r.end,
		Vector2(r.position.x, r.end.y),
	])
	poly.color = color
	add_child(poly)
