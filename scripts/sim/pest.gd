class_name Pest
extends Node2D

# 0 = Crumb  (tiny scuttling bug, flees worm)
# 1 = Hopper (frog, jumps in arcs — only eatable when landed)
# 2 = StinkBeetle (slow wander, leaves stink cloud when eaten)

const EAT_RADIUS := 12.0
const FLEE_SQ    := 80.0 * 80.0

var pest_type : int  = 0
var eaten     : bool = false
var can_eat   : bool = true   # Hoppers set this false mid-jump

var _home     : Vector2          # wander centre — pests drift back if they roam too far
var _worm     : Worm = null
var _vel      : Vector2 = Vector2.ZERO
var _time     : float   = 0.0

# --- Hopper state ---
var _hop_timer    : float = 0.0
var _hop_cooldown : float = 0.0
var _hop_start    : Vector2
var _hop_target   : Vector2
var _hop_progress : float = 1.0   # 1.0 = landed


func setup(pos: Vector2, kind: int, worm: Worm) -> void:
	position      = pos
	_home         = pos
	pest_type     = kind
	_worm         = worm
	_time         = randf() * TAU
	_hop_cooldown = randf_range(1.0, 2.5)
	match kind:
		0: _vel = Vector2.from_angle(randf() * TAU) * 70.0   # Crumb
		1: _vel = Vector2.ZERO                                # Hopper starts still
		2: _vel = Vector2.from_angle(randf() * TAU) * 38.0   # StinkBeetle


func _process(delta: float) -> void:
	if eaten:
		return
	_time += delta
	match pest_type:
		0: _move_crumb(delta)
		1: _move_hopper(delta)
		2: _move_beetle(delta)
	_drift_home()
	queue_redraw()


# =============================================================================
# Movement
# =============================================================================

func _move_crumb(delta: float) -> void:
	if is_instance_valid(_worm) and (_worm.head_pos - position).length_squared() < FLEE_SQ:
		var away := (position - _worm.head_pos).normalized()
		_vel = away * 120.0
	elif randf() < 0.025:
		_vel = Vector2.from_angle(randf() * TAU) * 70.0
	position += _vel * delta


func _move_hopper(delta: float) -> void:
	if _hop_progress < 1.0:
		# Mid-jump: arc to target
		_hop_progress = minf(_hop_progress + delta / 0.22, 1.0)
		var t := _hop_progress
		# Parabolic arc: position lerps, but y has a hump
		position = _hop_start.lerp(_hop_target, t) + Vector2(0.0, -sin(t * PI) * 40.0)
		can_eat = _hop_progress >= 1.0
		return
	# On ground: wait then jump
	_hop_timer += delta
	if _hop_timer >= _hop_cooldown:
		_hop_timer    = 0.0
		_hop_cooldown = randf_range(0.7, 2.0)
		_hop_start    = position
		var dir := Vector2.from_angle(randf() * TAU)
		_hop_target = position + dir * randf_range(55.0, 120.0)
		# Keep hops within wander radius of spawn
		if (_hop_target - _home).length() > 200.0:
			_hop_target = _home + (_hop_target - _home).normalized() * 200.0
		_hop_progress = 0.0
		can_eat       = false


func _move_beetle(delta: float) -> void:
	if randf() < 0.012:
		_vel = Vector2.from_angle(randf() * TAU) * 38.0
	position += _vel * delta


func _drift_home() -> void:
	# Gently redirect velocity toward home when the pest wanders too far
	var to_home := _home - position
	var dist    := to_home.length()
	if dist > 180.0:
		_vel = _vel.lerp(to_home.normalized() * _vel.length(), 0.08)


# =============================================================================
# Drawing
# =============================================================================

func _draw() -> void:
	match pest_type:
		0: _draw_crumb()
		1: _draw_hopper()
		2: _draw_beetle()


func _draw_crumb() -> void:
	draw_circle(Vector2.ZERO, 8.0, Color(0.78, 0.65, 0.42))
	# Scrabbling legs
	for i in 4:
		var a := PI * 0.5 * float(i) + _time * 9.0
		draw_line(Vector2.ZERO, Vector2(cos(a) * 7.0, sin(a) * 6.0), Color(0.55, 0.42, 0.22), 1.5)


func _draw_hopper() -> void:
	var pts := PackedVector2Array()
	for i in 16:
		var a := TAU * i / 16.0
		pts.append(Vector2(cos(a) * 10.0, sin(a) * 7.5))
	draw_colored_polygon(pts, Color(0.32, 0.72, 0.28))
	draw_circle(Vector2(-4.5, -3.5), 2.5, Color(0.08, 0.08, 0.08))
	draw_circle(Vector2( 4.5, -3.5), 2.5, Color(0.08, 0.08, 0.08))
	# Legs: tucked when jumping, extended when landed
	var leg_y := -7.0 if _hop_progress < 1.0 else 6.0
	draw_line(Vector2(-5.0, 4.5), Vector2(-10.0, leg_y), Color(0.22, 0.55, 0.18), 2.0)
	draw_line(Vector2( 5.0, 4.5), Vector2( 10.0, leg_y), Color(0.22, 0.55, 0.18), 2.0)


func _draw_beetle() -> void:
	var pts := PackedVector2Array()
	for i in 16:
		var a := TAU * i / 16.0
		pts.append(Vector2(cos(a) * 11.0, sin(a) * 8.0))
	draw_colored_polygon(pts, Color(0.14, 0.20, 0.10))
	draw_line(Vector2(0, -6.0), Vector2(0, 6.0), Color(0.28, 0.38, 0.20), 2.0)
	draw_circle(Vector2(-4.5, -2.5), 2.2, Color(0.88, 0.18, 0.10))
	draw_circle(Vector2( 4.5, -2.5), 2.2, Color(0.88, 0.18, 0.10))
	# Antennae waggle
	var wig := sin(_time * 6.0) * 4.0
	draw_line(Vector2(-3.5, -7.0), Vector2(-8.0 + wig, -14.0), Color(0.55, 0.62, 0.48), 1.5)
	draw_line(Vector2( 3.5, -7.0), Vector2( 8.0 + wig, -14.0), Color(0.55, 0.62, 0.48), 1.5)
