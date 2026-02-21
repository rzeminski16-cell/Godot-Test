extends Node2D

## Scrolling starfield background for the space atmosphere.

var stars: Array = []
var star_count: int = 80
var screen_size: Vector2


func _ready() -> void:
	screen_size = get_viewport_rect().size
	for i in range(star_count):
		stars.append(_create_star(true))


func _create_star(random_y: bool) -> Dictionary:
	return {
		"x": randf() * screen_size.x,
		"y": randf() * screen_size.y if random_y else -2,
		"speed": randf_range(30, 150),
		"size": randf_range(0.5, 2.5),
		"brightness": randf_range(0.3, 1.0)
	}


func _process(delta: float) -> void:
	for i in range(stars.size()):
		stars[i]["y"] += stars[i]["speed"] * delta
		if stars[i]["y"] > screen_size.y + 5:
			stars[i] = _create_star(false)
	queue_redraw()


func _draw() -> void:
	for star in stars:
		var color = Color(star["brightness"], star["brightness"], star["brightness"])
		draw_circle(Vector2(star["x"], star["y"]), star["size"], color)
