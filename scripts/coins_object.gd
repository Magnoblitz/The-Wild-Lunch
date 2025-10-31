extends Sprite2D
class_name CoinsObject

@export var target_position: Vector2 = Vector2(1080, 60)
@export var speed: float = 400.0  
@export var acceleration: float = 700.0

var value : int
var flying : bool = false

func clicked_coins(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if flying or (not event is InputEventMouseButton) or (not event.pressed):
		return
	
	flying = true
	SoundSystem.play_sound("coins", 3)
	
	get_parent().get_parent().get_parent().coins_collected()

func _process(delta):
	if flying:
		var direction = (target_position - global_position).normalized()
		speed += acceleration * delta
		global_position += direction * speed * delta 
		
		if global_position.distance_to(target_position) < 10:
			get_tree().current_scene.add_coins(value) 
			queue_free()
