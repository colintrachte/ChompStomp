class_name Gull
extends Node2D

# Thief behavior: swoops in from a screen edge, grabs a food item, flies away.
# In solo play this creates a "stop it before it escapes" moment.
# test_scene handles: eat detection (worm eats gull → food respawns)

enum _State { APPROACH, CARRYING, ESCAPED }

const SPEED      := 165.0
const EAT_RADIUS := 18.0

var eaten : bool = false   # set true by test_scene when worm intercepts it

var _state    : _State  = _State.APPROACH
var _food     : Food    = null   # target food (pre-selected by test_scene at spawn)
var _vel      : Vector2
var _exit_dir : Vector2
var _time     := 0.0   # used for wing-flap animation


func setup(spawn_pos: Vector2, target: Food, exit_direction: Vector2) -> void:
    position  = spawn_pos
    _food     = target
    _exit_dir = exit_direction.normalized()
    var to_food := target.global_position - spawn_pos
    _vel = to_food.normalized() * SPEED


func _process(delta: float) -> void:
    if eaten:
        return
    _time += delta

    match _state:
        _State.APPROACH:
            if not is_instance_valid(_food) or _food.eaten:
                # Food gone — leave empty-handed
                _vel      = _exit_dir * SPEED
                _state    = _State.ESCAPED
            else:
                var to_food := _food.global_position - global_position
                if to_food.length() < 20.0:
                    # Grab the food
                    _food.eaten = true
                    _food.queue_free()
                    _food  = null
                    _vel   = _exit_dir * SPEED
                    _state = _State.CARRYING
                else:
                    # Steer toward food
                    _vel = to_food.normalized() * SPEED
            position += _vel * delta

        _State.CARRYING, _State.ESCAPED:
            position += _vel * delta

    queue_redraw()


func _draw() -> void:
    var dir   := _vel.normalized() if _vel.length_squared() > 1.0 else Vector2.RIGHT
    var right := dir.rotated(PI * 0.5)
    var flap  := sin(_time * 14.0)   # fast wing flap

    # Body: cream oval
    var body_pts := PackedVector2Array()
    for i in 16:
        var a := TAU * i / 16.0
        body_pts.append(Vector2(cos(a) * 13.0, sin(a) * 7.0))
    var body_xf := Transform2D(dir.angle(), Vector2.ZERO)
    var body_rotated := PackedVector2Array()
    for v in body_pts:
        body_rotated.append(body_xf * v)
    draw_colored_polygon(body_rotated, Color(0.96, 0.93, 0.82))

    # Wings: two triangles that flap
    var wing_up := flap * 10.0
    # Left wing
    draw_colored_polygon(PackedVector2Array([
        Vector2.ZERO,
        right * 22.0 - dir * 8.0 + Vector2(0.0, -wing_up),
        right * 12.0 + dir * 6.0,
    ]), Color(0.88, 0.84, 0.72))
    # Right wing
    draw_colored_polygon(PackedVector2Array([
        Vector2.ZERO,
        -right * 22.0 - dir * 8.0 + Vector2(0.0, -wing_up),
        -right * 12.0 + dir * 6.0,
    ]), Color(0.88, 0.84, 0.72))

    # Beak: small yellow triangle at the front
    var beak_tip := dir * 16.0
    draw_colored_polygon(PackedVector2Array([
        dir * 12.0 + right * 3.5,
        beak_tip,
        dir * 12.0 - right * 3.5,
    ]), Color(1.0, 0.82, 0.18))

    # Yellow dot = food carried
    if _state == _State.CARRYING:
        draw_circle(-dir * 12.0, 5.0, Color(0.92, 0.78, 0.18))

    # Eye
    draw_circle(dir * 5.0 + right * 4.0, 2.5, Color(0.08, 0.08, 0.08))
