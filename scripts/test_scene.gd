extends Node2D

const FOOD_TARGET    := 10
const PICKUP_TARGET  := 3
const PEST_COUNTS    := [[0, 5], [1, 2], [2, 2]]   # Crumb×5, Hopper×2, StinkBeetle×2
const SPAWN_MIN      := 500.0
const SPAWN_MAX      := 850.0
const DESPAWN_DIST   := 1200.0

# Back button lives in screen space (CanvasLayer) — stays put while camera moves
const _BACK_RECT := Rect2(8, 8, 60, 60)

var _worm    : Worm
var _camera  : Camera2D # <-- Add this line
var _foods   : Array[Food] = []
var _pests   : Array[Pest] = []
var _pickups : Array[WeaponPickup] = []
var _clouds  : Array[StinkCloud] = []
var _boss    : RoboWormBoss = null
var _audio   : AudioStreamPlayer
var _boss_spawned := false
var _stream_timer := 0.0

# --- Active combo effect timers (seconds) ---
var _ram_timer    := 0.0   # FIRE_MASS / AMPLIFY_MASS: kill pests on contact
var _dash_timer   := 0.0   # FIRE_BOUNCE / AMPLIFY_BOUNCE: kill pests on contact (speed via worm)
var _pinball_t    := 0.0   # MASS_BOUNCE: kill pests on contact (speed via worm)

# --- Behavioral enemy arrays (thieves, bullies, chaos-makers) ---
var _gulls  : Array[Gull] = []
var _bbugs  : Array[BoulderBug] = []
var _mmites : Array[MagnetMite] = []

var _thief_timer := 20.0
var _bully_timer := 38.0
var _chaos_timer := 28.0

# --- Rolling hazard (Green Hill moving boulder) ---
const HAZARD_RADIUS := 28.0
const HAZARD_BOUNDS := Rect2(-900.0, -700.0, 1800.0, 1400.0)

var _hazard_pos := Vector2(380.0, 0.0)
var _hazard_vel := Vector2(72.0, 55.0)   # px/sec
var _hazard_rot := 0.0

# --- Speed pads (fixed world positions) ---
const SPEED_PAD_R     := 32.0
const SPEED_PAD_BOOST := 1.8
const SPEED_PAD_DUR   := 1.5

var _speed_pads := [
	{"pos": Vector2( 340.0,  180.0), "dir": Vector2(1.0, 0.0)},
	{"pos": Vector2(-340.0,  180.0), "dir": Vector2(-1.0, 0.0)},
	{"pos": Vector2(   0.0, -380.0), "dir": Vector2(0.0, -1.0)},
	{"pos": Vector2(   0.0,  380.0), "dir": Vector2(0.0,  1.0)},
	{"pos": Vector2( 560.0, -180.0), "dir": Vector2(1.0, 0.0)},
	{"pos": Vector2(-560.0, -180.0), "dir": Vector2(-1.0, 0.0)},
]


func _input(event: InputEvent) -> void:
	var sp := Vector2(-1.0, -1.0)
	if event is InputEventScreenTouch and event.pressed:
		sp = event.position
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		sp = event.position
	if sp.x >= 0.0 and _BACK_RECT.has_point(sp):
		get_tree().change_scene_to_file("res://scenes/worm_builder.tscn")


func _ready() -> void:
	var vp := get_viewport_rect().size
	RenderingServer.set_default_clear_color(Color(0.07, 0.11, 0.07))

	_audio = AudioStreamPlayer.new()
	_audio.volume_db = -4.0
	add_child(_audio)

	var data := _load_current_kid_data()

	_worm = Worm.new()
	add_child(_worm)
	_worm.setup(vp / 2.0, data)
	_worm.evolved.connect(_on_evolved)
	_worm.worm_defeated.connect(_on_worm_defeated)

	# Instantiate camera independently in the world
	_camera = Camera2D.new()
	_camera.global_position = _worm.head_pos
	add_child(_camera)

	for _i in FOOD_TARGET:
		_spawn_food()

	for pair in PEST_COUNTS:
		for _j in (pair[1] as int):
			_spawn_pest(pair[0] as int)

	# Spawn one of each starter pickup type
	for k in [WeaponPickup.CHILI, WeaponPickup.FIZZY, WeaponPickup.BOULDER]:
		_spawn_pickup(k)

	_build_hud()


