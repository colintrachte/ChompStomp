extends Node2D
class_name Worm

# Movement
const TICK_SPEED := 8.0         # pixels per 30 Hz tick (= 240 px/s)
const MAX_TURN := 0.12          # max radians to rotate per tick
const MIN_STEER_SQ := 900.0     # ignore touch within 30 px of head (avoids jitter)

# Body shape
const SEGMENT_GAP := 4          # history ticks between consecutive segment centres
const HEAD_HALF := 22.0         # half-side of head square (44 px)
const BODY_HALF := 18.0         # half-side of body squares (36 px, slight overlap = chunky)

var _head_pos: Vector2
var _direction: Vector2 = Vector2.RIGHT
var _history: Array[Vector2] = []
var _max_history: int = 0
var _visuals: Array[Polygon2D] = []
var _touch_target: Vector2
var _touching: bool = false
var _arena: Rect2


func setup(start_pos: Vector2, segment_count: int, arena: Rect2) -> void:
	_head_pos = start_pos
	_arena = arena
	_touch_target = start_pos + Vector2(200.0, 0.0)
	_max_history = maxi(1, (segment_count - 1) * SEGMENT_GAP + 1)
	_history.resize(_max_history)
	_history.fill(start_pos)

	for i in range(segment_count):
		var poly := Polygon2D.new()
		var h := HEAD_HALF if i == 0 else BODY_HALF
		poly.polygon = _rect_verts(h)
		poly.color = _segment_color(i)
		add_child(poly)
		_visuals.append(poly)

	_sync_visuals()
	for v in _visuals:
		v.reset_physics_interpolation()


func _physics_process(_delta: float) -> void:
	if _visuals.is_empty():
		return
	_steer()
	_advance()
	_sync_visuals()


func _steer() -> void:
	if not _touching:
		return
	var to_target := _touch_target - _head_pos
	if to_target.length_squared() < MIN_STEER_SQ:
		return
	var target_angle := to_target.angle()
	var current_angle := _direction.angle()
	var diff := wrapf(target_angle - current_angle, -PI, PI)
	_direction = Vector2.from_angle(current_angle + clampf(diff, -MAX_TURN, MAX_TURN))


func _advance() -> void:
	_head_pos += _direction * TICK_SPEED
	_head_pos.x = wrapf(_head_pos.x, _arena.position.x, _arena.end.x)
	_head_pos.y = wrapf(_head_pos.y, _arena.position.y, _arena.end.y)
	_history.push_front(_head_pos)
	if _history.size() > _max_history:
		_history.resize(_max_history)


func _sync_visuals() -> void:
	_visuals[0].global_position = _head_pos
	for i in range(1, _visuals.size()):
		var idx := mini(i * SEGMENT_GAP, _history.size() - 1)
		_visuals[i].global_position = _history[idx]


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		_touching = event.pressed
		if event.pressed:
			_touch_target = event.position
	elif event is InputEventScreenDrag:
		_touch_target = event.position
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		_touching = event.pressed
		if event.pressed:
			_touch_target = event.position
	elif event is InputEventMouseMotion and _touching:
		_touch_target = event.position


func _segment_color(i: int) -> Color:
	if i == 0:
		return Color.from_hsv(0.35, 0.9, 1.0)
	return Color.from_hsv(0.33, 0.75, 0.88 - i * 0.03)


func _rect_verts(half: float) -> PackedVector2Array:
	return PackedVector2Array([
		Vector2(-half, -half),
		Vector2(half, -half),
		Vector2(half, half),
		Vector2(-half, half),
	])
