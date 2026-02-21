extends Node2D

## Main game scene that manages enemy waves and game state.

@export var enemy_spawn_interval: float = 1.5
@export var min_spawn_interval: float = 0.3
@export var spawn_acceleration: float = 0.98

const ENEMY_SCENE = preload("res://scenes/enemy.tscn")

var spawn_timer: float = 0.0
var current_interval: float
var difficulty_timer: float = 0.0
var wave_number: int = 1
var screen_width: float

@onready var player: Area2D = $Player
@onready var hud: CanvasLayer = $HUD
@onready var game_over_panel: PanelContainer = $GameOverLayer/GameOverPanel
@onready var final_score_label: Label = $GameOverLayer/GameOverPanel/VBoxContainer/FinalScoreLabel
@onready var high_score_label: Label = $GameOverLayer/GameOverPanel/VBoxContainer/HighScoreLabel
@onready var restart_button: Button = $GameOverLayer/GameOverPanel/VBoxContainer/RestartButton
@onready var menu_button: Button = $GameOverLayer/GameOverPanel/VBoxContainer/MenuButton


func _ready() -> void:
	screen_width = get_viewport_rect().size.x
	current_interval = enemy_spawn_interval
	GameManager.reset()
	GameManager.game_over.connect(_on_game_over)
	game_over_panel.visible = false
	restart_button.pressed.connect(_on_restart_pressed)
	menu_button.pressed.connect(_on_menu_pressed)


func _process(delta: float) -> void:
	if not GameManager.is_game_active:
		return

	spawn_timer += delta
	difficulty_timer += delta

	# Increase difficulty over time
	if difficulty_timer > 10.0:
		difficulty_timer = 0.0
		current_interval = max(min_spawn_interval, current_interval * spawn_acceleration)
		wave_number += 1

	if spawn_timer >= current_interval:
		spawn_timer = 0.0
		_spawn_enemy()


func _spawn_enemy() -> void:
	var enemy = ENEMY_SCENE.instantiate()
	enemy.position = Vector2(randf_range(30, screen_width - 30), -30)

	# Increase difficulty with waves
	enemy.speed = randf_range(100, 150 + wave_number * 10)
	enemy.points = 100 + (wave_number - 1) * 25

	# Some enemies have wave movement
	if randf() < 0.3 + wave_number * 0.05:
		enemy.wave_amplitude = randf_range(40, 100)

	# Higher waves can have tougher enemies
	if wave_number >= 3 and randf() < 0.2:
		enemy.health = 2
		enemy.points = 250

	add_child(enemy)


func _on_game_over() -> void:
	game_over_panel.visible = true
	final_score_label.text = "Score: %d" % GameManager.score
	high_score_label.text = "Best: %d" % GameManager.high_score


func _on_restart_pressed() -> void:
	get_tree().reload_current_scene()


func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/title_screen.tscn")
