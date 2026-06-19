extends Node2D
class_name Worm

const Combos := preload("res://scripts/sim/combos.gd")

signal evolved(new_stage: int)
signal worm_defeated

# --- Evolution stage table ---
const STAGES := [
	{"segs": 4,  "head": 20.0, "body": 15.0, "speed":  7.0, "spikes": false, "wings": false},  # Tiny
	{"segs": 6,  "head": 24.0, "body": 19.0, "speed": 10.0, "spikes": false, "wings": false},  # Fast
	{"segs": 9,  "head": 29.0, "body": 24.0, "speed": 11.5, "spikes": true,  "wings": false},  # Spiky
	{"segs": 12, "head": 34.0, "body": 29.0, "speed": 12.5, "spikes": true,  "wings": true},   # Dragon
	{"segs": 16, "head": 42.0, "body": 36.0, "speed": 14.0, "spikes": true,  "wings": true},   # Mega
]

const EAT_TO_EVOLVE := [8, 15, 25, 40]

const SEGMENT_GAP  := 4
const MAX_TURN     := 0.12
const MIN_STEER_SQ := 900.0

# --- Mutable stage state ---
var _stage      := 0
var _food_eaten := 0
var _speed      := 7.0
var _h_head     := 20.0
var _h_body     := 15.0

# --- Health / effects ---
var _alive           := true
var _invincible_ticks := 0   # brief invincibility + flash after a hit
var _sneeze_ticks     := 0   # random wobble when worm sneezes

# --- Combo tag state ---
var _active_tag      := 0        # Combos.NONE = 0
var _tag_timer       := 0.0      # seconds until the loaded tag expires
var _speed_mul       := 1.0      # temporary multiplier from combo effects
var _speed_mul_timer := 0.0

# --- Motion state ---
var _head_pos  : Vector2
var _direction : Vector2 = Vector2.RIGHT
var _history   : Array[Vector2] = []
var _max_history: int = 0

# --- Visuals ---
var _visuals   : Array[Polygon2D] = []
var _face_node : FaceNode         = null

# --- Input ---
var _touch_target : Vector2
var _touching     : bool = false

# --- Config ---
var _worm_data : WormData = null

# --- Public read-only ---
var head_pos: Vector2:
	get: return _head_pos
var head_radius: float:
	get: return _h_head
var is_alive: bool:
	get: return _alive
var face_idx: int:
	get: return _worm_data.face_idx if _worm_data != null else 0
# Interpolated head position for smooth camera follow
var head_visual_pos: Vector2:
	get: return _visuals[0].global_position if not _visuals.is_empty() else _head_pos
var active_tag: int:
	get: return _active_tag


# =============================================================================
# Public API
# =============================================================================

func setup(start_pos: Vector2, data: WormData = null) -> void:
	_worm_data    = data
	_head_pos     = start_pos
	_touch_target = start_pos + Vector2(200.0, 0.0)
	_stage        = 0
	_food_eaten   = 0
	_alive        = true
	_apply_stage_consts()
	_rebuild_visuals()


func eat_food(_food_type: int) -> void:
	_food_eaten += 1
	if _stage >= EAT_TO_EVOLVE.size():
		return
	var threshold: int = EAT_TO_EVOLVE[_stage] as int
	if _food_eaten >= threshold:
		_food_eaten = 0
		_stage     += 1
		_apply_stage_consts()
		_rebuild_visuals()
		evolved.emit(_stage)


func take_hit() -> void:
	if not _alive or _invincible_ticks > 0:
		return
	if _stage > 0:
		_invincible_ticks = 67 if face_idx == 1 else 45   # sleepy face: 2.2 s, others: 1.5 s
		_food_eaten = 0
		_stage -= 1
		_apply_stage_consts()
		_rebuild_visuals()
	else:
		_alive = false
		set_physics_process(false)
		_trigger_loss()


