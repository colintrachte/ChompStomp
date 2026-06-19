extends Node2D

# =============================================================================
# Inner class — body type icon silhouette
# =============================================================================
class _BodyIcon extends Node2D:
	var body_idx := 0
	var selected := false
	var sz       := 48.0

	func refresh(idx: int, sel: bool, size: float) -> void:
		body_idx = idx; selected = sel; sz = size; queue_redraw()

	func _draw() -> void:
		if selected:
			draw_rect(Rect2(-sz*0.58,-sz*0.58, sz*1.16, sz*1.16), Color.WHITE, false, 3.5)
		match body_idx:
			0: _speedy()
			1: _heavy()
			2: _spiky()
			3: _robot()

	func _speedy() -> void:
		var pts := PackedVector2Array()
		for i in 20:
			var a := TAU * i / 20.0
			pts.append(Vector2(cos(a)*sz*0.44, sin(a)*sz*0.22))
		draw_colored_polygon(pts, Color(0.22, 0.68, 1.00))
		for i in 3:
			var y := (i - 1.0) * sz * 0.14
			draw_line(Vector2(-sz*0.56, y), Vector2(-sz*0.38, y), Color(1,1,1,0.80), 2.5, true)

	func _heavy() -> void:
		draw_rect(Rect2(-sz*0.42,-sz*0.40, sz*0.84, sz*0.80), Color(0.58, 0.38, 0.18))
		draw_rect(Rect2(-sz*0.42,-sz*0.40, sz*0.84, sz*0.80), Color(0,0,0,0.28), false, 2.5)

	func _spiky() -> void:
		draw_rect(Rect2(-sz*0.40,-sz*0.14, sz*0.80, sz*0.50), Color(0.90, 0.48, 0.12))
		for i in 5:
			var bx: float = lerp(-sz*0.30, sz*0.30, float(i) / 4.0)
			draw_colored_polygon(PackedVector2Array([
				Vector2(bx - sz*0.10, -sz*0.14),
				Vector2(bx, -sz*0.46),
				Vector2(bx + sz*0.10, -sz*0.14),
			]), Color(0.95, 0.78, 0.10))

	func _robot() -> void:
		draw_rect(Rect2(-sz*0.40,-sz*0.36, sz*0.80, sz*0.72), Color(0.50, 0.52, 0.58))
		draw_circle(Vector2(-sz*0.18,-sz*0.08), sz*0.11, Color(0.18, 0.85, 1.00))
		draw_circle(Vector2( sz*0.18,-sz*0.08), sz*0.11, Color(0.18, 0.85, 1.00))
		draw_line(Vector2(-sz*0.40, sz*0.10), Vector2(sz*0.40, sz*0.10), Color(0,0,0,0.35), 2.5)
		draw_circle(Vector2(-sz*0.30, sz*0.27), sz*0.08, Color(0.75, 0.75, 0.82))
		draw_circle(Vector2( sz*0.30, sz*0.27), sz*0.08, Color(0.75, 0.75, 0.82))


# =============================================================================
# Inner class — section label overlay (draws on top of all Polygon2D children)
# =============================================================================
class _LabelLayer extends Node2D:
	var _vp := Vector2.ZERO
	var _lx := 0.0
	var _rx := 0.0

	func _draw() -> void:
		var font  := ThemeDB.fallback_font
		var fs    := int(_vp.y * 0.022)
		var muted := Color(0.55, 0.65, 0.52, 0.72)
		var pw    := _vp.x - _rx

		draw_string(font, Vector2(0.0,  _vp.y * 0.098), "SHAPE",
			HORIZONTAL_ALIGNMENT_CENTER, _lx, fs, muted)
		draw_string(font, Vector2(_rx,  _vp.y * 0.040), "FACE",
			HORIZONTAL_ALIGNMENT_CENTER, pw, fs, muted)
		draw_string(font, Vector2(_rx,  _vp.y * 0.558), "COLOR",
			HORIZONTAL_ALIGNMENT_CENTER, pw, fs, muted)
		draw_string(font, Vector2(_lx,  _vp.y * 0.808), "BODY",
			HORIZONTAL_ALIGNMENT_CENTER, _rx - _lx, fs, muted)
		draw_string(font, Vector2(_lx,  _vp.y * 0.870), "PLAY",
			HORIZONTAL_ALIGNMENT_CENTER, _rx - _lx, int(_vp.y * 0.030),
			Color(0.38, 0.92, 0.52, 0.85))


