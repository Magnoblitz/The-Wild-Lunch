extends FoodHolder
class_name Oven

var cooking_state : GlobalData.CookingState = GlobalData.CookingState.IDLE
var time_remaining : float
var can_burn : bool
var burnt : bool = false

var burning_disabled : bool = false

var kitchen = null
var game_running : bool = true

func _ready() -> void:
	kitchen = get_parent()
	
	get_parent().get_parent().change_game_running.connect(func(running : bool): game_running = running)
	load_oven_data()

func _process(delta: float) -> void:
	if not game_running:
		return
	
	time_remaining -= delta
	
	if time_remaining <= 0 and cooking_state == GlobalData.CookingState.COOKING:
		finished_cooking()
		SoundSystem.play_sound("ding", 8)
		return
	
	if burning_disabled:
		return
	
	if can_burn and cooking_state == GlobalData.CookingState.WAITING_WITH_FOOD:
		if time_remaining <= 0:
			burnt_food()
		elif time_remaining <= 4:
			#Show that the food is about to burn by spawning flames
			if kitchen.dragging_food and kitchen.what_plate_dragging == self:
				kitchen.get_node("DraggingFood/Fire").emitting = true
			else:
				$Fire.emitting = true
			
			if burn_sound_id == -1:
				#Stop cooking sound
				SoundSystem.stop_sound(cooking_sound_id)
				cooking_sound_id = -1
				
				#Play burning sound
				burn_sound_id = SoundSystem.play_sound("fire")

var cooking_sound_id : int = -1
var burn_sound_id : int = -1
var smoke_sound_id : int = -1

func insert_food(food : PlateState, time : float):
	plate_state = food
	time_remaining = time
	cooking_state = GlobalData.CookingState.COOKING
	
	load_oven_data()
	
	cooking_sound_id = SoundSystem.play_sound("oven", 4)

func finished_cooking():
	cooking_state = GlobalData.CookingState.WAITING_WITH_FOOD
	time_remaining = plate_state.burning_time
	load_oven_data()
	
	get_parent().get_parent().get_node("UI/Tutorial").done_cooking(plate_state)
	
	var next_state = GlobalData.apply_action_to_food(plate_state, 4)
	if next_state == null:
		can_burn = false
	else:
		can_burn = true

var open_door_image = preload("res://art/open_oven_door.png")
var closed_door_image = preload("res://art/closed_oven_door.png")

func load_oven_data():
	if cooking_state == GlobalData.CookingState.COOKING:
		$Flame.visible = true
		$Door.texture = closed_door_image
		$Food.visible = false
	elif cooking_state == GlobalData.CookingState.WAITING_WITH_FOOD:
		$Food.texture = plate_state.image
		$Food.visible = true
		$Flame.visible = true
		$Door.texture = open_door_image
	else:
		$Food.visible = false
		$Flame.visible = false
		$Door.texture = open_door_image

func burnt_food():
	#The food is now burnt
	var next_state = GlobalData.apply_action_to_food(plate_state, 4)
	plate_state = next_state
	$Fire.emitting = false
	$Smoke.emitting = true
	
	#Stop burning sound and play fire sound
	SoundSystem.stop_sound(burn_sound_id)
	burn_sound_id = -1
	smoke_sound_id = SoundSystem.play_sound("smoke", 4)
	
	finished_cooking()
	load_oven_data()
	
	if kitchen.dragging_food and kitchen.what_plate_dragging == self:
		var event = InputEventMouseButton.new()
		event.pressed = true
		kitchen.plate_touched(null, event, 0, "Oven")
		
		kitchen.get_node("DraggingFood/Fire").emitting = false
		kitchen.get_node("DraggingFood/Smoke").emitting = true

func remove_item():
	plate_state = empty_plate_state
	cooking_state = GlobalData.CookingState.IDLE
	load_oven_data()
	$Fire.emitting = false
	$Smoke.emitting = false
	
	SoundSystem.stop_sound(cooking_sound_id)
	cooking_sound_id = -1
	SoundSystem.stop_sound(burn_sound_id)
	burn_sound_id = -1
	SoundSystem.stop_sound(smoke_sound_id)
	smoke_sound_id = -1



func drag_item():
	if $Fire.emitting:
		kitchen.get_node("DraggingFood/Fire").emitting = true
		$Fire.emitting = false
	if $Smoke.emitting:
		kitchen.get_node("DraggingFood/Smoke").emitting = true
		$Smoke.emitting = false

func stop_drag_item():
	if kitchen.get_node("DraggingFood/Fire").emitting:
		$Fire.emitting = true
	if kitchen.get_node("DraggingFood/Smoke").emitting:
		$Smoke.emitting = true
