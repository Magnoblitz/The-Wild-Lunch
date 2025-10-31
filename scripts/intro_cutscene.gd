extends Node2D

func _ready() -> void:
	#Hide mouse cursor during the cutscene
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
	#Disable current music and play the cutscene music
	SoundSystem.clear_sounds()
	SoundSystem.play_sound("cutscene music")
	
	$WagonScene.visible = true
	$DirtyRestaurantScene.visible = false
	$WorkScene.visible = false
	
	$AnimationPlayer.play("wagon", -1, 1.5)
	$AnimationPlayer.animation_finished.connect(finish_anim)

var male_silhouette_image = preload("res://art/intro_silhouette_male.png")
var female_silhouette_image = preload("res://art/intro_silhouette_female.png")

func finish_anim(anim_name: String):
	if anim_name == "wagon":
		$DirtyRestaurantScene.visible = true
		$WagonScene.visible = false
		
		#Make the plank fall over
		$DirtyRestaurantScene/Plank.apply_impulse(Vector2(-100, 0))
		
		$AnimationPlayer.play("restaurant")
		at_restaurant = true
		
		if GlobalData.get_current_save().male:
			$DirtyRestaurantScene/CutsceneSilhouette.texture = male_silhouette_image
		else:
			$DirtyRestaurantScene/CutsceneSilhouette.texture = female_silhouette_image
	elif anim_name == "restaurant":
		$WorkScene.visible = true
		$DirtyRestaurantScene.visible = false
		
		$WorkScene/Text.size = Vector2(1, 125)
		$AnimationPlayer.play("work")
	elif anim_name == "work":
		go_to_restaurant()

var at_restaurant : bool = false
var restaurant_time : float = 0

func _process(delta: float) -> void:
	if at_restaurant:
		restaurant_time += delta
		
		var effect = 0
		if restaurant_time > 10:
			effect = (restaurant_time - 10) / 5
		
		$DirtyRestaurantScene/Ghost.material.set_shader_parameter("modulate", Color(1,1,1,effect * 0.667))


func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_S:
			go_to_restaurant()
		elif event.keycode == KEY_M:
			SoundSystem.toggle_mute_music()


func go_to_restaurant():
	SoundSystem.clear_sounds()
	GlobalData.start_day()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