# =============================================================================
# Main builder
# =============================================================================

# --- Layout (computed at _ready from viewport) ---
var _vp     := Vector2.ZERO   # full viewport
var _lx     := 0.0            # left panel right edge
var _rx     := 0.0            # right panel left edge
var _cx     := 0.0            # worm horizontal center
var _worm_y := 0.0            # worm vertical center
var _bsz    := 48.0           # body icon size

# --- State ---
var _data   : Array[WormData] = []
var _kid    := 0
var _sel_seg := 0

# --- Worm preview nodes ---
var _seg_layer  : Node2D
var _seg_polys  : Array[Polygon2D] = []
var _sel_ring   : Polygon2D
var _face_node  : FaceNode

# --- Highlight nodes needing refresh ---
var _shape_rings : Array[Polygon2D] = []
var _swatch_rects: Array[Polygon2D] = []
var _face_rings  : Array[Polygon2D] = []
var _body_icons  : Array[_BodyIcon] = []
var _kid_rings   : Array[Polygon2D] = []

# --- Input hit areas ---
var _hits: Array = []   # [{r: Rect2, fn: Callable}]

# --- Animation ---
var _time    := 0.0
var _bounces : Array[float] = []

# --- Sound ---
var _audio  : AudioStreamPlayer
var _sounds : Dictionary = {}


# =============================================================================
# Lifecycle
# =============================================================================

func _ready() -> void:
	_vp     = get_viewport_rect().size
	_lx     = _vp.x * 0.148          # ~190 @ 1280
	_rx     = _vp.x * 0.727          # ~930 @ 1280
	_cx     = (_lx + _rx) * 0.5
	_worm_y = _vp.y * 0.44
	_bsz    = _vp.x * 0.040

	_data = [WormData.load_or_default(0), WormData.load_or_default(1)]
	_sel_seg = 0

	_setup_sounds()

	_build_panels()
	_build_left()
	_build_center()
	_build_right()
	_build_labels()
	_build_back_btn()

	_seg_layer = Node2D.new()
	add_child(_seg_layer)

	_rebuild_worm()


func _process(delta: float) -> void:
	_time += delta

	if is_instance_valid(_sel_ring):
		_sel_ring.color.a = 0.62 + sin(_time * 7.0) * 0.32

	var count := _data[_kid].segments.size()
	for i in count:
		if i >= _seg_polys.size():
			continue
		var base  := _seg_world_pos(i)
		var wig   := sin(_time * 2.8 + i * 0.85) * _seg_display_half() * 0.15
		var bnc   := 0.0
		if i < _bounces.size() and _bounces[i] > 0.001:
			_bounces[i] = maxf(0.0, _bounces[i] - delta * 4.5)
			bnc = sin(_bounces[i] * PI) * _seg_display_half() * 0.28
		_seg_polys[i].position = base + Vector2(0.0, wig - bnc)


func _input(event: InputEvent) -> void:
	var pos     := Vector2.ZERO
	var pressed := false
	if event is InputEventScreenTouch and event.pressed:
		pos = event.position; pressed = true
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		pos = event.position; pressed = true
	if not pressed:
		return

	if _check_worm_tap(pos):
		return
	for hit in _hits:
		if (hit.r as Rect2).has_point(pos):
			(hit.fn as Callable).call()
			return


# =============================================================================
# Layout builders
# =============================================================================