func _build_hud() -> void:
	var ui := CanvasLayer.new()
	add_child(ui)
	var arrow := Polygon2D.new()
	arrow.polygon = PackedVector2Array([
		Vector2(52, 14), Vector2(20, 38), Vector2(52, 62),
		Vector2(52, 50), Vector2(36, 38), Vector2(52, 26),
	])
	arrow.color = Color(0.55, 0.70, 0.50, 0.80)
	ui.add_child(arrow)
	var lbl := Label.new()
	lbl.text = "BACK"
	lbl.position = Vector2(60, 24)
	lbl.add_theme_font_size_override("font_size", 18)
	lbl.add_theme_color_override("font_color", Color(0.55, 0.70, 0.50, 0.80))
	ui.add_child(lbl)


func _process(delta: float) -> void:
	# Update camera position to follow smooth visual movement
	if is_instance_valid(_camera) and is_instance_valid(_worm) and _worm.is_alive:
		_camera.global_position = _worm.head_visual_pos

	if not _worm.is_alive:
		return
	_stream_timer += delta
	if _stream_timer >= 2.0:
		_stream_timer = 0.0
		_stream_world()

	# Occasional thief / bully / chaos spawns
	_thief_timer -= delta
	if _thief_timer <= 0.0:
		_thief_timer = randf_range(22.0, 40.0)
		_spawn_gull()

	_bully_timer -= delta
	if _bully_timer <= 0.0:
		_bully_timer = randf_range(35.0, 55.0)
		_spawn_boulder_bug()

	_chaos_timer -= delta
	if _chaos_timer <= 0.0:
		_chaos_timer = randf_range(25.0, 45.0)
		_spawn_magnet_mite()

	queue_redraw()


