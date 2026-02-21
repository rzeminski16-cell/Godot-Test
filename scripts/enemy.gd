extends Area2D

## Enemy ship that moves downward. Awards points when destroyed.

@export var speed: float = 150.0
@export var points: int = 100
@export var health: int = 1

var direction := Vector2.DOWN
var wave_amplitude: float = 0.0
var wave_speed: float = 3.0
var time_alive: float = 0.0

const EXPLOSION_SCENE = preload("res://scenes/explosion.tscn")


func _ready() -> void:
	add_to_group("enemies")


func _process(delta: float) -> void:
	time_alive += delta
	var movement := direction * speed * delta
	if wave_amplitude > 0:
		movement.x += sin(time_alive * wave_speed) * wave_amplitude * delta
	position += movement

	if position.y > 780:
		queue_free()


func destroy() -> void:
	health -= 1
	if health <= 0:
		GameManager.add_score(points)
		_spawn_explosion()
		queue_free()


func _spawn_explosion() -> void:
	var explosion = EXPLOSION_SCENE.instantiate()
	explosion.position = global_position
	get_tree().current_scene.add_child(explosion)