func _build_panels() -> void:
	_add_bg(Rect2(0, 0, _lx, _vp.y),              Color(0.11, 0.13, 0.11))
	_add_bg(Rect2(_lx, 0, _rx - _lx, _vp.y),      Color(0.08, 0.10, 0.08))
	_add_bg(Rect2(_rx, 0, _vp.x - _rx, _vp.y),    Color(0.11, 0.13, 0.11))
	_add_bg(Rect2(_lx - 1, 0, 2, _vp.y),           Color(0.30, 0.42, 0.28, 0.55))
	_add_bg(Rect2(_rx - 1, 0, 2, _vp.y),           Color(0.30, 0.42, 0.28, 0.55))


func _build_left() -> void:
	var pcx   := _lx * 0.5
	var rows  := 8
	var gap   := (_vp.y * 0.78) / float(rows)
	var half  := minf(gap * 0.38, 28.0)
	var y0    := _vp.y * 0.13

	for si in rows:
		var cy      := y0 + si * gap
		var unlocked := WormData.is_shape_unlocked(si)
		var icon := Polygon2D.new()
		icon.polygon = WormData.shape_verts(si, half)
		icon.position = Vector2(pcx, cy)
		icon.color    = Color(0.58, 0.65, 0.56) if unlocked else Color(0.28, 0.30, 0.28)
		add_child(icon)

		var ring := Polygon2D.new()
		ring.polygon  = WormData.shape_verts(si, half * 1.35)
		ring.position = Vector2(pcx, cy)
		ring.color    = Color(1.0, 0.92, 0.0, 0.0)
		add_child(ring)
		_shape_rings.append(ring)

		# Padlock indicator on locked shapes
		if not unlocked:
			var lock := Polygon2D.new()
			lock.polygon  = WormData.shape_verts(4, half * 0.36)  # small pentagon badge
			lock.position = Vector2(pcx + half * 0.72, cy - half * 0.72)
			lock.color    = Color(0.85, 0.72, 0.12)
			add_child(lock)

		var hit_r  := Rect2(0, cy - gap * 0.5, _lx, gap)
		var si_cap := si
		_add_hit(hit_r, func(): _on_shape(si_cap))

	# + and − buttons
	var btn_y := _vp.y * 0.90
	var btn_h := gap * 0.36
	_draw_plus(Vector2(pcx * 0.55, btn_y), btn_h, Color(0.25, 0.82, 0.28))
	_draw_minus(Vector2(pcx * 1.45, btn_y), btn_h, Color(0.82, 0.25, 0.25))
	_add_hit(Rect2(0, btn_y - btn_h, _lx * 0.5, btn_h * 2.0), func(): _on_add())
	_add_hit(Rect2(_lx * 0.5, btn_y - btn_h, _lx * 0.5, btn_h * 2.0), func(): _on_rem())


