extends Node2D

@export var rotate_speed : float = 5

func _process(delta: float) -> void:
	rotation += rotate_speed * delta
