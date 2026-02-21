extends Node2D

## 2.5D explosion effect with layered debris, sparks, and a shockwave ring.

var lifetime: float = 0.6
var time: float = 0.0
var particles: Array = []
var sparks: Array = []
var ring_radius: float = 0.0
var ring_max: float = 40.0


func _ready() -> void:
	# Debris chunks with 2.5D depth
	for i in range(10):
		var angle = (i / 10.0) * TAU + randf_range(-0.3, 0.3)
		particles.append({
			"angle": angle,
			"speed": randf_range(60, 180),
			"size": randf_range(3, 7),
			"rotation": randf() * TAU,
			"rot_speed": randf_range(-5, 5),
			"top_color": [Color(1, 0.85, 0.2), Color(1, 0.55, 0.1), Color(0.9, 0.25, 0.1)][randi() % 3],
			"side_color": [Color(0.7, 0.5, 0.1), Color(0.6, 0.3, 0.05), Color(0.5, 0.12, 0.05)][randi() % 3],
		})

	# Small bright sparks
	for i in range(12):
		var angle = randf() * TAU
		sparks.append({
			"angle": angle,
			"speed": randf_range(100, 280),
			"length": randf_range(3, 8),
			"color": [Color(1, 1, 0.6), Color(1, 0.8, 0.3), Color(1, 1, 1)][randi() % 3],
		})


func _process(delta: float) -> void:
	time += delta
	if time >= lifetime:
		queue_free()
		return
	ring_radius = (time / lifetime) * ring_max
	queue_redraw()


func _draw() -> void:
	var progress = time / lifetime

	# Shadow underneath
	var shadow_alpha = (1.0 - progress) * 0.2
	draw_circle(Vector2(3, 5), 15 * (1.0 - progress * 0.5), Color(0, 0, 0, shadow_alpha))

	# Shockwave ring
	if progress < 0.7:
		var ring_alpha = (1.0 - progress / 0.7) * 0.4
		var ring_color = Color(1, 0.7, 0.2, ring_alpha)
		_draw_ring(Vector2.ZERO, ring_radius, 1.5, ring_color)

	# Debris chunks with 2.5D faces
	for p in particles:
		var dist = p["speed"] * time
		var pos = Vector2(cos(p["angle"]), sin(p["angle"])) * dist
		var alpha = 1.0 - progress
		var size = p["size"] * (1.0 - progress * 0.4)
		var rot = p["rotation"] + p["rot_speed"] * time

		# Shadow
		var shadow_pos = pos + Vector2(2, 3)
		draw_circle(shadow_pos, size * 0.8, Color(0, 0, 0, alpha * 0.15))

		# Side face (darker, offset down)
		var side_col: Color = p["side_color"]
		side_col.a = alpha
		var side_offset = Vector2(0, size * 0.4)
		_draw_rotated_rect(pos + side_offset, size, size * 0.6, rot, side_col)

		# Top face (brighter)
		var top_col: Color = p["top_color"]
		top_col.a = alpha
		_draw_rotated_rect(pos, size, size * 0.7, rot, top_col)

	# Bright sparks (streak lines)
	for s in sparks:
		var dist = s["speed"] * time
		var dir = Vector2(cos(s["angle"]), sin(s["angle"]))
		var pos = dir * dist
		var tail = dir * max(0, dist - s["length"] * (1.0 - progress))
		var alpha = (1.0 - progress) * (1.0 if progress < 0.5 else (1.0 - (progress - 0.5) * 2.0))
		var col: Color = s["color"]
		col.a = max(0, alpha)
		draw_line(tail, pos, col, 1.5)

	# Central flash
	if progress < 0.3:
		var flash_alpha = (1.0 - progress / 0.3) * 0.8
		draw_circle(Vector2.ZERO, 8 * (1.0 - progress), Color(1, 1, 0.9, flash_alpha))
		draw_circle(Vector2.ZERO, 4 * (1.0 - progress), Color(1, 1, 1, flash_alpha))


func _draw_rotated_rect(center: Vector2, w: float, h: float, angle: float, color: Color) -> void:
	var points: PackedVector2Array = PackedVector2Array()
	var cos_a = cos(angle)
	var sin_a = sin(angle)
	for corner in [Vector2(-w, -h), Vector2(w, -h), Vector2(w, h), Vector2(-w, h)]:
		var rotated = Vector2(
			corner.x * cos_a - corner.y * sin_a,
			corner.x * sin_a + corner.y * cos_a
		)
		points.append(center + rotated * 0.5)
	draw_colored_polygon(points, color)


func _draw_ring(center: Vector2, radius: float, width: float, color: Color) -> void:
	var segments = 24
	for i in range(segments):
		var a1 = (i / float(segments)) * TAU
		var a2 = ((i + 1) / float(segments)) * TAU
		var p1_outer = center + Vector2(cos(a1), sin(a1)) * (radius + width)
		var p2_outer = center + Vector2(cos(a2), sin(a2)) * (radius + width)
		var p1_inner = center + Vector2(cos(a1), sin(a1)) * max(0, radius - width)
		var p2_inner = center + Vector2(cos(a2), sin(a2)) * max(0, radius - width)
		draw_colored_polygon(PackedVector2Array([p1_outer, p2_outer, p2_inner, p1_inner]), color)