func _build_center() -> void:
	# Kid avatar circles
	var av_r  := minf(_vp.x * 0.033, 38.0)
	var av_y  := _vp.y * 0.075
	var av_dx := (_rx - _lx) * 0.20
	var kid_positions := [Vector2(_cx - av_dx, av_y), Vector2(_cx + av_dx, av_y)]

	for ki in 2:
		var head_color := WormData.PALETTE[_data[ki].segments[0]["ci"] as int]
		var av := _make_circle(kid_positions[ki], av_r, head_color)
		add_child(av)

		var ring := _make_circle(kid_positions[ki], av_r * 1.28, Color.WHITE if ki == _kid else Color(1,1,1,0.0))
		ring.color.a = 1.0 if ki == _kid else 0.0
		add_child(ring)
		_kid_rings.append(ring)
		ring.z_index = -1

		var ki_cap := ki
		_add_hit(Rect2(kid_positions[ki] - Vector2(av_r*1.5, av_r*1.5), Vector2(av_r*3.0, av_r*3.0)),
				func(): _on_kid(ki_cap))

	# Body type icons
	var body_y := _vp.y * 0.85
	var body_gap := (_rx - _lx) * 0.22
	var body_x0  := _cx - body_gap * 1.5
	for bi in 4:
		var icon := _BodyIcon.new()
		icon.position = Vector2(body_x0 + bi * body_gap, body_y)
		icon.refresh(bi, bi == _data[_kid].body_type_idx, _bsz)
		add_child(icon)
		_body_icons.append(icon)

		var bi_cap := bi
		_add_hit(Rect2(icon.position - Vector2(_bsz, _bsz), Vector2(_bsz*2.0, _bsz*2.0)),
				func(): _on_body(bi_cap))

	# Play button — circle background + centered triangle
	var play_pos := Vector2(_cx, _vp.y * 0.924)
	var btn_r    := minf(_vp.y * 0.068, 58.0)

	var glow := _make_circle(play_pos, btn_r * 1.30, Color(0.10, 0.62, 0.22, 0.22))
	add_child(glow)
	var btn_bg := _make_circle(play_pos, btn_r, Color(0.14, 0.65, 0.25))
	add_child(btn_bg)

	var tri_h    := btn_r * 0.56
	var play_tri := Polygon2D.new()
	play_tri.polygon = PackedVector2Array([
		Vector2(-tri_h * 0.75, -tri_h),
		Vector2( tri_h * 1.00,  0.0),
		Vector2(-tri_h * 0.75,  tri_h),
	])
	play_tri.position = play_pos + Vector2(tri_h * 0.12, 0.0)
	play_tri.color    = Color.WHITE
	add_child(play_tri)
	_add_hit(Rect2(play_pos.x - btn_r * 1.3, play_pos.y - btn_r * 1.3, btn_r * 2.6, btn_r * 2.6),
			func(): _on_play())


func _build_right() -> void:
	var pcx  := (_rx + _vp.x) * 0.5
	var pw   := _vp.x - _rx

	# Face icons: 6 stacked in top half of right panel
	var face_rows := 6
	var fgap      := (_vp.y * 0.52) / float(face_rows)
	var fhalf     := minf(fgap * 0.36, 26.0)
	var fy0       := _vp.y * 0.06

	for fi in face_rows:
		var cy := fy0 + fi * fgap

		# Face background circle
		var bg_circ := _make_circle(Vector2(pcx, cy), fhalf * 1.15, Color(0.22, 0.28, 0.22))
		add_child(bg_circ)

		var face := FaceNode.new()
		face.set_face(fi, fhalf)
		face.position = Vector2(pcx, cy)
		add_child(face)

		var ring := _make_circle(Vector2(pcx, cy), fhalf * 1.42, Color(1.0, 0.92, 0.0, 0.0))
		add_child(ring)
		_face_rings.append(ring)
		ring.z_index = -1

		var fi_cap := fi
		_add_hit(Rect2(_rx, cy - fgap*0.5, pw, fgap), func(): _on_face(fi_cap))

	# Color palette: 14 swatches in 2 columns below faces
	var sw_size  := minf(pw * 0.42, 44.0)
	var sw_gap   := sw_size * 1.12
	var palette_y0 := _vp.y * 0.56
	var col0_x     := _rx + pw * 0.28
	var col1_x     := _rx + pw * 0.68

	for ci in 14:
		var col := 0 if ci < 7 else 1
		var row := ci if ci < 7 else ci - 7
		var sx  := col0_x if col == 0 else col1_x
		var sy  := palette_y0 + row * sw_gap

		var sw := _make_circle(Vector2(sx, sy), sw_size * 0.46, WormData.PALETTE[ci])
		add_child(sw)

		var ring := _make_circle(Vector2(sx, sy), sw_size * 0.58, Color(1.0, 1.0, 1.0, 0.0))
		add_child(ring)
		_swatch_rects.append(ring)
		ring.z_index = -1

		var ci_cap := ci
		var hit_sz := sw_size * 0.62
		_add_hit(Rect2(sx - hit_sz, sy - hit_sz, hit_sz*2.0, hit_sz*2.0),
				func(): _on_color(ci_cap))


