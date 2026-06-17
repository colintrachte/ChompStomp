class_name WormData
extends RefCounted

const PALETTE: Array[Color] = [
	Color(0.22, 0.47, 1.00),  # 0  blue
	Color(1.00, 0.90, 0.08),  # 1  yellow
	Color(0.62, 0.18, 0.85),  # 2  purple
	Color(0.18, 0.80, 0.22),  # 3  green
	Color(0.92, 0.92, 0.92),  # 4  white
	Color(0.08, 0.08, 0.08),  # 5  black
	Color(0.95, 0.15, 0.15),  # 6  red
	Color(0.50, 0.28, 0.08),  # 7  brown
	Color(0.95, 0.52, 0.72),  # 8  pink
	Color(1.00, 0.55, 0.08),  # 9  orange
	Color(0.52, 0.52, 0.52),  # 10 grey
	Color(0.08, 0.12, 0.55),  # 11 dark-blue
	Color(0.08, 0.68, 0.62),  # 12 teal
	Color(0.90, 0.08, 0.78),  # 13 magenta
]

const MIN_SEGS := 3
const MAX_SEGS := 12
const DEFAULT_SEGS := 6

# segments: Array of {si: int, ci: int}  (shape_idx 0-6, color_idx 0-13)
var segments: Array = []
var face_idx: int    = 4   # default: smile
var body_type_idx: int = 0 # default: speedy

func _init() -> void:
	reset()

func reset() -> void:
	segments.clear()
	for i in range(DEFAULT_SEGS):
		segments.append({"si": 0, "ci": i % PALETTE.size()})
	face_idx = 4
	body_type_idx = 0

func to_dict() -> Dictionary:
	return {"segs": segments.duplicate(true), "fi": face_idx, "bt": body_type_idx}

func from_dict(d: Dictionary) -> void:
	if d.has("segs") and d["segs"] is Array and not (d["segs"] as Array).is_empty():
		segments = (d["segs"] as Array).duplicate(true)
	face_idx      = d.get("fi", 4)
	body_type_idx = d.get("bt", 0)

static func save(kid: int, data: WormData) -> void:
	var f := FileAccess.open("user://worm_%d.json" % kid, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(data.to_dict()))

static func load_or_default(kid: int) -> WormData:
	var data := WormData.new()
	var path  := "user://worm_%d.json" % kid
	if not FileAccess.file_exists(path):
		return data
	var f := FileAccess.open(path, FileAccess.READ)
	if f:
		var parsed = JSON.parse_string(f.get_as_text())
		if parsed is Dictionary:
			data.from_dict(parsed)
	return data

# --- Shape vertex generators ---

static func shape_verts(si: int, half: float) -> PackedVector2Array:
	match si:
		0: return _rect(half, half * 0.72)
		1: return _ellipse(half * 1.25, half * 0.60)
		2: return _ellipse(half, half)
		3: return _diamond(half)
		4: return _poly(5, half)
		5: return _triangle(half)
		6: return _star(half)
		7: return _cog(half)
	return _rect(half, half * 0.72)


# --- Blueprint persistence ---

static func is_shape_unlocked(si: int) -> bool:
	if si < 7:
		return true
	var path := "user://blueprints.json"
	if not FileAccess.file_exists(path):
		return false
	var f := FileAccess.open(path, FileAccess.READ)
	if not f:
		return false
	var d = JSON.parse_string(f.get_as_text())
	if not d is Dictionary:
		return false
	var shapes = (d as Dictionary).get("shapes", [])
	return si in shapes


static func unlock_shape(si: int) -> void:
	var path := "user://blueprints.json"
	var current: Dictionary = {}
	if FileAccess.file_exists(path):
		var f := FileAccess.open(path, FileAccess.READ)
		if f:
			var d = JSON.parse_string(f.get_as_text())
			if d is Dictionary:
				current = d as Dictionary
	var shapes: Array = current.get("shapes", [])
	if si not in shapes:
		shapes.append(si)
		current["shapes"] = shapes
		var fw := FileAccess.open(path, FileAccess.WRITE)
		if fw:
			fw.store_string(JSON.stringify(current))

static func _rect(w: float, h: float) -> PackedVector2Array:
	return PackedVector2Array([Vector2(-w,-h), Vector2(w,-h), Vector2(w,h), Vector2(-w,h)])

static func _ellipse(rx: float, ry: float) -> PackedVector2Array:
	var v := PackedVector2Array()
	for i in 20:
		var a := TAU * i / 20.0
		v.append(Vector2(cos(a) * rx, sin(a) * ry))
	return v

static func _diamond(h: float) -> PackedVector2Array:
	return PackedVector2Array([Vector2(0,-h), Vector2(h*0.65,0), Vector2(0,h), Vector2(-h*0.65,0)])

static func _poly(n: int, r: float) -> PackedVector2Array:
	var v := PackedVector2Array()
	for i in n:
		var a := TAU * i / float(n) - PI * 0.5
		v.append(Vector2(cos(a) * r, sin(a) * r))
	return v

static func _triangle(h: float) -> PackedVector2Array:
	return PackedVector2Array([Vector2(0,-h), Vector2(h*0.82,h*0.65), Vector2(-h*0.82,h*0.65)])

static func _star(h: float) -> PackedVector2Array:
	var v := PackedVector2Array()
	var inner := h * 0.42
	for i in 10:
		var a := TAU * i / 10.0 - PI * 0.5
		var r := h if i % 2 == 0 else inner
		v.append(Vector2(cos(a) * r, sin(a) * r))
	return v


static func _cog(r: float) -> PackedVector2Array:
	var v := PackedVector2Array()
	var teeth := 8
	for i in teeth * 2:
		var a  := TAU * float(i) / float(teeth * 2) - PI * 0.5
		var ri := r if i % 2 == 0 else r * 0.66
		v.append(Vector2(cos(a) * ri, sin(a) * ri))
	return v