func _physics_process(delta: float) -> void:
	if not _worm.is_alive:
		return

	var head := _worm.head_pos
	var hr   := _worm.head_radius
	var fi   := _worm.face_idx

	# --- Face ability: food magnet (cat=3 weak, bunny=4 medium, silly=5 strong) ---
	# Matches Chloe's drawing: tongue/silly makes food "bounce back", bunny/cat same idea
	if fi == 3 or fi == 4 or fi == 5:
		var magnet_r := 65.0 if fi == 3 else (115.0 if fi == 4 else 145.0)
		var pull     := 0.50 if fi == 3 else (0.80  if fi == 4 else 1.25 )
		var magnet_sq := magnet_r * magnet_r
		for food in _foods:
			if not is_instance_valid(food) or food.eaten:
				continue
			var d := food.global_position - head
			var dsq := d.length_squared()
			if dsq > 1.0 and dsq < magnet_sq:
				food.position -= d.normalized() * pull

	# --- Worm eats food ---
	var eat_food_sq := pow(hr + Food.EAT_RADIUS, 2.0)
	for food in _foods.duplicate():
		if not is_instance_valid(food) or food.eaten:
			continue
		if (head - food.global_position).length_squared() < eat_food_sq:
			_eat_food(food)

	# --- Worm eats pests ---
	var eat_pest_sq := pow(hr + Pest.EAT_RADIUS, 2.0)
	for pest in _pests.duplicate():
		if not is_instance_valid(pest) or pest.eaten or not pest.can_eat:
			continue
		if (head - pest.global_position).length_squared() < eat_pest_sq:
			_eat_pest(pest)

	# --- Boss collision ---
	if is_instance_valid(_boss) and _boss.alive:
		var tail_sq := pow(hr + _boss.tail_half, 2.0)
		if (head - _boss.tail_pos).length_squared() < tail_sq:
			_boss.eat_tail_segment()
			_worm.eat_food(0)
			_worm.chomp_flash()
			_play_eat()

		if _boss.is_charging:
			var charge_sq := pow(hr + _boss.head_half, 2.0)
			if (head - _boss.head_pos).length_squared() < charge_sq:
				_worm.take_hit()
				_play_hit()

	# --- Weapon pickup collision ---
	var eat_pickup_sq := pow(hr + WeaponPickup.EAT_RADIUS, 2.0)
	for pickup in _pickups.duplicate():
		if not is_instance_valid(pickup) or pickup.eaten:
			continue
		if (head - pickup.global_position).length_squared() < eat_pickup_sq:
			_eat_pickup(pickup)

	# --- Active combo effect: ram (FIRE_MASS / AMPLIFY_MASS) ---
	if _ram_timer > 0.0:
		_ram_timer -= delta
		var ram_sq := pow(hr * 1.8, 2.0)
		for pest in _pests.duplicate():
			if not is_instance_valid(pest) or pest.eaten:
				continue
			if (head - pest.global_position).length_squared() < ram_sq:
				_eat_pest(pest)

	# --- Active combo effect: dash / pinball (FIRE_BOUNCE / MASS_BOUNCE / AMPLIFY_BOUNCE) ---
	if _dash_timer > 0.0 or _pinball_t > 0.0:
		if _dash_timer > 0.0:
			_dash_timer -= delta
		if _pinball_t > 0.0:
			_pinball_t -= delta
		var kill_sq := pow(hr + Pest.EAT_RADIUS, 2.0)
		for pest in _pests.duplicate():
			if not is_instance_valid(pest) or pest.eaten:
				continue
			if (head - pest.global_position).length_squared() < kill_sq:
				_eat_pest(pest)

	# --- Rolling hazard movement + collision ---
	_hazard_pos += _hazard_vel * delta
	_hazard_rot += _hazard_vel.length() * delta * 0.018
	if _hazard_pos.x <= HAZARD_BOUNDS.position.x + HAZARD_RADIUS:
		_hazard_vel.x = absf(_hazard_vel.x)
	elif _hazard_pos.x >= HAZARD_BOUNDS.end.x - HAZARD_RADIUS:
		_hazard_vel.x = -absf(_hazard_vel.x)
	if _hazard_pos.y <= HAZARD_BOUNDS.position.y + HAZARD_RADIUS:
		_hazard_vel.y = absf(_hazard_vel.y)
	elif _hazard_pos.y >= HAZARD_BOUNDS.end.y - HAZARD_RADIUS:
		_hazard_vel.y = -absf(_hazard_vel.y)
	if (head - _hazard_pos).length_squared() < pow(hr + HAZARD_RADIUS, 2.0):
		_worm.take_hit()
		_play_hit()

	# --- Speed pads ---
	for pad in _speed_pads:
		if (head - (pad["pos"] as Vector2)).length_squared() < SPEED_PAD_R * SPEED_PAD_R:
			_worm.apply_speed_boost(SPEED_PAD_BOOST, SPEED_PAD_DUR)
			break

	# --- Magnet mite pulls food / pickups ---
	for mite in _mmites:
		if not is_instance_valid(mite) or mite.eaten:
			continue
		var mp    := mite.global_position
		var msq   := MagnetMite.MAGNET_RADIUS * MagnetMite.MAGNET_RADIUS
		for food in _foods:
			if not is_instance_valid(food) or food.eaten:
				continue
			var df := mp - food.global_position
			if df.length_squared() < msq and df.length_squared() > 1.0:
				food.position += df.normalized() * 0.9
		for pickup in _pickups:
			if not is_instance_valid(pickup) or pickup.eaten:
				continue
			var dp := mp - pickup.global_position
			if dp.length_squared() < msq and dp.length_squared() > 1.0:
				pickup.position += dp.normalized() * 0.65