func sneeze() -> void:
	_sneeze_ticks = 30   # 1 s of random wiggle at 30 Hz


func respawn(pos: Vector2) -> void:
	_alive        = true
	_stage        = 0
	_food_eaten   = 0
	_invincible_ticks = 60   # 2 s invincibility on respawn
	_sneeze_ticks = 0
	_active_tag      = 0
	_tag_timer       = 0.0
	_speed_mul       = 1.0
	_speed_mul_timer = 0.0
	_head_pos     = pos
	_direction    = Vector2.RIGHT
	_history.fill(pos)
	_reset_visual_transforms()
	_apply_stage_consts()
	_rebuild_visuals()
	visible = true
	set_physics_process(true)


func load_tag(tag: int) -> void:
	_active_tag = tag
	_tag_timer  = Combos.TAG_WINDOW
	_update_tag_tint()


func clear_tag() -> void:
	_active_tag = 0
	_tag_timer  = 0.0
	_clear_tag_tint()


func apply_speed_boost(mul: float, duration: float) -> void:
	_speed_mul       = mul
	_speed_mul_timer = duration


# =============================================================================
# Physics loop
# =============================================================================

func _physics_process(delta: float) -> void:
	if not _alive or _visuals.is_empty():
		return
	if _invincible_ticks > 0:
		_invincible_ticks -= 1
		visible = (_invincible_ticks % 6) >= 3
	elif not visible:
		visible = true

	if _tag_timer > 0.0:
		_tag_timer -= delta
		if _tag_timer <= 0.0:
			_clear_tag_tint()
		else:
			_update_tag_tint()

	if _speed_mul_timer > 0.0:
		_speed_mul_timer -= delta
		if _speed_mul_timer <= 0.0:
			_speed_mul = 1.0

	_steer()
	_advance()
	_sync_visuals()


func _steer() -> void:
	if _sneeze_ticks > 0:
		_sneeze_ticks -= 1
		_direction = Vector2.from_angle(_direction.angle() + randf_range(-0.4, 0.4))
		return
	if not _touching:
		return
	var to_target := _touch_target - _head_pos
	if to_target.length_squared() < MIN_STEER_SQ:
		return
	var target_angle  := to_target.angle()
	var current_angle := _direction.angle()
	var diff          := wrapf(target_angle - current_angle, -PI, PI)
	_direction = Vector2.from_angle(current_angle + clampf(diff, -MAX_TURN, MAX_TURN))


func _advance() -> void:
	_head_pos += _direction * _speed * _speed_mul
	_history.push_front(_head_pos)
	if _history.size() > _max_history:
		_history.resize(_max_history)


func _sync_visuals() -> void:
	_visuals[0].global_position = _head_pos
	_visuals[0].rotation = _direction.angle()

	for i in range(1, _visuals.size()):
		var idx      := mini(i * SEGMENT_GAP, _history.size() - 1)
		_visuals[i].global_position = _history[idx]
		var prev_idx := mini((i + 1) * SEGMENT_GAP, _history.size() - 1)
		var seg_dir  := _history[idx] - _history[prev_idx]
		if seg_dir.length_squared() > 0.5:
			_visuals[i].rotation = seg_dir.angle()


func attach_camera(cam: Camera2D) -> void:
	if not _visuals.is_empty():
		_visuals[0].add_child(cam)


# =============================================================================
# Input
# =============================================================================

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		_touching = event.pressed
		if event.pressed:
			_touch_target = get_viewport().canvas_transform.affine_inverse() * event.position
	elif event is InputEventScreenDrag:
		_touch_target = get_viewport().canvas_transform.affine_inverse() * event.position
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		_touching = event.pressed
		if event.pressed:
			_touch_target = get_global_mouse_position()
	elif event is InputEventMouseMotion and _touching:
		_touch_target = get_global_mouse_position()


# =============================================================================
# Evolution helpers
# =============================================================================

