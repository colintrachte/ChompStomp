class_name ComboEffect
extends Node2D

const Combos := preload("res://scripts/sim/combos.gd")

# Self-removing visual effect spawned at combo resolution.
# Uses sprite-frame-style drawn animation (no particles).

var _time     := 0.0
var _duration := 0.70
var _combo    := 0


func setup(combo: int) -> void:
	_combo = combo
	match combo:
		Combos.FIRE_GAS:       _duration = 0.90
		Combos.FIRE_MASS:      _duration = 0.55
		Combos.FIRE_BOUNCE:    _duration = 0.50
		Combos.GAS_MASS:       _duration = 0.80
		Combos.GAS_BOUNCE:     _duration = 0.65
		Combos.MASS_BOUNCE:    _duration = 0.65
		Combos.AMPLIFY_FIRE:   _duration = 0.70
		Combos.AMPLIFY_GAS:    _duration = 0.65
		Combos.AMPLIFY_MASS:   _duration = 0.60
		Combos.AMPLIFY_BOUNCE: _duration = 0.55
		_:                     _duration = 0.45


func _process(delta: float) -> void:
	_time += delta
	if _time >= _duration:
		queue_free()
		return
	queue_redraw()


func _draw() -> void:
	var t := _time / _duration
	match _combo:
		Combos.FIRE_GAS:       _draw_fire_gas(t)
		Combos.FIRE_MASS:      _draw_fire_mass(t)
		Combos.FIRE_BOUNCE:    _draw_fire_bounce(t)
		Combos.GAS_MASS:       _draw_gas_mass(t)
		Combos.GAS_BOUNCE:     _draw_gas_bounce(t)
		Combos.MASS_BOUNCE:    _draw_mass_bounce(t)
		Combos.AMPLIFY_FIRE:   _draw_amplify(t, Color(1.0, 0.42, 0.08))
		Combos.AMPLIFY_GAS:    _draw_amplify(t, Color(0.30, 0.88, 0.28))
		Combos.AMPLIFY_MASS:   _draw_amplify(t, Color(0.62, 0.52, 0.72))
		Combos.AMPLIFY_BOUNCE: _draw_amplify(t, Color(0.18, 0.62, 1.00))
		_:                     _draw_amplify(t, Color(1.0, 1.0, 0.80))


# fire + gas: 3 expanding orange/red rings + central flash
func _draw_fire_gas(t: float) -> void:
	if t < 0.30:
		var ft := t / 0.30
		draw_circle(Vector2.ZERO, lerpf(0.0, 55.0, ft), Color(1.0, 0.92, 0.72, 1.0 - ft))
	for i in 3:
		var delay := float(i) * 0.20
		var rt    := clampf((t - delay) * 1.6, 0.0, 1.0)
		if rt <= 0.0:
			continue
		var r   := lerpf(22.0, 240.0, pow(rt, 0.55))
		var w   := lerpf(18.0, 2.0, rt)
		var col := Color(1.0, lerpf(0.50, 0.12, rt), 0.08, 1.0 - rt)
		draw_arc(Vector2.ZERO, r, 0.0, TAU, 48, col, w, true)


# fire + mass: orange impact ring + hot core
func _draw_fire_mass(t: float) -> void:
	var r   := lerpf(12.0, 95.0, t)
	var w   := lerpf(16.0, 2.0, t)
	draw_arc(Vector2.ZERO, r, 0.0, TAU, 32, Color(1.0, 0.42, 0.08, 1.0 - t), w, true)
	if t < 0.35:
		var ft := t / 0.35
		draw_circle(Vector2.ZERO, lerpf(10.0, 0.0, ft), Color(1.0, 0.88, 0.40, 1.0 - ft))


# fire + bounce: horizontal orange streak
func _draw_fire_bounce(t: float) -> void:
	for i in 5:
		var ft  := clampf(t - float(i) * 0.07, 0.0, 1.0)
		var len := lerpf(0.0, 90.0, ft) * (1.0 - float(i) * 0.18)
		var a   := (1.0 - ft) - float(i) * 0.18
		if a <= 0.0:
			continue
		draw_line(Vector2(-len, 0.0), Vector2.ZERO,
			Color(1.0, lerpf(0.65, 0.12, ft), 0.08, a), lerpf(9.0, 2.0, ft))
	draw_arc(Vector2.ZERO, lerpf(5.0, 60.0, t), 0.0, TAU, 24,
		Color(1.0, 0.80, 0.30, 1.0 - t), 4.0, true)


# gas + mass: green lift circle then grey slam shockwave
func _draw_gas_mass(t: float) -> void:
	if t < 0.52:
		var rt  := t / 0.52
		var y   := lerpf(0.0, -65.0, rt)
		var col := Color(0.30, 0.88, 0.28, 1.0 - rt * 0.45)
		draw_circle(Vector2(0.0, y), lerpf(12.0, 32.0, rt), col)
	if t >= 0.44:
		var st  := (t - 0.44) / 0.56
		var r   := lerpf(10.0, 175.0, pow(st, 0.5))
		var col := Color(0.62, 0.52, 0.72, 1.0 - st)
		draw_arc(Vector2.ZERO, r, 0.0, TAU, 36, col, lerpf(14.0, 2.0, st), true)


# gas + bounce: expanding translucent bubble with bright rim
func _draw_gas_bounce(t: float) -> void:
	var r := lerpf(14.0, 160.0, t)
	draw_circle(Vector2.ZERO, r, Color(0.30, 0.88, 0.80, (1.0 - t) * 0.50))
	draw_arc(Vector2.ZERO, r, 0.0, TAU, 32, Color(0.20, 0.65, 1.00, 1.0 - t), 3.5, true)


# mass + bounce: two overlapping rings — purple-grey outer, blue inner
func _draw_mass_bounce(t: float) -> void:
	var r1 := lerpf(18.0, 130.0, t)
	var r2 := lerpf(10.0,  85.0, clampf(t * 1.4, 0.0, 1.0))
	draw_arc(Vector2.ZERO, r1, 0.0, TAU, 32,
		Color(0.62, 0.52, 0.72, 1.0 - t), lerpf(12.0, 2.0, t), true)
	draw_arc(Vector2.ZERO, r2, 0.0, TAU, 24,
		Color(0.18, 0.62, 1.00, 1.0 - t), lerpf(8.0, 1.5, t), true)


# Amplify: single ring in tag color + brief hot core
func _draw_amplify(t: float, col: Color) -> void:
	var r := lerpf(10.0, 110.0, t)
	col.a = 1.0 - t
	draw_arc(Vector2.ZERO, r, 0.0, TAU, 28, col, lerpf(14.0, 2.0, t), true)
	if t < 0.40:
		var ft := t / 0.40
		draw_circle(Vector2.ZERO, lerpf(8.0, 0.0, ft), Color(1.0, 1.0, 0.80, 1.0 - ft))