# --- Gull: worm intercepts it before it escapes ---
	var gull_sq := pow(hr + Gull.EAT_RADIUS, 2.0)
	var next_gulls: Array[Gull] = []
	for gull in _gulls:
		if not is_instance_valid(gull):
			continue
		if gull.eaten:
			gull.queue_free()
			continue
		
		if (head - gull.global_position).length_squared() < gull_sq:
			gull.eaten = true
			_worm.eat_food(0)
			_worm.chomp_flash()
			_play_eat()
			var drop := Food.new()
			drop.setup(gull.global_position, randi() % 3)
			add_child(drop)
			_foods.append(drop)
			gull.queue_free()
		else:
			next_gulls.append(gull)
	_gulls = next_gulls

	# --- Boulder Bug: eat from behind; armored front knocks back ---
	var bbug_sq := pow(hr + BoulderBug.EAT_RADIUS, 2.0)
	var next_bbugs: Array[BoulderBug] = []
	for bbug in _bbugs:
		if not is_instance_valid(bbug):
			continue
		if bbug.eaten:
			bbug.queue_free()
			continue

		if (head - bbug.global_position).length_squared() < bbug_sq:
			var to_bug: Vector2 = (bbug.global_position - head).normalized()
			if to_bug.dot(bbug.facing) > 0.30:
				bbug.eaten = true
				_worm.eat_food(0)
				_worm.eat_food(0)
				_worm.chomp_flash()
				_play_eat()
				bbug.queue_free()
			else:
				_worm.take_hit()
				_play_hit()
				next_bbugs.append(bbug)
		else:
			next_bbugs.append(bbug)
	_bbugs = next_bbugs

	# --- Magnet Mite: worm eats it → scatter hoard ---
	var mite_sq := pow(hr + MagnetMite.EAT_RADIUS, 2.0)
	var next_mmites: Array[MagnetMite] = []
	for mite in _mmites:
		if not is_instance_valid(mite):
			continue
		if mite.eaten:
			mite.queue_free()
			continue

		if (head - mite.global_position).length_squared() < mite_sq:
			mite.eaten = true
			_worm.eat_food(0)
			_worm.chomp_flash()
			_play_eat()
			_scatter_around(mite.global_position, MagnetMite.MAGNET_RADIUS)
			mite.queue_free()
		else:
			next_mmites.append(mite)
	_mmites = next_mmites
	# --- Stink clouds hit worm ---
	var cloud_sq := StinkCloud.RADIUS * StinkCloud.RADIUS
	var next_clouds: Array[StinkCloud] = []
	for cloud in _clouds:
		if is_instance_valid(cloud):
			if (head - cloud.global_position).length_squared() < cloud_sq:
				_worm.sneeze()
			next_clouds.append(cloud)
	_clouds = next_clouds

# =============================================================================
# Streaming: despawn distant items, replenish near worm
# =============================================================================
func _stream_world() -> void:
	var head       := _worm.head_pos
	var despawn_sq := DESPAWN_DIST * DESPAWN_DIST

	# --- Filter Foods ---
	var next_foods: Array[Food] = []
	for food in _foods:
		if is_instance_valid(food):
			if (head - food.global_position).length_squared() > despawn_sq:
				food.queue_free()
			else:
				next_foods.append(food)
	_foods = next_foods

	# --- Filter Pests ---
	var next_pests: Array[Pest] = []
	for pest in _pests:
		if is_instance_valid(pest):
			if (head - pest.global_position).length_squared() > despawn_sq:
				pest.queue_free()
			else:
				next_pests.append(pest)
	_pests = next_pests

	# --- Filter Pickups ---
	var next_pickups: Array[WeaponPickup] = []
	for pickup in _pickups:
		if is_instance_valid(pickup):
			if (head - pickup.global_position).length_squared() > despawn_sq:
				pickup.queue_free()
			else:
				next_pickups.append(pickup)
	_pickups = next_pickups

	# --- Filter Gulls ---
	var next_gulls: Array[Gull] = []
	for gull in _gulls:
		if is_instance_valid(gull):
			if (head - gull.global_position).length_squared() > despawn_sq:
				gull.queue_free()
			else:
				next_gulls.append(gull)
	_gulls = next_gulls

	# --- Filter Boulder Bugs ---
	var next_bbugs: Array[BoulderBug] = []
	for bbug in _bbugs:
		if is_instance_valid(bbug):
			if (head - bbug.global_position).length_squared() > despawn_sq:
				bbug.queue_free()
			else:
				next_bbugs.append(bbug)
	_bbugs = next_bbugs

	# --- Filter Magnet Mites ---
	var next_mmites: Array[MagnetMite] = []
	for mite in _mmites:
		if is_instance_valid(mite):
			if (head - mite.global_position).length_squared() > despawn_sq:
				mite.queue_free()
			else:
				next_mmites.append(mite)
	_mmites = next_mmites

	# --- Replenish Items ---
	while _foods.size() < FOOD_TARGET:
		_spawn_food()

	var pest_target := 0
	for pair in PEST_COUNTS:
		pest_target += (pair[1] as int)
	while _pests.size() < pest_target:
		_spawn_pest(randi() % 3)

	while _pickups.size() < PICKUP_TARGET:
		_spawn_pickup(randi() % 4)
		
	# --- Filter Stink Clouds ---
	var next_clouds: Array[StinkCloud] = []
	for cloud in _clouds:
		if is_instance_valid(cloud):
			if (head - cloud.global_position).length_squared() > despawn_sq:
				cloud.queue_free()
			else:
				next_clouds.append(cloud)
	_clouds = next_clouds