func _apply_stage_consts() -> void:
	var s: Dictionary = STAGES[_stage]
	_speed  = s["speed"] as float
	_h_head = s["head"]  as float
	_h_body = s["body"]  as float


func _rebuild_visuals() -> void:
	var stage: Dictionary = STAGES[_stage]
	var target_segs := stage["segs"] as int

	if _face_node != null and is_instance_valid(_face_node):
		var fp := _face_node.get_parent()
		if fp != null:
			fp.remove_child(_face_node)

	# Remove excess segments left over from a higher stage
	while _visuals.size() > target_segs:
		var old: Polygon2D = _visuals.pop_back()
		_clear_deco(old)
		old.queue_free()

	while _visuals.size() < target_segs:
		var poly := Polygon2D.new()
		add_child(poly)
		_visuals.append(poly)

	for i in _visuals.size():
		var h        := _h_head if i == 0 else _h_body
		var base_col := _seg_color(i)

		# Base layer: smooth circle — circles are large enough to touch/overlap at every stage
		_visuals[i].polygon = WormData.shape_verts(2, h)   # shape 2 = circle
		_visuals[i].color   = base_col
		_clear_deco(_visuals[i])

		# Sticker: kid's chosen shape painted on top of the base circle
		var sticker := Polygon2D.new()
		sticker.set_meta("deco", true)
		sticker.polygon = _sticker_verts(i, h * 0.72)
		sticker.color   = base_col.darkened(0.24)
		_visuals[i].add_child(sticker)

		# Highlight: small sheen ellipse offset to upper-left, renders on top of sticker
		var hl := Polygon2D.new()
		hl.set_meta("deco", true)
		hl.polygon  = WormData._ellipse(h * 0.38, h * 0.28)
		hl.position = Vector2(-h * 0.28, -h * 0.28)
		hl.color    = base_col.lightened(0.45)
		_visuals[i].add_child(hl)

		# Evolution decorations render on top of sticker + highlight
		if stage["spikes"] and i > 0:
			_add_spike(_visuals[i], h)
		if stage["wings"] and i == 0:
			_add_wings(_visuals[i], h)

	if _worm_data != null:
		if _face_node == null:
			_face_node         = FaceNode.new()
			_face_node.z_index = 5
		if _face_node.get_parent() == null:
			_visuals[0].add_child(_face_node)
		_face_node.set_face(_worm_data.face_idx, _h_head)

	_update_history(target_segs)
	_sync_visuals()
	for v in _visuals:
		v.reset_physics_interpolation()
	if _active_tag != 0 and _tag_timer > 0.0:
		_update_tag_tint()


func _update_history(target_segs: int) -> void:
	_max_history = maxi(1, (target_segs - 1) * SEGMENT_GAP + 1)
	var tail := _head_pos if _history.is_empty() else _history[_history.size() - 1]
	while _history.size() < _max_history:
		_history.append(tail)
	_history.resize(_max_history)
	_history.fill(tail)


# =============================================================================
# Per-segment appearance
# =============================================================================

func _sticker_verts(i: int, half: float) -> PackedVector2Array:
	if _worm_data == null:
		return WormData.shape_verts(0, half)
	var n  := _worm_data.segments.size()
	var si := _worm_data.segments[i % n]["si"] as int
	return WormData.shape_verts(si, half)


func _seg_color(i: int) -> Color:
	if _worm_data == null:
		return Color.from_hsv(0.33, 0.75, 0.88 - float(i) * 0.02)
	var n  := _worm_data.segments.size()
	var ci := _worm_data.segments[i % n]["ci"] as int
	return WormData.PALETTE[ci]


# =============================================================================
# Decoration helpers
# =============================================================================

func _clear_deco(poly: Polygon2D) -> void:
	for child in poly.get_children():
		if child.has_meta("deco"):
			poly.remove_child(child)
			child.queue_free()


