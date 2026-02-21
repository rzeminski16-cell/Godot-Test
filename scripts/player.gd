extends Area2D

## Player spaceship with movement and shooting.

@export var speed: float = 300.0
@export var fire_rate: float = 0.2

var can_shoot: bool = true
var is_alive: bool = true

@onready var shoot_timer: Timer = $ShootTimer
@onready var muzzle: Marker2D = $Muzzle
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var invincibility_timer: Timer = $InvincibilityTimer
@onready var ship_visuals: Array[Node] = []

const BULLET_SCENE = preload("res://scenes/bullet.tscn")

var screen_size: Vector2
var is_invincible: bool = false


func _ready() -> void:
	screen_size = get_viewport_rect().size
	shoot_timer.wait_time = fire_rate
	shoot_timer.timeout.connect(_on_shoot_timer_timeout)
	invincibility_timer.timeout.connect(_on_invincibility_timer_timeout)
	area_entered.connect(_on_area_entered)
	for child in get_children():
		if child is Polygon2D:
			ship_visuals.append(child)


func _process(delta: float) -> void:
	if not is_alive:
		return

	var input_vector := Vector2.ZERO
	input_vector.x = Input.get_axis("move_left", "move_right")
	input_vector.y = Input.get_axis("move_up", "move_down")

	if input_vector.length() > 1.0:
		input_vector = input_vector.normalized()

	position += input_vector * speed * delta

	# Clamp to screen bounds
	position.x = clamp(position.x, 20, screen_size.x - 20)
	position.y = clamp(position.y, 20, screen_size.y - 20)

	if Input.is_action_pressed("shoot") and can_shoot:
		shoot()

	# Blink during invincibility
	if is_invincible:
		var blink = !ship_visuals[0].visible if ship_visuals.size() > 0 else true
		for v in ship_visuals:
			v.visible = blink
	else:
		for v in ship_visuals:
			v.visible = true


func shoot() -> void:
	can_shoot = false
	shoot_timer.start()
	var bullet = BULLET_SCENE.instantiate()
	bullet.position = muzzle.global_position
	get_tree().current_scene.add_child(bullet)


func _on_shoot_timer_timeout() -> void:
	can_shoot = true


func take_damage() -> void:
	if is_invincible:
		return

	GameManager.lose_life()
	if GameManager.lives <= 0:
		die()
	else:
		start_invincibility()


func start_invincibility() -> void:
	is_invincible = true
	invincibility_timer.start()


func _on_invincibility_timer_timeout() -> void:
	is_invincible = false
	for v in ship_visuals:
		v.visible = true


func die() -> void:
	is_alive = false
	visible = false
	collision_shape.set_deferred("disabled", true)


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemies"):
		take_damage()
		area.queue_free()