# =============================================================================
# Weapon pickup management
# =============================================================================

func _eat_pickup(pickup: WeaponPickup) -> void:
	pickup.eaten = true
	_pickups.erase(pickup)
	var new_tag  := pickup.tag()
	var prev_tag := _worm.active_tag
	_worm.chomp_flash()

	if prev_tag != Combos.NONE:
		_worm.clear_tag()
		var combo := Combos.resolve(prev_tag, new_tag)
		_apply_combo(combo, _worm.head_pos)
	else:
		_worm.load_tag(new_tag)
		_play_eat()

	pickup.queue_free()
	get_tree().create_timer(randf_range(6.0, 12.0)).timeout.connect(
		func(): _spawn_pickup(randi() % 4), CONNECT_ONE_SHOT
	)


func _spawn_pickup(kind: int) -> void:
	var pickup := WeaponPickup.new()
	pickup.setup(_random_world_pos(), kind)
	add_child(pickup)
	_pickups.append(pickup)


# =============================================================================
# Combo resolution
# =============================================================================

func _apply_combo(combo: int, pos: Vector2) -> void:
	var effect: ComboEffect = ComboEffect.new()
	effect.position = pos
	effect.setup(combo)
	add_child(effect)
	_play_combo_sound(combo)

	match combo:
		Combos.FIRE_GAS:
			_kill_pests_in_radius(pos, 220.0)
			if is_instance_valid(_boss) and _boss.alive:
				_boss.eat_tail_segment()
				_boss.eat_tail_segment()
			_screen_flash(Color(1.0, 0.65, 0.10), 0.45)

		Combos.FIRE_MASS:
			_ram_timer = 3.5

		Combos.FIRE_BOUNCE:
			_worm.apply_speed_boost(2.2, 2.5)
			_dash_timer = 2.5

		Combos.GAS_MASS:
			_kill_pests_in_radius(pos, 140.0)
			_freeze_pests(3.5)

		Combos.GAS_BOUNCE:
			_freeze_pests(4.0)

		Combos.MASS_BOUNCE:
			_worm.apply_speed_boost(1.6, 3.5)
			_pinball_t = 3.5

		Combos.AMPLIFY_FIRE:
			_kill_pests_in_radius(pos, 120.0)

		Combos.AMPLIFY_GAS:
			_freeze_pests(5.0)

		Combos.AMPLIFY_MASS:
			_ram_timer = 4.5

		Combos.AMPLIFY_BOUNCE:
			_worm.apply_speed_boost(3.0, 3.0)
			_dash_timer = 3.0

		_:
			pass   # DEFAULT: both single-tag effects already happened; visual effect only