func _add_spike(poly: Polygon2D, half: float) -> void:
	var spike := Polygon2D.new()
	spike.set_meta("deco", true)
	spike.polygon = PackedVector2Array([
		Vector2(-half * 0.35, -half),
		Vector2(0.0,          -half * 1.55),
		Vector2( half * 0.35, -half),
	])
	spike.color = Color(0.88, 0.62, 0.12)
	poly.add_child(spike)


func _add_wings(head_poly: Polygon2D, half: float) -> void:
	for s: float in [-1.0, 1.0]:
		var wing := Polygon2D.new()
		wing.set_meta("deco", true)
		wing.polygon = PackedVector2Array([
			Vector2(s * half * 0.5,  0.0),
			Vector2(s * half * 2.4, -half * 0.65),
			Vector2(s * half * 2.1,  half * 0.45),
		])
		wing.color = Color(0.72, 0.18, 0.82, 0.88)
		head_poly.add_child(wing)


func _update_tag_tint() -> void:
	var tc    := Combos.tag_color(_active_tag)
	var pulse := 0.55 + sin(_tag_timer * 10.0) * 0.22
	var mod   := Color.WHITE.lerp(tc, pulse)
	for v in _visuals:
		v.modulate = mod


func _clear_tag_tint() -> void:
	_active_tag = 0
	_tag_timer  = 0.0
	for v in _visuals:
		v.modulate = Color.WHITE


func _reset_visual_transforms() -> void:
	for v in _visuals:
		v.modulate = Color.WHITE
		v.rotation = 0.0
		for child in v.get_children():
			if child is CanvasItem:
				(child as CanvasItem).modulate = Color.WHITE


# =============================================================================
# Eat feedback
# =============================================================================

func chomp_flash() -> void:
	if _visuals.is_empty():
		return
	var tw := _visuals[0].create_tween()
	tw.tween_property(_visuals[0], "scale", Vector2(1.38, 1.38), 0.055).set_ease(Tween.EASE_OUT)
	tw.tween_property(_visuals[0], "scale", Vector2(1.0, 1.0),   0.10 ).set_ease(Tween.EASE_IN)


# =============================================================================
# Loss animations
# =============================================================================

func _trigger_loss() -> void:
	set_physics_process(false)
	if randi() % 2 == 0:
		_loss_scattered_beads()
	else:
		_loss_blasted_off()


func _loss_scattered_beads() -> void:
	var tw := create_tween().set_parallel(true)
	for v in _visuals:
		var off := Vector2.from_angle(randf() * TAU) * randf_range(55.0, 130.0)
		tw.tween_property(v, "position", v.position + off, 0.40).set_ease(Tween.EASE_OUT)
		tw.tween_property(v, "rotation", randf_range(-PI, PI), 0.40)
	tw.chain().tween_interval(0.25)
	tw.chain().tween_callback(func():
		var tw2 := create_tween().set_parallel(true)
		for v in _visuals:
			tw2.tween_property(v, "position", _head_pos, 0.35)
			tw2.tween_property(v, "rotation", 0.0, 0.35)
			tw2.tween_property(v, "modulate", Color(1, 1, 1, 0.0), 0.35)
		tw2.chain().tween_callback(func(): worm_defeated.emit())
	)


func _loss_blasted_off() -> void:
	var blast_dir := Vector2.from_angle(randf() * TAU)
	var tw := create_tween().set_parallel(true)
	for i in _visuals.size():
		var v := _visuals[i]
		tw.tween_property(v, "position", v.position + blast_dir * 1400.0, 0.55).set_ease(Tween.EASE_IN)
		tw.tween_property(v, "rotation", blast_dir.angle() + float(i) * 0.45, 0.55)
		tw.tween_property(v, "modulate", Color(1, 1, 1, 0.0), 0.30).set_delay(0.22)
	tw.chain().tween_callback(func(): worm_defeated.emit())
