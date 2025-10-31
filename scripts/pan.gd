extends FoodHolder
class_name PanCooker

var cooking_state : GlobalData.CookingState = GlobalData.CookingState.IDLE
var time_remaining : float
var can_burn : bool = false
var burnt : bool = false
var burning_disabled : bool = false

var cooking_image : Texture2D

var kitchen = null
var game_running : bool = true

func _ready() -> void:
	kitchen = get_parent().get_parent()
	
	get_parent().get_parent().get_parent().change_game_running.connect(func(running : bool): game_running = running)
	load_pan_data()

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
			
			if sizzle_sound_id != -1:
				#Stop sizzling sound
				SoundSystem.stop_sound(sizzle_sound_id)
				sizzle_sound_id = -1
				
				#Play burning sound
				burn_sound_id = SoundSystem.play_sound("fire")


var sizzle_sound_id : int = -1
var burn_sound_id : int = -1
var smoke_sound_id : int = -1

func insert_food(food : PlateState, time : float, previous_image : Texture2D):
	plate_state = food
	time_remaining = time
	cooking_state = GlobalData.CookingState.COOKING
	cooking_image = previous_image
	
	load_pan_data()
	
	sizzle_sound_id = SoundSystem.play_sound("sizzle")

func finished_cooking():
	cooking_state = GlobalData.CookingState.WAITING_WITH_FOOD
	time_remaining = plate_state.burning_time
	load_pan_data()
	
	get_parent().get_parent().get_parent().get_node("UI/Tutorial").done_cooking(plate_state)
	
	var next_state = GlobalData.apply_action_to_food(plate_state, 6)
	if next_state == null:
		can_burn = false
	else:
		can_burn = true

func load_pan_data():
	if cooking_state == GlobalData.CookingState.COOKING:
		$Pan.texture = cooking_image
	else:
		$Pan.texture = plate_state.pan_images[name.to_int()]
	
	if cooking_state == GlobalData.CookingState.COOKING:
		$Sparks.emitting = true
	else:
		$Sparks.emitting = false

func burnt_food():
	#The food is now burnt
	var next_state = GlobalData.apply_action_to_food(plate_state, 6)
	plate_state = next_state
	$Fire.emitting = false
	$Smoke.emitting = true
	
	#Stop burning sound and play fire sound
	SoundSystem.stop_sound(burn_sound_id)
	burn_sound_id = -1
	smoke_sound_id = SoundSystem.play_sound("smoke", 4)
	
	finished_cooking()
	load_pan_data()
	
	if kitchen.dragging_food and kitchen.what_plate_dragging == self:
		var event = InputEventMouseButton.new()
		event.pressed = true
		
		var pan_name : String = "BtmLeftPan"
		if name == "1":
			pan_name = "TopLeftPan"
		elif name == "2":
			pan_name = "TopRightPan"
		elif name == "3":
			pan_name = "BtmRightPan"
		
		kitchen.plate_touched(null, event, 0, pan_name)
		
		kitchen.get_node("DraggingFood/Fire").emitting = false
		kitchen.get_node("DraggingFood/Smoke").emitting = true

func remove_item():
	plate_state = empty_plate_state
	cooking_state = GlobalData.CookingState.IDLE
	load_pan_data()
	$Fire.emitting = false
	$Smoke.emitting = false
	
	SoundSystem.stop_sound(sizzle_sound_id)
	sizzle_sound_id = -1
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
