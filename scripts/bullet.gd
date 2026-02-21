extends Area2D

## Player bullet that moves upward and destroys enemies on contact.

@export var speed: float = 600.0


func _ready() -> void:
	area_entered.connect(_on_area_entered)


func _process(delta: float) -> void:
	position.y -= speed * delta
	if position.y < -20:
		queue_free()


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemies"):
		area.destroy()
		queue_free()
