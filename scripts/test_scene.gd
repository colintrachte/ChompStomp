extends Node2D

const FOOD_TARGET  := 10
const PEST_COUNTS  := [[0, 5], [1, 2], [2, 2]]   # Crumb×5, Hopper×2, StinkBeetle×2
const SPAWN_MIN    := 500.0
const SPAWN_MAX    := 850.0
const DESPAWN_DIST := 1200.0

var _worm  : Worm
var _foods : Array[Food] = []
var _pests : Array[Pest] = []
var _clouds: Array[StinkCloud] = []
var _boss  : RoboWormBoss = null
var _audio : AudioStreamPlayer
var _boss_spawned := false
var _stream_timer := 0.0


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

	var cam := Camera2D.new()
	_worm.attach_camera(cam)

	for _i in FOOD_TARGET:
		_spawn_food()

	for pair in PEST_COUNTS:
		for _j in (pair[1] as int):
			_spawn_pest(pair[0] as int)


func _process(delta: float) -> void:
	if not _worm.is_alive:
		return
	_stream_timer += delta
	if _stream_timer >= 2.0:
		_stream_timer = 0.0
		_stream_world()


func _physics_process(_delta: float) -> void:
	if not _worm.is_alive:
		return

	var head := _worm.head_pos
	var hr   := _worm.head_radius

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
			_play_eat()

		if _boss.is_charging:
			var charge_sq := pow(hr + _boss.head_half, 2.0)
			if (head - _boss.head_pos).length_squared() < charge_sq:
				_worm.take_hit()
				_play_hit()

	# --- Stink clouds hit worm ---
	var cloud_sq := StinkCloud.RADIUS * StinkCloud.RADIUS
	for cloud in _clouds.duplicate():
		if not is_instance_valid(cloud):
			_clouds.erase(cloud)
			continue
		if (head - cloud.global_position).length_squared() < cloud_sq:
			_worm.sneeze()


# =============================================================================
# Streaming: despawn distant items, replenish near worm
# =============================================================================

func _stream_world() -> void:
	var head       := _worm.head_pos
	var despawn_sq := DESPAWN_DIST * DESPAWN_DIST

	for food in _foods.duplicate():
		if not is_instance_valid(food):
			_foods.erase(food)
			continue
		if (head - food.global_position).length_squared() > despawn_sq:
			_foods.erase(food)
			food.queue_free()

	for pest in _pests.duplicate():
		if not is_instance_valid(pest):
			_pests.erase(pest)
			continue
		if (head - pest.global_position).length_squared() > despawn_sq:
			_pests.erase(pest)
			pest.queue_free()

	while _foods.size() < FOOD_TARGET:
		_spawn_food()

	var pest_target := 0
	for pair in PEST_COUNTS:
		pest_target += (pair[1] as int)
	while _pests.size() < pest_target:
		_spawn_pest(randi() % 3)


# =============================================================================
# Food management
# =============================================================================

func _eat_food(food: Food) -> void:
	food.eaten = true
	_foods.erase(food)
	_worm.eat_food(food.food_type)
	food.queue_free()
	_play_eat()
	call_deferred("_spawn_food")


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
		_worm.respawn(respawn_pos), CONNECT_ONE_SHOT
	)


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
