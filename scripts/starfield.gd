extends Node2D

## 2.5D parallax starfield with multiple depth layers and varied star shapes.

var layers: Array = []
var screen_size: Vector2

# Layer configs: [count, min_speed, max_speed, min_size, max_size, min_bright, max_bright]
var layer_configs: Array = [
	[30, 15, 40, 0.5, 1.2, 0.15, 0.3],
	[25, 40, 80, 0.8, 1.8, 0.25, 0.5],
	[20, 80, 140, 1.2, 2.5, 0.4, 0.7],
	[10, 140, 200, 2.0, 3.5, 0.6, 1.0],
]


func _ready() -> void:
	screen_size = get_viewport_rect().size
	for config in layer_configs:
		var layer_stars: Array = []
		for i in range(config[0]):
			layer_stars.append(_create_star(config, true))
		layers.append(layer_stars)


func _create_star(config: Array, random_y: bool) -> Dictionary:
	var shape_type = randi() % 4
	var brightness = randf_range(config[5], config[6])
	var tint_r = brightness + randf_range(-0.05, 0.05)
	var tint_g = brightness + randf_range(-0.03, 0.05)
	var tint_b = brightness + randf_range(0.0, 0.1)
	return {
		"x": randf() * screen_size.x,
		"y": randf() * screen_size.y if random_y else randf_range(-10, -2),
		"speed": randf_range(config[1], config[2]),
		"size": randf_range(config[3], config[4]),
		"color": Color(clampf(tint_r, 0, 1), clampf(tint_g, 0, 1), clampf(tint_b, 0, 1)),
		"shape": shape_type,
		"twinkle_offset": randf() * TAU,
		"twinkle_speed": randf_range(2.0, 5.0),
	}


func _process(delta: float) -> void:
	for layer_idx in range(layers.size()):
		var config = layer_configs[layer_idx]
		for i in range(layers[layer_idx].size()):
			layers[layer_idx][i]["y"] += layers[layer_idx][i]["speed"] * delta
			if layers[layer_idx][i]["y"] > screen_size.y + 10:
				layers[layer_idx][i] = _create_star(config, false)
	queue_redraw()


func _draw() -> void:
	var t = Time.get_ticks_msec() / 1000.0
	for layer in layers:
		for star in layer:
			var twinkle = 0.7 + 0.3 * sin(t * star["twinkle_speed"] + star["twinkle_offset"])
			var color: Color = star["color"]
			color.a = twinkle
			var pos = Vector2(star["x"], star["y"])
			var size: float = star["size"]

			match star["shape"]:
				0:  # Circle with subtle glow
					if size > 1.5:
						var glow = color
						glow.a *= 0.2
						draw_circle(pos, size * 1.8, glow)
					draw_circle(pos, size, color)
				1:  # Diamond shape (Stardew-like)
					var pts = PackedVector2Array([
						pos + Vector2(0, -size),
						pos + Vector2(size * 0.6, 0),
						pos + Vector2(0, size),
						pos + Vector2(-size * 0.6, 0),
					])
					draw_colored_polygon(pts, color)
				2:  # Cross/sparkle shape
					var half = size * 0.3
					var pts = PackedVector2Array([
						pos + Vector2(0, -size),
						pos + Vector2(half, -half),
						pos + Vector2(size, 0),
						pos + Vector2(half, half),
						pos + Vector2(0, size),
						pos + Vector2(-half, half),
						pos + Vector2(-size, 0),
						pos + Vector2(-half, -half),
					])
					draw_colored_polygon(pts, color)
				3:  # Tiny square
					var s = size * 0.7
					draw_colored_polygon(PackedVector2Array([
						pos + Vector2(-s, -s), pos + Vector2(s, -s),
						pos + Vector2(s, s), pos + Vector2(-s, s),
					]), color)
