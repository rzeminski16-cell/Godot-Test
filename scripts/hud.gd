extends CanvasLayer

## Heads-up display showing score and remaining lives.

@onready var score_label: Label = $HUDPanel/HBox/ScoreLabel
@onready var lives_label: Label = $HUDPanel/HBox/LivesLabel


func _ready() -> void:
	GameManager.score_changed.connect(_on_score_changed)
	GameManager.lives_changed.connect(_on_lives_changed)
	_on_score_changed(GameManager.score)
	_on_lives_changed(GameManager.lives)


func _on_score_changed(new_score: int) -> void:
	score_label.text = "SCORE: %d" % new_score


func _on_lives_changed(new_lives: int) -> void:
	var hearts = ""
	for i in range(new_lives):
		hearts += "♥ "
	lives_label.text = hearts.strip_edges()
