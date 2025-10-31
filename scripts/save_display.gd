extends Control

var id : int = -1

func _on_x_button_pressed() -> void:
	get_parent().get_parent().get_parent().ask_remove_save(id)

func _on_button_pressed() -> void:
	GlobalData.current_save = id
	SoundSystem.clear_sounds()
	get_tree().change_scene_to_file("res://scenes/between_days_menu.tscn")