func _kill_pests_in_radius(pos: Vector2, radius: float) -> void:
	var rsq := radius * radius
	for pest in _pests.duplicate():
		if not is_instance_valid(pest) or pest.eaten:
			continue
		if (pos - pest.global_position).length_squared() < rsq:
			_eat_pest(pest)


func _freeze_pests(duration: float) -> void:
	for pest in _pests:
		if is_instance_valid(pest) and not pest.eaten:
			pest.freeze_for(duration)


func _screen_flash(color: Color, duration: float) -> void:
	var vp    := get_viewport_rect().size
	var cl    := CanvasLayer.new()
	cl.layer  = 10
	var rect  := ColorRect.new()
	rect.size  = vp
	rect.color = Color(color.r, color.g, color.b, 0.45)
	cl.add_child(rect)
	add_child(cl)
	var tw := create_tween()
	tw.tween_property(rect, "color:a", 0.0, duration)
	tw.tween_callback(func(): cl.queue_free())


# =============================================================================
# Food management
# =============================================================================

func _eat_food(food: Food) -> void:
	food.eaten = true
	_foods.erase(food)
	_worm.eat_food(food.food_type)
	_worm.chomp_flash()
	_play_eat()
	call_deferred("_spawn_food")

	# Surprised face: eating food blasts nearby pests outward
	if _worm.face_idx == 2:
		var eat_pos := food.global_position
		for pest in _pests:
			if not is_instance_valid(pest) or pest.eaten:
				continue
			var d := pest.global_position - eat_pos
			var dsq := d.length_squared()
			if dsq > 1.0 and dsq < 90.0 * 90.0:
				pest.apply_knockback(d.normalized() * 110.0)

	food.queue_free()


func _spawn_food() -> void:
	var food := Food.new()
	food.setup(_random_world_pos(), randi() % 3)
	add_child(food)
	_foods.append(food)


# =============================================================================
# Pest management
# =============================================================================

func _eat_pest(pest: Pest) -> void:
	pest.eaten = true
	_pests.erase(pest)
	var was_kind := pest.pest_type
	var was_pos  := pest.global_position
	_worm.eat_food(0)
	_worm.chomp_flash()
	pest.queue_free()
	_play_eat()

	if was_kind == 2:
		var cloud := StinkCloud.new()
		cloud.position = was_pos
		add_child(cloud)
		_clouds.append(cloud)

	var cap_kind := was_kind
	get_tree().create_timer(randf_range(2.5, 5.0)).timeout.connect(
		func(): _spawn_pest(cap_kind), CONNECT_ONE_SHOT
	)


func _spawn_pest(kind: int) -> void:
	var pest := Pest.new()
	pest.setup(_random_world_pos(), kind, _worm)
	add_child(pest)
	_pests.append(pest)


# =============================================================================
# Boss
# =============================================================================

func _spawn_boss() -> void:
	_boss = RoboWormBoss.new()
	add_child(_boss)
	var local_arena := Rect2(_worm.head_pos - Vector2(400.0, 300.0), Vector2(800.0, 600.0))
	_boss.setup(local_arena, _worm)
	_boss.boss_defeated.connect(_on_boss_defeated)
	_play_boss_roar()


func _on_boss_defeated() -> void:
	_boss = null
	WormData.unlock_shape(7)
	_play_evolve(5)
	var vp    := get_viewport_rect().size
	var flash := Polygon2D.new()
	flash.polygon = PackedVector2Array([
		Vector2.ZERO, Vector2(vp.x, 0.0), vp, Vector2(0.0, vp.y)
	])
	flash.color = Color(1.0, 0.85, 0.0, 0.0)
	add_child(flash)
	var tw := create_tween()
	tw.tween_property(flash, "color:a", 0.35, 0.18)
	tw.tween_property(flash, "color:a", 0.0,  0.55)
	tw.tween_callback(func(): flash.queue_free())


# =============================================================================
# Worm events
# =============================================================================

func _on_evolved(new_stage: int) -> void:
	_play_evolve(new_stage)
	if new_stage == 2 and not _boss_spawned:
		_boss_spawned = true
		_spawn_boss()


