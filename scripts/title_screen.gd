extends Control

#Use this variable to make sure that the menu music is not duplicated when the user navigates from the save_file_menu to the title_screen
var play_menu_music : bool = true

func _ready():
	if play_menu_music:
		SoundSystem.play_sound("menu music")
	
	if SoundSystem.music_muted:
		sound_off()
	else:
		sound_on()
	
	$Man/Anim.play("RESET")
	$Man/Timer.start(man_wait_under_table_time)
	$Man/Bubble.visible = false
	remaining_jokes = jokes.duplicate()
	remaining_jokes.shuffle()
	
	#Connect the change_fullscreen signal from Settings to a function in this script
	$Settings.change_fullscreen.connect(fullscreen_changed)
	fullscreen_changed() #Load the correct texture for the button
	
	#Connect the change_music_muted signal from Settings to a function in this script
	$Settings.change_music_muted.connect(change_music_muted)

func play_button_pressed():
	get_tree().change_scene_to_file("res://scenes/save_file_menu.tscn")

func _on_sound_button_pressed() -> void:
	SoundSystem.toggle_mute_music()
	
	if SoundSystem.music_muted:
		sound_off()
	else:
		sound_on()

func sound_off():
	$SoundButton/Anim.stop()
	$SoundButton.scale = Vector2(1, 1)
	$SoundButton/Slash.visible = true

func sound_on():
	$SoundButton/Anim.play("pulse", -1, 0.5)
	$SoundButton/Slash.visible = false


func _on_exit_button_pressed() -> void:
	Saving.save_and_quit()


#0 = man is under table
#1 = hands are visible
#2 = man is visible
#3 = man is scuttling
#4 = man is telling joke
var man_state : int = 0

@export var man_wait_under_table_time : float = 10
@export var joke_line_time : float = 5

@export var jokes : Array[Joke]
var remaining_jokes : Array[Joke]

var joke_line = 0

func _on_nose_pressed() -> void:
	if man_state == 2 or man_state == 4:
		SoundSystem.play_sound("honk", 2)
		man_state = 4
		
		$Man/Bubble/Joke.text = remaining_jokes[0].lines[0]
		joke_line = 1
		$Man/Bubble.visible = true
		$Man/Timer.start(joke_line_time)

func man_appear() -> void:
	if man_state == 0:
		man_state = 1
		$Man/Anim.play("hands_emerge", -1, 2)
		$Man/Timer.start(3)
	elif man_state == 1:
		man_state = 2
		$Man/Anim.play("man_emerge")
		$Man/Timer.start(5)
	elif man_state == 2:
		man_state = 3
		$Man/Anim.play("scuttle")
	elif man_state == 4:
		if joke_line >= remaining_jokes[0].lines.size():
			
			var last_joke : Joke = remaining_jokes[0]
			remaining_jokes.pop_front()
			
			if remaining_jokes.size() == 0:
				remaining_jokes = jokes.duplicate()
				remaining_jokes.shuffle()
				
				if remaining_jokes[0] == last_joke:
					remaining_jokes.pop_front()
					remaining_jokes.push_back(last_joke)
			
			$Man/Bubble.visible = false
			$Man/Anim.play("man_duck")
			man_state = 0
			$Man/Timer.start(man_wait_under_table_time + 2)
			return
		
		$Man/Bubble/Joke.text = remaining_jokes[0].lines[joke_line]
		joke_line += 1
		$Man/Timer.start(joke_line_time)

func _on_man_anim_animation_finished(anim_name: StringName) -> void:
	if anim_name == "scuttle":
		man_state = 2
		$Man/Timer.start(5)


var fullscreen_image = preload("res://art/fullscreen_button.png")
var windowed_image = preload("res://art/windowed_button.png")

func fullscreen_changed():
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		$FullscreenButton.texture_normal = windowed_image
	else:
		$FullscreenButton.texture_normal = fullscreen_image

func _on_fullscreen_button_pressed() -> void:
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	
	fullscreen_changed()

func _on_settings_button_pressed() -> void:
	$Settings.toggle_visible()


func change_music_muted():
	if SoundSystem.music_muted:
		sound_off();
	else:
		sound_on()



#Credits code:

#This function is called whenever a credits url is pressed
func _on_text_meta_clicked(meta: Variant) -> void:
	OS.shell_open(str(meta))

func _on_credits_button_pressed() -> void:
	$Credits.visible = not $Credits.visible

func _on_credits_x_pressed() -> void:
	$Credits.visible = false
