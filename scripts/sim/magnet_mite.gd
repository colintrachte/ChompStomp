class_name MagnetMite
extends Node2D

# Chaos behavior: metal bug that magnetically pulls nearby food and pickups
# toward itself, hoarding them. When eaten, everything it was pulling scatters.
# test_scene applies the magnetic force and handles the scatter on death.

const WANDER_SPEED  := 22.0
const EAT_RADIUS    := 14.0
const MAGNET_RADIUS := 120.0   # read by test_scene for pull loop

var eaten : bool = false

var _vel  : Vector2 = Vector2.ZERO
var _home : Vector2
var _time : float   = 0.0


func setup(pos: Vector2) -> void:
    position = pos
    _home    = pos
    _vel     = Vector2.from_angle(randf() * TAU) * WANDER_SPEED


func _process(delta: float) -> void:
    if eaten:
        return
    _time += delta
    if randf() < 0.005:
        _vel = Vector2.from_angle(randf() * TAU) * WANDER_SPEED
    var to_home := _home - global_position
    if to_home.length() > 180.0:
        _vel = to_home.normalized() * WANDER_SPEED
    position += _vel * delta
    queue_redraw()


func _draw() -> void:
    # Pulsing magnetic field rings
    var t    := _time
    var ring_a := 0.30 + sin(t * 3.5) * 0.12
    draw_arc(Vector2.ZERO, MAGNET_RADIUS * 0.55, 0.0, TAU, 24,
        Color(0.55, 0.78, 1.00, ring_a * 0.5), 2.0, true)
    draw_arc(Vector2.ZERO, MAGNET_RADIUS * 0.38, 0.0, TAU, 20,
        Color(0.55, 0.78, 1.00, ring_a * 0.7), 1.5, true)

    # Body: silver beetle
    var pts := PackedVector2Array()
    for i in 14:
        var a := TAU * i / 14.0
        var r := 12.0 + sin(a * 3.0) * 2.5
        pts.append(Vector2(cos(a) * r, sin(a) * r))
    draw_colored_polygon(pts, Color(0.68, 0.68, 0.75))

    # Shell dividing line
    draw_line(Vector2(0.0, -11.0), Vector2(0.0, 11.0), Color(0.44, 0.44, 0.50), 1.8)

    # Sheen
    draw_circle(Vector2(-4.0, -4.5), 4.0, Color(0.90, 0.90, 0.96, 0.55))

    # Eyes: glowing blue (magnetic energy)
    draw_circle(Vector2(-4.5, -3.0), 2.5, Color(0.22, 0.62, 1.00))
    draw_circle(Vector2( 4.5, -3.0), 2.5, Color(0.22, 0.62, 1.00))

    # Antennae with magnetic sparkle tips
    var wig := sin(_time * 7.0) * 4.0
    draw_line(Vector2(-3.5, -10.0), Vector2(-7.0 + wig, -19.0), Color(0.55, 0.55, 0.62), 1.5)
    draw_line(Vector2( 3.5, -10.0), Vector2( 7.0 + wig, -19.0), Color(0.55, 0.55, 0.62), 1.5)
    draw_circle(Vector2(-7.0 + wig, -19.0), 3.0, Color(0.30, 0.70, 1.00, 0.80))
    draw_circle(Vector2( 7.0 + wig, -19.0), 3.0, Color(0.30, 0.70, 1.00, 0.80))