# =============================================================================
# Worm preview
# =============================================================================

func _rebuild_worm() -> void:
	for c in _seg_layer.get_children():
		_seg_layer.remove_child(c)
		c.queue_free()
	_seg_polys.clear()
	_face_node = null

	var segs  := _data[_kid].segments
	var h     := _seg_display_half()
	_bounces.resize(segs.size())
	_bounces.fill(0.0)

	_sel_ring = Polygon2D.new()
	_sel_ring.color   = Color(1.0, 0.92, 0.0, 0.75)
	_sel_ring.z_index = -1
	_seg_layer.add_child(_sel_ring)

	for i in segs.size():
		var poly := Polygon2D.new()
		poly.polygon  = WormData.shape_verts(segs[i]["si"], h)
		poly.color    = WormData.PALETTE[segs[i]["ci"] as int]
		poly.z_index  = 0
		_seg_layer.add_child(poly)
		_seg_polys.append(poly)

		if i == 0:
			_face_node = FaceNode.new()
			_face_node.set_face(_data[_kid].face_idx, h)
			poly.add_child(_face_node)

	_sel_seg = clampi(_sel_seg, 0, segs.size() - 1)
	_sync_seg_positions()
	_refresh_sel_ring()
	_refresh_highlights()


func _seg_display_half() -> float:
	var count  := _data[_kid].segments.size()
	var avail  := (_rx - _lx) * 0.88
	return clampf(avail / (float(count) * 2.15), 20.0, 56.0)


func _seg_world_pos(i: int) -> Vector2:
	var count    := _data[_kid].segments.size()
	var h        := _seg_display_half()
	var spacing  := h * 2.15
	var total_w  := spacing * float(count - 1)
	var x        := _cx - total_w * 0.5 + float(i) * spacing
	var y        := _worm_y + sin(float(i) * 0.62) * h * 0.55   # gentle S-curve
	return Vector2(x, y)


func _sync_seg_positions() -> void:
	var count := _seg_polys.size()
	for i in count:
		_seg_polys[i].position = _seg_world_pos(i)
		# Rotate each segment to face the next one (matches in-game orientation)
		if i < count - 1:
			var dir := _seg_world_pos(i + 1) - _seg_world_pos(i)
			_seg_polys[i].rotation = dir.angle()
		elif count > 1:
			_seg_polys[i].rotation = _seg_polys[i - 1].rotation


func _refresh_sel_ring() -> void:
	if not is_instance_valid(_sel_ring) or _sel_seg >= _data[_kid].segments.size():
		return
	var h  := _seg_display_half()
	var si := _data[_kid].segments[_sel_seg]["si"] as int
	_sel_ring.polygon  = WormData.shape_verts(si, h * 1.28)
	_sel_ring.position = _seg_world_pos(_sel_seg)


# =============================================================================
# Highlight refreshes
# =============================================================================

func _refresh_highlights() -> void:
	if _data[_kid].segments.is_empty():
		return
	var seg: Dictionary = _data[_kid].segments[_sel_seg]
	var si  := seg["si"] as int
	var ci  := seg["ci"] as int
	var fi  := _data[_kid].face_idx
	var bi  := _data[_kid].body_type_idx

	for i in _shape_rings.size():
		_shape_rings[i].color.a = 0.90 if i == si else 0.0
	for i in _swatch_rects.size():
		_swatch_rects[i].color.a = 0.95 if i == ci else 0.0
	for i in _face_rings.size():
		_face_rings[i].color.a = 0.90 if i == fi else 0.0
	for i in _body_icons.size():
		_body_icons[i].refresh(i, i == bi, _bsz)
	for i in _kid_rings.size():
		_kid_rings[i].color.a = 1.0 if i == _kid else 0.0


# =============================================================================
# Actions
# =============================================================================

