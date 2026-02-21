extends Control

## Title screen with start button and game title.

@onready var start_button: Button = $VBoxContainer/StartButton
@onready var starfield: Node2D = $Starfield


func _ready() -> void:
	start_button.pressed.connect(_on_start_pressed)
	start_button.grab_focus()


func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_game.tscn")
