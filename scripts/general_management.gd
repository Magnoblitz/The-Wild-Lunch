extends Node

var pencil_image = preload("res://art/pencil.png")

func _ready() -> void:
	Input.set_custom_mouse_cursor(pencil_image, Input.CURSOR_IBEAM)
	
	modulate = CanvasModulate.new()
	add_child(modulate)


var brightness : int = 100
var modulate : CanvasModulate

func set_brightness(b : int):
	brightness = b
	var c = b * 0.0084 + 0.16
	modulate.color = Color(c,c,c)



func get_settings_obj(obj : Node) -> Settings:
	if obj is Settings:
		return obj
	
	for c in obj.get_children():
		var o = get_settings_obj(c)
		if o != null:
			return o
	return null


func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_F11:
		if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		
		var settings = get_settings_obj(get_tree().current_scene)
		if settings != null:
			settings.emit_signal("change_fullscreen")
			settings.load_info()
