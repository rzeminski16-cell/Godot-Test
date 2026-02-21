extends Node2D

## Decorative 2.5D ship that gently bobs on the title screen.

var time: float = 0.0
var base_y: float = 0.0


func _ready() -> void:
	base_y = position.y


func _process(delta: float) -> void:
	time += delta
	position.y = base_y + sin(time * 1.5) * 8.0
	rotation = sin(time * 0.8) * 0.05
