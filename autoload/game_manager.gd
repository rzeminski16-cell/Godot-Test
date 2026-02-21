extends Node

## Global game manager autoload for tracking score, lives, and game state.

signal score_changed(new_score: int)
signal lives_changed(new_lives: int)
signal game_over

var score: int = 0
var lives: int = 3
var high_score: int = 0
var is_game_active: bool = false


func reset() -> void:
	score = 0
	lives = 3
	is_game_active = true
	score_changed.emit(score)
	lives_changed.emit(lives)


func add_score(points: int) -> void:
	score += points
	if score > high_score:
		high_score = score
	score_changed.emit(score)


func lose_life() -> void:
	lives -= 1
	lives_changed.emit(lives)
	if lives <= 0:
		is_game_active = false
		game_over.emit()
