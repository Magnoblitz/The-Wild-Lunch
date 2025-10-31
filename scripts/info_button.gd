extends Control

@export var title_text : String = ""
@export_multiline var content_text : String 

var info_panel_object = preload("res://scene_objects/info_panel.tscn")
var info_panel = null


func mouse_entered() -> void:
	info_panel = info_panel_object.instantiate()
	info_panel.get_node("Title").text = title_text
	info_panel.get_node("Content").text = content_text
	
	var half_screen_size = get_viewport_rect().size / 2
	
	if global_position.x < half_screen_size.x:  #On left half of screen
		info_panel.global_position.x = global_position.x + 64
	else: #On right half of screen
		info_panel.global_position.x = global_position.x - 357
	
	if global_position.y < half_screen_size.y:  #On top half of screen
		info_panel.global_position.y = global_position.y + 64
	else: #On bottom half of screen
		info_panel.global_position.y = global_position.y - 275
	
	
	get_parent().add_child(info_panel)

func mouse_exited() -> void:
	if info_panel != null:
		info_panel.queue_free()