func _check_worm_tap(pos: Vector2) -> bool:
	var h := _seg_display_half() * 1.15
	for i in _seg_polys.size():
		if (pos - _seg_polys[i].position).length_squared() <= h * h:
			_on_seg(i)
			return true
	return false


func _on_seg(i: int) -> void:
	_sel_seg = i
	if i < _bounces.size():
		_bounces[i] = 1.0
	_refresh_sel_ring()
	_refresh_highlights()
	_play("select")


func _on_color(ci: int) -> void:
	_data[_kid].segments[_sel_seg]["ci"] = ci
	_seg_polys[_sel_seg].color = WormData.PALETTE[ci]
	_refresh_highlights()
	_auto_save()
	_play("color")


func _on_shape(si: int) -> void:
	if not WormData.is_shape_unlocked(si):
		_play("locked")
		return
	_data[_kid].segments[_sel_seg]["si"] = si
	var h := _seg_display_half()
	_seg_polys[_sel_seg].polygon = WormData.shape_verts(si, h)
	_refresh_sel_ring()
	_refresh_highlights()
	_auto_save()
	_play("shape")


func _on_face(fi: int) -> void:
	_data[_kid].face_idx = fi
	if is_instance_valid(_face_node):
		_face_node.set_face(fi, _seg_display_half())
	_refresh_highlights()
	_auto_save()
	_play("face")


func _on_body(bi: int) -> void:
	_data[_kid].body_type_idx = bi
	_refresh_highlights()
	_auto_save()
	_play("body")


func _on_add() -> void:
	if _data[_kid].segments.size() >= WormData.MAX_SEGS:
		return
	var last_ci := (_data[_kid].segments[-1]["ci"] as int + 1) % WormData.PALETTE.size()
	_data[_kid].segments.append({"si": 0, "ci": last_ci})
	_auto_save()
	_play("add")
	_rebuild_worm()


func _on_rem() -> void:
	if _data[_kid].segments.size() <= WormData.MIN_SEGS:
		return
	_data[_kid].segments.pop_back()
	_sel_seg = clampi(_sel_seg, 0, _data[_kid].segments.size() - 1)
	_auto_save()
	_play("rem")
	_rebuild_worm()


func _on_kid(ki: int) -> void:
	if ki == _kid:
		return
	_auto_save()
	_kid = ki
	_sel_seg = 0
	_rebuild_worm()
	_refresh_highlights()
	_play("select")


func _on_play() -> void:
	_auto_save()
	var f := FileAccess.open("user://current_kid.txt", FileAccess.WRITE)
	if f:
		f.store_string(str(_kid))
	get_tree().change_scene_to_file("res://scenes/test_worm.tscn")


func _build_labels() -> void:
	var layer := _LabelLayer.new()
	layer._vp = _vp
	layer._lx = _lx
	layer._rx = _rx
	add_child(layer)


func _build_back_btn() -> void:
	var sz := minf(_vp.x * 0.028, 32.0)
	var px := _lx * 0.18
	var py := _vp.y * 0.028
	var arrow := Polygon2D.new()
	arrow.polygon = PackedVector2Array([
		Vector2(sz * 1.1, 0.0),
		Vector2(0.0, sz * 0.6),
		Vector2(sz * 1.1, sz * 1.2),
		Vector2(sz * 1.1, sz * 0.88),
		Vector2(sz * 0.42, sz * 0.6),
		Vector2(sz * 1.1, sz * 0.32),
	])
	arrow.position = Vector2(px, py)
	arrow.color    = Color(0.50, 0.60, 0.48, 0.80)
	add_child(arrow)
	# push_front so this hit is checked before shape panel hits in _input
	_hits.push_front({"r": Rect2(0, 0, _lx, _vp.y * 0.10), "fn": func(): _on_back()})


func _on_back() -> void:
	_auto_save()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _auto_save() -> void:
	WormData.save(_kid, _data[_kid])


# =============================================================================
# Sound
# =============================================================================

