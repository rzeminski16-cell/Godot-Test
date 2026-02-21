extends Node2D

## Visual explosion effect using animated particles drawn with polygons.

var lifetime: float = 0.5
var time: float = 0.0
var particles: Array = []


func _ready() -> void:
	# Create particle data
	for i in range(8):
		var angle = (i / 8.0) * TAU
		var speed = randf_range(80, 200)
		var size = randf_range(2, 5)
		particles.append({
			"angle": angle,
			"speed": speed,
			"size": size,
			"color": [Color.YELLOW, Color.ORANGE, Color.RED][randi() % 3]
		})


func _process(delta: float) -> void:
	time += delta
	if time >= lifetime:
		queue_free()
		return
	queue_redraw()


func _draw() -> void:
	var progress = time / lifetime
	for p in particles:
		var dist = p["speed"] * time
		var pos = Vector2(cos(p["angle"]), sin(p["angle"])) * dist
		var alpha = 1.0 - progress
		var color: Color = p["color"]
		color.a = alpha
		var size = p["size"] * (1.0 - progress * 0.5)
		draw_circle(pos, size, color)
