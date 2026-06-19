class_name BoulderBug
extends Node2D

# Bully behavior: armored roly-poly that charges toward the worm.
# Can ONLY be eaten from the soft back end (test_scene checks approach angle).
# Worm hitting the armored front gets knocked back.

enum _State { WANDER, CHARGE, RECOVER }

const WANDER_SPEED  := 38.0
const CHARGE_SPEED  := 175.0
const DETECT_RANGE  := 240.0
const EAT_RADIUS    := 20.0

const CHARGE_DUR  := 0.90
const RECOVER_DUR := 1.50

var eaten  : bool    = false
var facing : Vector2 = Vector2.RIGHT   # armor direction; test_scene reads this

var _state   : _State  = _State.WANDER
var _worm    : Worm    = null
var _vel     : Vector2 = Vector2.ZERO
var _state_t : float   = 0.0
var _time    : float   = 0.0
var _home    : Vector2


func setup(pos: Vector2, worm: Worm) -> void:
    position = pos
    _home    = pos
    _worm    = worm
    facing   = Vector2.from_angle(randf() * TAU)
    _vel     = facing * WANDER_SPEED


func _process(delta: float) -> void:
    if eaten:
        return
    _time  += delta

    match _state:
        _State.WANDER:
            _wander(delta)
            if is_instance_valid(_worm) and _worm.is_alive:
                var to_worm := _worm.head_pos - global_position
                if to_worm.length_squared() < DETECT_RANGE * DETECT_RANGE:
                    _enter_charge(to_worm.normalized())
        _State.CHARGE:
            _state_t += delta
            position += facing * CHARGE_SPEED * delta
            if _state_t >= CHARGE_DUR:
                _enter_recover()
        _State.RECOVER:
            _state_t += delta
            if _state_t >= RECOVER_DUR:
                _state   = _State.WANDER
                _state_t = 0.0
                facing   = -facing

    queue_redraw()


func _wander(delta: float) -> void:
    if randf() < 0.008:
        _vel   = Vector2.from_angle(randf() * TAU) * WANDER_SPEED
    var to_home := _home - global_position
    if to_home.length() > 220.0:
        _vel = to_home.normalized() * WANDER_SPEED
    position += _vel * delta


func _enter_charge(dir: Vector2) -> void:
    _state   = _State.CHARGE
    facing   = dir
    _vel     = Vector2.ZERO
    _state_t = 0.0


func _enter_recover() -> void:
    _state   = _State.RECOVER
    _state_t = 0.0
    facing   = -facing
    _vel     = facing * WANDER_SPEED * 0.5


func _draw() -> void:
    var right := facing.rotated(PI * 0.5)
    var blink := _state == _State.CHARGE

    # Main body: dark grey circle
    draw_circle(Vector2.ZERO, 18.0, Color(0.28, 0.26, 0.32))

    # Shiny armor shell — front semicircle fan aligned to facing direction
    var armor_pts := PackedVector2Array()
    armor_pts.append(Vector2.ZERO)
    for i in 9:
        var a := facing.angle() - PI * 0.5 + PI * float(i) / 8.0
        armor_pts.append(Vector2(cos(a) * 20.0, sin(a) * 20.0))
    draw_colored_polygon(armor_pts, Color(0.72, 0.70, 0.78))
    # Armor gleam
    draw_circle(facing * 8.0, 5.5, Color(0.90, 0.88, 0.94, 0.70))

    # Dots for soft back texture
    for i in 3:
        var dp := -facing * (6.0 + float(i) * 4.0) + right * (float(i % 2) - 0.5) * 6.0
        draw_circle(dp, 2.2, Color(0.42, 0.38, 0.45, 0.60))

    # Eyes on armor side
    var eye_base := facing * 10.0
    var eye_col  := Color(1.0, 0.22, 0.10) if blink else Color(0.08, 0.08, 0.08)
    draw_circle(eye_base + right * 5.0, 3.0, eye_col)
    draw_circle(eye_base - right * 5.0, 3.0, eye_col)

    # Tiny legs
    for i in 3:
        var t    := float(i) / 3.0
        var lpos := -facing * (4.0 + t * 8.0)
        draw_line(lpos + right * 16.0, lpos + right * 24.0, Color(0.40, 0.36, 0.44), 2.0)
        draw_line(lpos - right * 16.0, lpos - right * 24.0, Color(0.40, 0.36, 0.44), 2.0)
