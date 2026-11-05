class_name GearBackground
extends Control

## Animated heart-gear background ported from the team's HTML mockup.

const BACKGROUND := Color("0b0711")
@export var gear_texture: Texture2D
const SEED := 20250214
const COLUMNS := 6
const ROWS := 5
const SPEED := 2.0
const LAYERS := [
	{"size_min": 0.30, "size_max": 0.48, "alpha_min": 0.040, "alpha_max": 0.065, "spin_min": 140.0, "spin_max": 240.0},
	{"size_min": 0.48, "size_max": 0.68, "alpha_min": 0.075, "alpha_max": 0.115, "spin_min": 90.0, "spin_max": 170.0},
	{"size_min": 0.66, "size_max": 0.88, "alpha_min": 0.130, "alpha_max": 0.190, "spin_min": 55.0, "spin_max": 120.0},
]

class Gear:
	var pos: Vector2
	var size: float
	var opacity: float
	var speed: float
	var angle: float
	var layer: int

var _gears: Array[Gear] = []
var _glow_pink: GradientTexture2D
var _glow_violet: GradientTexture2D


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_glow_pink = _make_glow(Color(1.0, 0.35, 0.49, 0.11))
	_glow_violet = _make_glow(Color(0.47, 0.37, 1.0, 0.08))
	_build_gears()


func _process(delta: float) -> void:
	for gear in _gears:
		gear.angle += gear.speed * delta
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), BACKGROUND)
	draw_texture_rect(_glow_pink, Rect2(Vector2(-size.x * 0.4, -size.y * 0.5), size * 1.5), false)
	draw_texture_rect(_glow_violet, Rect2(size * Vector2(0.1, 0.1), size * 1.2), false)

	if gear_texture == null:
		return

	var min_side := minf(size.x, size.y)
	for gear in _gears:
		var gear_size := gear.size * min_side
		draw_set_transform(gear.pos * size, gear.angle, Vector2.ONE)
		draw_texture_rect(
			gear_texture,
			Rect2(Vector2(-gear_size * 0.5, -gear_size * 0.5), Vector2(gear_size, gear_size)),
			false,
			Color(1, 1, 1, gear.opacity),
		)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _build_gears() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = SEED
	var aspect := 16.0 / 9.0
	var cell_w := aspect / COLUMNS
	var cell_h := 1.0 / ROWS
	var cell_min := minf(cell_w, cell_h)
	var placed: Array[Vector3] = []

	for row in ROWS:
		for col in COLUMNS:
			var roll := rng.randf()
			var layer := 0 if roll < 0.35 else 1 if roll < 0.72 else 2
			var data: Dictionary = LAYERS[layer]
			var gear_size := rng.randf_range(data["size_min"], data["size_max"]) * cell_min
			var opacity := rng.randf_range(data["alpha_min"], data["alpha_max"])
			var duration := rng.randf_range(data["spin_min"], data["spin_max"])
			var direction := 1.0 if rng.randf() < 0.5 else -1.0
			var jitter := Vector2(cell_w, cell_h) * 0.38
			var pos := Vector2.ZERO
			var best := Vector2.ZERO
			var best_clearance := -INF
			var found := false

			for attempt in 16:
				var candidate := Vector2(
					(col + 0.5) * cell_w + rng.randf_range(-jitter.x, jitter.x),
					(row + 0.5) * cell_h + rng.randf_range(-jitter.y, jitter.y),
				)
				if layer == 0:
					pos = candidate
					found = true
					break
				var clearance := INF
				for other in placed:
					clearance = minf(clearance, candidate.distance_to(Vector2(other.x, other.y)) - (gear_size + other.z) * 0.5)
				if clearance > 0.0:
					pos = candidate
					found = true
					break
				if clearance > best_clearance:
					best = candidate
					best_clearance = clearance
			if not found:
				pos = best

			placed.append(Vector3(pos.x, pos.y, gear_size))
			var gear := Gear.new()
			gear.pos = Vector2(pos.x / aspect, pos.y)
			gear.size = gear_size
			gear.opacity = opacity
			gear.speed = TAU / duration * direction * SPEED
			gear.angle = rng.randf_range(0.0, TAU)
			gear.layer = layer
			_gears.append(gear)

	_gears.sort_custom(_sort_by_layer)


func _sort_by_layer(a: Gear, b: Gear) -> bool:
	return a.layer < b.layer


func _make_glow(color: Color) -> GradientTexture2D:
	var gradient := Gradient.new()
	gradient.colors = PackedColorArray([color, Color(color.r, color.g, color.b, 0.0)])
	var texture := GradientTexture2D.new()
	texture.gradient = gradient
	texture.fill = GradientTexture2D.FILL_RADIAL
	texture.fill_from = Vector2(0.5, 0.5)
	texture.fill_to = Vector2(1.0, 1.0)
	texture.width = 256
	texture.height = 256
	return texture