func _setup_sounds() -> void:
	_audio = AudioStreamPlayer.new()
	_audio.volume_db = -5.0
	add_child(_audio)
	_sounds = {
		"select": _wav(660.0, 0.06, 0.40, 0.40),
		"color":  _wav(523.0, 0.09, 0.40, 0.35),
		"shape":  _wav(440.0, 0.09, 0.40, 0.35),
		"face":   _wav(392.0, 0.09, 0.40, 0.35),
		"body":   _wav(330.0, 0.09, 0.40, 0.35),
		"add":    _chirp(370.0, 620.0, 0.13, 0.42),
		"rem":    _chirp(620.0, 310.0, 0.13, 0.42),
		"locked": _wav(180.0, 0.14, 0.28, 1.20),
	}

func _play(key: String) -> void:
	if _audio and _sounds.has(key):
		_audio.stream = _sounds[key]
		_audio.play()

static func _wav(freq: float, dur: float, vol: float, dexp: float) -> AudioStreamWAV:
	var sr := 22050
	var n  := int(sr * dur)
	var w  := AudioStreamWAV.new()
	w.format    = AudioStreamWAV.FORMAT_16_BITS
	w.mix_rate  = sr
	var data := PackedByteArray(); data.resize(n * 2)
	for i in n:
		var env := pow(1.0 - float(i) / float(n), dexp)
		var s   := int(clampf(sin(TAU * freq * float(i) / float(sr)) * env * vol * 32767.0, -32767.0, 32767.0))
		data[i*2]   = s & 0xFF
		data[i*2+1] = (s >> 8) & 0xFF
	w.data = data; return w

static func _chirp(f0: float, f1: float, dur: float, vol: float) -> AudioStreamWAV:
	var sr := 22050
	var n  := int(sr * dur)
	var w  := AudioStreamWAV.new()
	w.format   = AudioStreamWAV.FORMAT_16_BITS
	w.mix_rate = sr
	var data := PackedByteArray(); data.resize(n * 2)
	for i in n:
		var r   := float(i) / float(n)
		var env := pow(1.0 - r, 0.25)
		var s   := int(clampf(sin(TAU * lerp(f0, f1, r) * float(i) / float(sr)) * env * vol * 32767.0, -32767.0, 32767.0))
		data[i*2]   = s & 0xFF
		data[i*2+1] = (s >> 8) & 0xFF
	w.data = data; return w


# =============================================================================
# Drawing helpers
# =============================================================================

func _add_bg(r: Rect2, c: Color) -> void:
	var p := Polygon2D.new()
	p.polygon = PackedVector2Array([r.position, Vector2(r.end.x, r.position.y), r.end, Vector2(r.position.x, r.end.y)])
	p.color   = c
	add_child(p)

func _make_circle(pos: Vector2, r: float, color: Color) -> Polygon2D:
	var p := Polygon2D.new()
	var v := PackedVector2Array()
	for i in 20:
		var a := TAU * i / 20.0
		v.append(Vector2(cos(a) * r, sin(a) * r))
	p.polygon  = v
	p.position = pos
	p.color    = color
	return p

func _add_hit(r: Rect2, fn: Callable) -> void:
	_hits.append({"r": r, "fn": fn})

func _draw_plus(pos: Vector2, sz: float, c: Color) -> void:
	_add_bar(pos, Vector2(sz * 1.0, sz * 0.28), c)
	_add_bar(pos, Vector2(sz * 0.28, sz * 1.0), c)

func _draw_minus(pos: Vector2, sz: float, c: Color) -> void:
	_add_bar(pos, Vector2(sz * 1.0, sz * 0.28), c)

func _add_bar(pos: Vector2, size: Vector2, c: Color) -> void:
	var hw := size.x * 0.5; var hh := size.y * 0.5
	var p  := Polygon2D.new()
	p.polygon  = PackedVector2Array([Vector2(-hw,-hh), Vector2(hw,-hh), Vector2(hw,hh), Vector2(-hw,hh)])
	p.position = pos
	p.color    = c
	add_child(p)