func _on_worm_defeated() -> void:
	_play_hit()
	var respawn_pos := _worm.head_pos
	get_tree().create_timer(0.6).timeout.connect(func():
		_worm.respawn(respawn_pos)
		if is_instance_valid(_camera):
			_camera.global_position = respawn_pos
	, CONNECT_ONE_SHOT)


# =============================================================================
# Sound
# =============================================================================

func _play_eat() -> void:
	_audio.stream = _chirp(330.0, 660.0, 0.08, 0.45)
	_audio.play()


func _play_evolve(stage: int) -> void:
	var base := 330.0 + float(stage) * 55.0
	_audio.stream = _chirp(base, base * 2.2, 0.28, 0.58)
	_audio.play()


func _play_hit() -> void:
	_audio.stream = _chirp(440.0, 180.0, 0.18, 0.55)
	_audio.play()


func _play_boss_roar() -> void:
	_audio.stream = _chirp(110.0, 55.0, 0.45, 0.70)
	_audio.play()


func _play_combo_sound(combo: int) -> void:
	match combo:
		Combos.FIRE_GAS:
			_audio.stream = _chirp(75.0, 300.0, 0.65, 0.95)
		Combos.FIRE_MASS:
			_audio.stream = _chirp(140.0, 70.0,  0.38, 0.80)
		Combos.FIRE_BOUNCE:
			_audio.stream = _chirp(420.0, 840.0, 0.22, 0.70)
		Combos.GAS_MASS:
			_audio.stream = _chirp(210.0, 100.0, 0.48, 0.72)
		Combos.GAS_BOUNCE:
			_audio.stream = _chirp(340.0, 680.0, 0.32, 0.58)
		Combos.MASS_BOUNCE:
			_audio.stream = _chirp(190.0, 380.0, 0.30, 0.68)
		_:
			_audio.stream = _chirp(320.0, 640.0, 0.26, 0.72)
	_audio.play()


static func _chirp(f0: float, f1: float, dur: float, vol: float) -> AudioStreamWAV:
	var sr   := 22050
	var n    := int(sr * dur)
	var w    := AudioStreamWAV.new()
	w.format   = AudioStreamWAV.FORMAT_16_BITS
	w.mix_rate = sr
	var bytes := PackedByteArray(); bytes.resize(n * 2)
	for i in n:
		var r   := float(i) / float(n)
		var env := pow(1.0 - r, 0.25)
		var s   := int(clampf(sin(TAU * lerp(f0, f1, r) * float(i) / float(sr)) * env * vol * 32767.0, -32767.0, 32767.0))
		bytes[i*2]   = s & 0xFF
		bytes[i*2+1] = (s >> 8) & 0xFF
	w.data = bytes; return w


# =============================================================================
# WormData loading
# =============================================================================

func _load_current_kid_data() -> WormData:
	var kid  := 0
	var path := "user://current_kid.txt"
	if FileAccess.file_exists(path):
		var f := FileAccess.open(path, FileAccess.READ)
		if f:
			kid = int(f.get_as_text().strip_edges())
	return WormData.load_or_default(kid)


# =============================================================================
# Helpers
# =============================================================================

func _random_world_pos() -> Vector2:
	var head  := _worm.head_pos if is_instance_valid(_worm) else get_viewport_rect().size / 2.0
	var dist  := randf_range(SPAWN_MIN, SPAWN_MAX)
	var angle := randf() * TAU
	return head + Vector2(cos(angle), sin(angle)) * dist


# =============================================================================
# Arena drawing (speed pads + rolling hazard)
# =============================================================================

func _draw() -> void:
	for pad in _speed_pads:
		_draw_speed_pad(pad["pos"] as Vector2, pad["dir"] as Vector2)
	_draw_rolling_hazard()


