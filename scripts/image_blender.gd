extends ColorRect

@export var images : Array[Texture2D] = []
@export var current_image : int = 0 ##Choose the starting image

@export var time_between : float = 5
@export var transition_time : float = 1

var current_time = 0
var transitioning : bool = false

func _ready():
	material.set_shader_parameter("current_texture", images[current_image])
	material.set_shader_parameter("new_texture", images[current_image])
	material.set_shader_parameter("time", 0)


func _process(delta: float) -> void:
	current_time += delta

	if transitioning:
		material.set_shader_parameter("time", (current_time - time_between) / transition_time * 2)
		
		if current_time >= time_between + transition_time:
			transitioning = false
			current_image = (current_image + 1) % images.size()
			current_time = 0
		
	elif current_time > time_between:
		transitioning = true
		material.set_shader_parameter("current_texture", material.get_shader_parameter("new_texture"))
		material.set_shader_parameter("new_texture", images[(current_image + 1) % images.size()])
		material.set_shader_parameter("time", 0)
