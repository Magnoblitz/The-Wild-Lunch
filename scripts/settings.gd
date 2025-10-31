extends Control
class_name Settings

@export var ingame : bool = false 
@export var between_days : bool = false

func _ready():
	load_info()

func toggle_visible():
	visible = not visible
	
	if visible:
		load_info()

func load_info():
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		$FullScreenOptions.selected = 1
	else:
		$FullScreenOptions.selected = 0
	
	$BrightnessBar.value = General.brightness
	$BrightnessValue.text = str(General.brightness) + "%"
	
	$MusicBar.value = SoundSystem.music_volume
	$MusicValue.text = str(SoundSystem.music_volume) + "%"
	if SoundSystem.music_muted:
		$MusicMuted.texture_normal = muted_image
	else:
		$MusicMuted.texture_normal = unmuted_image
	
	$SfxBar.value = SoundSystem.sfx_volume
	$SfxValue.text = str(SoundSystem.sfx_volume) + "%"
	if SoundSystem.sfx_muted:
		$SfxMuted.texture_normal = muted_image
	else:
		$SfxMuted.texture_normal = unmuted_image
	
	
	if not ingame and not between_days:
		$ReturnButton.visible = false


func set_color(color : Color):
	var text_objects = [ $Title, $Volume, $Music, $MusicValue, $SfxValue, $BrightnessValue, $SoundEffects, $Brightness, $Fullscreen]
	for t in text_objects:
		t.add_theme_color_override("font_color", color)
	
	var image_button_objects = [ $MusicMuted, $SfxMuted ]
	for i in image_button_objects:
		i.modulate = color
	
	var text_button_objects = [ $ReturnButton, $ExitButton, $X ]
	for t in text_button_objects:
		t.add_theme_color_override("font_hover_pressed_color", color)
		t.add_theme_color_override("font_hover_color", color)
		t.add_theme_color_override("font_pressed_color", color)
		t.add_theme_color_override("font_focus_color", color)
		t.add_theme_color_override("font_color", color)
	
	var options_objects = [ $FullScreenOptions ]
	for o in options_objects:
		o.add_theme_color_override("font_hover_pressed_color", color)
		o.add_theme_color_override("font_hover_color", color)
		o.add_theme_color_override("font_pressed_color", color)
		o.add_theme_color_override("font_focus_color", color)
		o.add_theme_color_override("font_color", color)
	
	var bar_objects = [ $SfxBar, $MusicBar, $BrightnessBar ]
	for b in bar_objects:
		b.modulate = color



@warning_ignore("UNUSED_SIGNAL")
signal change_fullscreen
@warning_ignore("UNUSED_SIGNAL")
signal change_music_muted

func _on_full_screen_options_item_selected(index: int) -> void:
	if index == 0:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	elif index == 1:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	emit_signal("change_fullscreen")


func _on_exit_button_pressed() -> void:
	if ingame:
		$ExitPanel.visible = true
	else:
		Saving.save_and_quit()

func _on_exit_no_pressed() -> void:
	$ExitPanel.visible = false

func _on_exit_yes_pressed() -> void:
	Saving.save_and_quit()

func _on_brightness_bar_value_changed(value: float) -> void:
	General.set_brightness(int(value))
	$BrightnessValue.text = str(value) + "%"

func _on_x_pressed() -> void:
	visible = false
	
	if ingame:
		get_tree().current_scene.toggle_pause()


func _on_music_bar_value_changed(value: float) -> void:
	$MusicValue.text = str(value) + "%"
	SoundSystem.set_music_volume(int(value))


func _on_sfx_bar_value_changed(value: float) -> void:
	$SfxValue.text = str(value) + "%"
	SoundSystem.set_sfx_volume(int(value))


var muted_image = preload("res://art/muted.png")
var unmuted_image = preload("res://art/unmuted.png")

func _on_music_muted_pressed() -> void:
	SoundSystem.toggle_mute_music()
	
	emit_signal("change_music_muted")
	
	if SoundSystem.music_muted:
		$MusicMuted.texture_normal = muted_image
	else:
		$MusicMuted.texture_normal = unmuted_image

func _on_sfx_muted_pressed() -> void:
	SoundSystem.toggle_mute_sfx()
	
	if SoundSystem.sfx_muted:
		$SfxMuted.texture_normal = muted_image
	else:
		$SfxMuted.texture_normal = unmuted_image



func _on_return_button_pressed() -> void:
	if ingame:
		$ReturnPanel.visible = true
	elif between_days:
		SoundSystem.play_sound("menu music")
		get_tree().change_scene_to_file("res://scenes/save_file_menu.tscn")

func _on_return_no_pressed() -> void:
	$ReturnPanel.visible = false

func _on_return_yes_pressed() -> void:
	SoundSystem.clear_sounds()
	get_tree().change_scene_to_file("res://scenes/between_days_menu.tscn")