func _draw_speed_pad(pos: Vector2, dir: Vector2) -> void:
	var right := dir.rotated(PI * 0.5) * 15.0
	var col   := Color(1.0, 0.92, 0.12, 0.60)
	for i in 3:
		var base := pos + dir * (float(i) - 1.0) * 18.0
		draw_line(base - right, base + dir * 15.0, col, 3.5)
		draw_line(base + right, base + dir * 15.0, col, 3.5)
	draw_arc(pos, SPEED_PAD_R, 0.0, TAU, 18, Color(1.0, 0.92, 0.12, 0.16), SPEED_PAD_R * 2.0, true)


func _draw_rolling_hazard() -> void:
	var pts := PackedVector2Array()
	for i in 10:
		var a := TAU * i / 10.0
		var r := HAZARD_RADIUS + sin(a * 4.0 + _hazard_rot * 0.8) * 4.5
		pts.append(_hazard_pos + Vector2(cos(a) * r, sin(a) * r))
	draw_colored_polygon(pts, Color(0.34, 0.32, 0.38))
	var crack_end := _hazard_pos + Vector2.from_angle(_hazard_rot) * HAZARD_RADIUS * 0.75
	draw_line(_hazard_pos, crack_end, Color(0.18, 0.16, 0.20), 2.5)
	draw_circle(_hazard_pos + Vector2(-HAZARD_RADIUS * 0.3, -HAZARD_RADIUS * 0.38), 5.0,
		Color(0.62, 0.60, 0.66, 0.45))


# =============================================================================
# Behavioral enemy spawns
# =============================================================================

func _spawn_gull() -> void:
	var live_foods: Array = _foods.filter(
		func(f): return is_instance_valid(f) and not f.eaten
	)
	if live_foods.is_empty():
		return
	var target   := live_foods[randi() % live_foods.size()] as Food
	var vp       := get_viewport_rect().size
	var screen_tl := _worm.head_pos - vp * 0.5
	var side     := randi() % 4
	var spawn_pos: Vector2
	var exit_dir : Vector2
	match side:
		0:
			spawn_pos = Vector2(screen_tl.x + randf() * vp.x, screen_tl.y - 80.0)
			exit_dir  = Vector2(randf_range(-0.3, 0.3), -1.0).normalized()
		1:
			spawn_pos = Vector2(screen_tl.x + vp.x + 80.0, screen_tl.y + randf() * vp.y)
			exit_dir  = Vector2(1.0, randf_range(-0.3, 0.3)).normalized()
		2:
			spawn_pos = Vector2(screen_tl.x + randf() * vp.x, screen_tl.y + vp.y + 80.0)
			exit_dir  = Vector2(randf_range(-0.3, 0.3), 1.0).normalized()
		_:
			spawn_pos = Vector2(screen_tl.x - 80.0, screen_tl.y + randf() * vp.y)
			exit_dir  = Vector2(-1.0, randf_range(-0.3, 0.3)).normalized()
	var gull := Gull.new()
	gull.setup(spawn_pos, target, exit_dir)
	add_child(gull)
	_gulls.append(gull)


func _spawn_boulder_bug() -> void:
	var bbug := BoulderBug.new()
	bbug.setup(_random_world_pos(), _worm)
	add_child(bbug)
	_bbugs.append(bbug)


func _spawn_magnet_mite() -> void:
	var mite := MagnetMite.new()
	mite.setup(_random_world_pos())
	add_child(mite)
	_mmites.append(mite)


func _scatter_around(pos: Vector2, radius: float) -> void:
	var rsq := radius * radius
	for food in _foods:
		if not is_instance_valid(food) or food.eaten:
			continue
		var df := food.global_position - pos
		if df.length_squared() < rsq:
			var sdir := df.normalized() if df.length_squared() > 1.0 else Vector2.from_angle(randf() * TAU)
			food.position += sdir * randf_range(60.0, 130.0)
	for pickup in _pickups:
		if not is_instance_valid(pickup) or pickup.eaten:
			continue
		var dp := pickup.global_position - pos
		if dp.length_squared() < rsq:
			var sdir := dp.normalized() if dp.length_squared() > 1.0 else Vector2.from_angle(randf() * TAU)
			pickup.position += sdir * randf_range(80.0, 155.0)
