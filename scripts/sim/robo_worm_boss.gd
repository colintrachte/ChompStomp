class_name RoboWormBoss
extends Node2D

signal boss_defeated
signal hit_player

# Movement (px/tick at 30 Hz)
const ORBIT_SPEED  := 5.5    # ~165 px/s
const CHARGE_SPEED := 14.0   # ~420 px/s

const BODY_SEG_COUNT := 5    # body segments (not counting head)
const SEG_GAP        := 6    # history ticks between consecutive segments
const HEAD_HALF      := 30.0
const BODY_HALF      := 24.0

enum _State { ORBIT, TELEGRAPH, CHARGE, RECOVER }

var _state      : _State = _State.ORBIT
var _ticks      : int    = 0    # general-purpose tick counter for state timer
var _orbit_tick : int    = 0    # running tick for orbit angle

var _head_pos   : Vector2
var _direction  : Vector2 = Vector2.RIGHT
var _history    : Array[Vector2] = []
var _visuals    : Array[Polygon2D] = []   # [0]=head, [1..5]=body
var _alive_segs : int    = BODY_SEG_COUNT # remaining body segments

var _arena         : Rect2
var _player        : Worm = null
var _orbit_center  : Vector2
var _charge_target : Vector2

# How many ticks to spend in each state (randomised at transition)
var _state_duration : int = 240   # start with 8 s in orbit


# --- Exposed for test-scene collision ---
var head_pos: Vector2:
	get: return _head_pos
var head_half: float:
	get: return HEAD_HALF

var tail_pos: Vector2:
	get:
		if _alive_segs <= 0:
			return Vector2(-99999.0, -99999.0)
		var idx := mini(_alive_segs * SEG_GAP, _history.size() - 1)
		return _history[idx]
var tail_half: float:
	get: return BODY_HALF

var is_charging: bool:
	get: return _state == _State.CHARGE

var alive: bool:
	get: return _alive_segs >= 0 and is_inside_tree()


func setup(arena: Rect2, player: Worm) -> void:
	_arena        = arena
	_player       = player
	_orbit_center = arena.get_center()
	_head_pos     = _orbit_center + Vector2(280.0, 0.0)
	_direction    = Vector2.UP

	var max_hist := BODY_SEG_COUNT * SEG_GAP + 1
	_history.resize(max_hist)
	_history.fill(_head_pos)

	# Head
	_make_segment(HEAD_HALF, Color(0.42, 0.44, 0.50))
	# Body segments
	for i in BODY_SEG_COUNT:
		_make_segment(BODY_HALF, Color(0.32, 0.34, 0.40))

	_sync_visuals()
	for v in _visuals:
		v.reset_physics_interpolation()

	_state_duration = randi_range(180, 270)   # first orbit before first charge


func eat_tail_segment() -> void:
	if _alive_segs <= 0:
		return
	# Hide the last living body segment (index = _alive_segs)
	_visuals[_alive_segs].visible = false
	_alive_segs -= 1
	if _alive_segs <= 0:
		_on_defeated()


func _physics_process(_delta: float) -> void:
	_ticks += 1
	_orbit_tick += 1

	match _state:
		_State.ORBIT:
			_do_orbit()
			if _ticks >= _state_duration:
				_enter_telegraph()

		_State.TELEGRAPH:
			_do_orbit_slow()
			# Flash head red
			_visuals[0].modulate = Color(1, 0.22, 0.22) if (_ticks % 8) < 4 else Color(1, 1, 1)
			if _ticks >= _state_duration:
				_enter_charge()

		_State.CHARGE:
			_do_charge()
			if _ticks >= _state_duration:
				_enter_recover()

		_State.RECOVER:
			_do_orbit_slow()
			_visuals[0].modulate = Color(1, 1, 1)
			if _ticks >= _state_duration:
				_enter_orbit()

	_history.push_front(_head_pos)
	if _history.size() > BODY_SEG_COUNT * SEG_GAP + 1:
		_history.resize(BODY_SEG_COUNT * SEG_GAP + 1)

	_sync_visuals()


# =============================================================================
# State transitions
# =============================================================================

func _enter_telegraph() -> void:
	_state = _State.TELEGRAPH
	_ticks = 0
	_state_duration = 42   # 1.4 s of flashing


func _enter_charge() -> void:
	_state  = _State.CHARGE
	_ticks  = 0
	_state_duration = 22   # 0.73 s charge
	if is_instance_valid(_player):
		_charge_target = _player.head_pos
	else:
		_charge_target = _head_pos + _direction * 200.0
	_direction = (_charge_target - _head_pos).normalized()


func _enter_recover() -> void:
	_state = _State.RECOVER
	_ticks = 0
	_state_duration = 55   # ~1.8 s recover
	_visuals[0].modulate = Color(1, 1, 1)


func _enter_orbit() -> void:
	_state = _State.ORBIT
	_ticks = 0
	_state_duration = randi_range(150, 240)   # 5-8 s before next charge


# =============================================================================
# Movement modes
# =============================================================================

func _do_orbit() -> void:
	var angle  := float(_orbit_tick) * ORBIT_SPEED / 280.0   # radians, 280 = orbit radius
	var target := _orbit_center + Vector2(cos(angle), sin(angle)) * 280.0
	_direction = (target - _head_pos).normalized()
	_head_pos += _direction * ORBIT_SPEED
	_clamp_arena()


func _do_orbit_slow() -> void:
	var angle  := float(_orbit_tick) * (ORBIT_SPEED * 0.35) / 280.0
	var target := _orbit_center + Vector2(cos(angle), sin(angle)) * 280.0
	_direction = (target - _head_pos).normalized()
	_head_pos += _direction * (ORBIT_SPEED * 0.35)
	_clamp_arena()


func _do_charge() -> void:
	_head_pos += _direction * CHARGE_SPEED
	_clamp_arena()


func _clamp_arena() -> void:
	_head_pos.x = clampf(_head_pos.x, _arena.position.x + HEAD_HALF, _arena.end.x - HEAD_HALF)
	_head_pos.y = clampf(_head_pos.y, _arena.position.y + HEAD_HALF, _arena.end.y - HEAD_HALF)


# =============================================================================
# Helpers
# =============================================================================

func _make_segment(half: float, color: Color) -> void:
	var poly := Polygon2D.new()
	poly.polygon = WormData.shape_verts(0, half)
	poly.color   = color
	add_child(poly)
	_visuals.append(poly)


func _sync_visuals() -> void:
	_visuals[0].global_position = _head_pos
	for i in range(1, _alive_segs + 1):
		var idx := mini(i * SEG_GAP, _history.size() - 1)
		_visuals[i].global_position = _history[idx]


func _on_defeated() -> void:
	set_physics_process(false)
	# Bounce all remaining visuals off screen before freeing
	var tw := create_tween().set_parallel(true)
	for v in _visuals:
		if v.visible:
			var dir := (v.position - _orbit_center).normalized()
			tw.tween_property(v, "position", v.position + dir * 800.0, 0.5).set_ease(Tween.EASE_IN)
			tw.tween_property(v, "modulate", Color(1, 1, 1, 0.0), 0.4).set_delay(0.1)
	tw.chain().tween_callback(func():
		boss_defeated.emit()
		queue_free()
	)
