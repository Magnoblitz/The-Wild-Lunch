extends Node2D


#here, what should happen if the money goes negative?
#maybe at the end of the day, no money will be made, but none will be removed



@export var main_plate : FoodHolder
@export var oven : Oven
@export var btm_left_pan : PanCooker
@export var top_left_pan : PanCooker
@export var top_right_pan : PanCooker
@export var btm_right_pan : PanCooker
@export var rotgut : FoodHolder
@export var jerky : FoodHolder
@export var hotsauce : FoodHolder
@export var bowls : FoodHolder
@export var cooking_plate1 : SpecialFoodHolder
@export var cooking_plate2 : SpecialFoodHolder
@export var cooking_plate3 : SpecialFoodHolder

@export var customer_container : Node2D

var dragging_enabled : bool = true
var dragging_food : bool = false
var what_plate_dragging : FoodHolder

var trash_enabled : bool = true

func _ready() -> void:
	load_kitchen()

func _process(_delta: float) -> void:
	if dragging_food:
		$DraggingFood.global_position = get_global_mouse_position()
		
		if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			release_food()

func receive_action(_viewport: Node, event: InputEvent, _shape_idx: int, action: int) -> void:
	if (not event is InputEventMouseButton) or (not event.pressed):
		return
	
	#apply the action to the main plate
	var next_state = GlobalData.apply_action_to_food(main_plate.plate_state, action)
	if next_state != null:
		main_plate.plate_state = next_state
		load_kitchen()
		GlobalData.play_action_sound(action)
		get_parent().get_node("UI/Tutorial").receive_action(action)
		return
	
	#apply the action to the oven
	next_state = GlobalData.apply_action_to_food(oven.plate_state, action)
	if next_state != null:
		var cooked_state = GlobalData.apply_action_to_food(next_state, 3)
		if oven.cooking_state == GlobalData.CookingState.IDLE && cooked_state != null:
			oven.insert_food(cooked_state, next_state.cooking_time)
		
		load_kitchen()
		GlobalData.play_action_sound(action)
		get_parent().get_node("UI/Tutorial").receive_action(action)
		return

func load_kitchen():
	main_plate.get_node("Food").texture = main_plate.plate_state.image
	oven.load_oven_data()
	btm_left_pan.load_pan_data()
	top_left_pan.load_pan_data()
	top_right_pan.load_pan_data()
	btm_right_pan.load_pan_data()
	cooking_plate1.get_node("Food").texture = cooking_plate1.plate_state.image
	cooking_plate2.get_node("Food").texture = cooking_plate2.plate_state.image
	cooking_plate3.get_node("Food").texture = cooking_plate3.plate_state.image
	
	
	
	var allowed_orders : Array[int] = []
	
	var unlocked_food = GlobalData.get_current_save().unlocked_food
	if unlocked_food.has("Rotgut"):
		$Rotgut.visible = true
		allowed_orders.push_back(2)
	else:
		$Rotgut.visible = false
	
	if unlocked_food.has("Beans"):
		$Beans.visible = true
		$Bowls.visible = true
		allowed_orders.push_back(0)
	else:
		$Beans.visible = false
		$Bowls.visible = false
	
	if unlocked_food.has("Jerky"):
		$Jerky.visible = true
		get_node("Pans/0").visible = true
		allowed_orders.push_back(3)
	else:
		$Jerky.visible = false
		get_node("Pans/0").visible = false
	
	if unlocked_food.has("Pan1"):
		get_node("Pans/1").visible = true
	else:
		get_node("Pans/1").visible = false
	
	if unlocked_food.has("Pan2"):
		get_node("Pans/2").visible = true
	else:
		get_node("Pans/2").visible = false
	
	if unlocked_food.has("Pan3"):
		get_node("Pans/3").visible = true
	else:
		get_node("Pans/3").visible = false
	
	if unlocked_food.has("Hotsauce"):
		$Hotsauce.visible = true
		allowed_orders.push_back(4)
	else:
		$Hotsauce.visible = false
	
	if unlocked_food.has("Cornbread"):
		$Cornbread.visible = true
		allowed_orders.push_back(1)
	else:
		$Cornbread.visible = false
	
	get_parent().allowed_orders = allowed_orders
	
	
	
	if not dragging_food:
		$DraggingFood.visible = false


func plate_touched(_viewport: Node, event: InputEvent, _shape_idx: int, plate: String) -> void:
	if (not event is InputEventMouseButton) or (not event.pressed) or not dragging_enabled:
		return
	
	dragging_food = true
	
	if plate == "MainPlate":
		what_plate_dragging = main_plate
	elif plate == "Oven":
		what_plate_dragging = oven
	elif plate == "Rotgut":
		what_plate_dragging = rotgut
	elif plate == "Jerky":
		what_plate_dragging = jerky
	elif plate == "Hotsauce":
		what_plate_dragging = hotsauce
	elif plate == "BtmLeftPan":
		if btm_left_pan.cooking_state == GlobalData.CookingState.COOKING:
			dragging_food = false
			return
		what_plate_dragging = btm_left_pan
	elif plate == "TopLeftPan":
		if top_left_pan.cooking_state == GlobalData.CookingState.COOKING:
			dragging_food = false
			return
		what_plate_dragging = top_left_pan
	elif plate == "TopRightPan":
		if top_right_pan.cooking_state == GlobalData.CookingState.COOKING:
			dragging_food = false
			return
		what_plate_dragging = top_right_pan
	elif plate == "BtmRightPan":
		if btm_right_pan.cooking_state == GlobalData.CookingState.COOKING:
			dragging_food = false
			return
		what_plate_dragging = btm_right_pan
	elif plate == "Bowls":
		what_plate_dragging = bowls
	elif plate == "CookingPlate1":
		what_plate_dragging = cooking_plate1
	elif plate == "CookingPlate2":
		what_plate_dragging = cooking_plate2
	elif plate == "CookingPlate3":
		what_plate_dragging = cooking_plate3
	
	if what_plate_dragging == null:
		dragging_food = false
		return
	
	#Set the plate's image to whatever the "empty plate state"'s image is:
	var ps : PlateState = what_plate_dragging.empty_plate_state
	
	#For plates that legitimately hold food items on top of themselves
	if what_plate_dragging.food_display == FoodHolder.FoodDisplay.NORMAL:
		what_plate_dragging.get_node("Food").texture = ps.image
	#For plates that are really just a source of food in the kitchen
	elif what_plate_dragging.food_display == FoodHolder.FoodDisplay.PLATED:
		what_plate_dragging.get_node("Food").texture = ps.plated_image
	#For the pan
	else:
		what_plate_dragging.get_node("Pan").texture = ps.pan_images[what_plate_dragging.name.to_int()]
	
	$DraggingFood.texture = what_plate_dragging.plate_state.image
	$DraggingFood.visible = true
	
	what_plate_dragging.drag_item()


func get_customer(id : int):
	for customer : Customer in customer_container.get_children():
		if customer.id == id:
			return customer
	return null

func release_food():
	#Food can be dragged over a customer (to serve them)
	#Over a trash can (to trash the food)
	#Over a kitchen tool such as an oven (to utilize the tool)
	
	what_plate_dragging.stop_drag_item()
	$DraggingFood/Fire.restart()
	$DraggingFood/Fire.emitting = false
	$DraggingFood/Smoke.restart()
	$DraggingFood/Smoke.emitting = false
	
	if not mouse_in_region:
		dragging_food = false
		$DraggingFood.visible = false
		load_kitchen()
		return
	
	#The food is over the trash can
	if what_region_mouse_is_in == -1 and trash_enabled:
		lose_money(what_plate_dragging.plate_state.trash_value)
		get_parent().get_node("UI/Tutorial").item_trashed(what_plate_dragging.plate_state)
		what_plate_dragging.remove_item()
		SoundSystem.play_sound("trash item", 8)
	elif what_region_mouse_is_in == -2:  #Oven
		var next_state = GlobalData.apply_action_to_food(what_plate_dragging.plate_state, 3)
		if oven.cooking_state == GlobalData.CookingState.IDLE && next_state != null:  #If the oven is not being used and the item can actually be cooked
			GlobalData.play_action_sound(3)
			get_parent().get_node("UI/Tutorial").receive_action(3)
			oven.insert_food(next_state, what_plate_dragging.plate_state.cooking_time)
			what_plate_dragging.remove_item()
	elif what_region_mouse_is_in == -3:  #CURRENTLY UNUSED
		pass
	elif what_region_mouse_is_in == -4:  #MainPlate
		if what_plate_dragging.plate_state.main_plate_action != -1:
			var next_state = GlobalData.apply_action_to_food(main_plate.plate_state, what_plate_dragging.plate_state.main_plate_action)
			if next_state != null:
				GlobalData.play_action_sound(what_plate_dragging.plate_state.main_plate_action)
				get_parent().get_node("UI/Tutorial").receive_action(what_plate_dragging.plate_state.main_plate_action)
				main_plate.plate_state = next_state
	elif what_region_mouse_is_in == -5: #CookingPlate1
		if cooking_plate1.can_add_food(what_plate_dragging.plate_state):
			cooking_plate1.add_food(what_plate_dragging.plate_state)
			get_parent().get_node("UI/Tutorial").item_on_small_plate(what_plate_dragging.plate_state)
			what_plate_dragging.remove_item()
	elif what_region_mouse_is_in == -6: #CookingPlate2
		if cooking_plate2.can_add_food(what_plate_dragging.plate_state):
			cooking_plate2.add_food(what_plate_dragging.plate_state)
			get_parent().get_node("UI/Tutorial").item_on_small_plate(what_plate_dragging.plate_state)
			what_plate_dragging.remove_item()
	elif what_region_mouse_is_in == -7: #CookingPlate3
		if cooking_plate3.can_add_food(what_plate_dragging.plate_state):
			cooking_plate3.add_food(what_plate_dragging.plate_state)
			get_parent().get_node("UI/Tutorial").item_on_small_plate(what_plate_dragging.plate_state)
			what_plate_dragging.remove_item()
	elif what_region_mouse_is_in == -8: #BtmLeftPan
		var next_state = GlobalData.apply_action_to_food(what_plate_dragging.plate_state, 5)
		if btm_left_pan.cooking_state == GlobalData.CookingState.IDLE && next_state != null:  #If the pan is not being used and the item can actually be cooked
			add_item_to_pan(btm_left_pan, next_state, 0)
	elif what_region_mouse_is_in == -9: #TopLeftPan
		var next_state = GlobalData.apply_action_to_food(what_plate_dragging.plate_state, 5)
		if top_left_pan.cooking_state == GlobalData.CookingState.IDLE && next_state != null:  #If the pan is not being used and the item can actually be cooked
			add_item_to_pan(top_left_pan, next_state, 1)
	elif what_region_mouse_is_in == -10: #TopRightPan
		var next_state = GlobalData.apply_action_to_food(what_plate_dragging.plate_state, 5)
		if top_right_pan.cooking_state == GlobalData.CookingState.IDLE && next_state != null:  #If the pan is not being used and the item can actually be cooked
			add_item_to_pan(top_right_pan, next_state, 2)
	elif what_region_mouse_is_in == -11: #BtmRightPan
		var next_state = GlobalData.apply_action_to_food(what_plate_dragging.plate_state, 5)
		if btm_right_pan.cooking_state == GlobalData.CookingState.IDLE && next_state != null:  #If the pan is not being used and the item can actually be cooked
			add_item_to_pan(btm_right_pan, next_state, 3)
	
	else:
		var customer = get_customer(what_region_mouse_is_in)
		
		if customer != null:
			#Is this food what the customer is asking for?
			if customer.is_ordering_food(what_plate_dragging.plate_state.id):
				get_parent().customer_received_food(customer, what_plate_dragging.plate_state.id)
				served_food(what_plate_dragging.plate_state.id)
				customer.receive_food(what_plate_dragging.plate_state.id)
				what_plate_dragging.remove_item()
	
	dragging_food = false
	$DraggingFood.visible = false
	
	load_kitchen()
	trash_changed(true)

func add_item_to_pan(pan : PanCooker, next_state : PlateState, index : int):
	GlobalData.play_action_sound(5)
	get_parent().get_node("UI/Tutorial").receive_action(5)
	pan.insert_food(next_state, what_plate_dragging.plate_state.cooking_time, what_plate_dragging.plate_state.pan_images[index])
	what_plate_dragging.remove_item()
	get_parent().get_node("UI/Tutorial").item_added_to_pan(next_state)

func served_food(id : int):
	for v in range(0, get_parent().food_served.size()):
		if get_parent().food_served[v].x == id:
			get_parent().food_served[v].y += 1
			return
	get_parent().food_served.push_back(Vector2i(id, 1))




var mouse_in_region : bool = false
var what_region_mouse_is_in : int = 0
func mouse_entered_region(region_num : int) -> void:
	var in_trash = mouse_in_region and what_region_mouse_is_in == -1 and dragging_food
	
	mouse_in_region = true
	what_region_mouse_is_in = region_num
	
	#if the user entered the trash can, it will play a sound
	if in_trash != (mouse_in_region and what_region_mouse_is_in == -1 and dragging_food):
		trash_changed()
func mouse_exited_region() -> void:
	#if the user's mouse exits the trash can, play a sound
	if mouse_in_region and what_region_mouse_is_in == -1 and dragging_food:
		mouse_in_region = false
		trash_changed()
	
	mouse_in_region = false


var trash_closed_image = preload("res://art/trash_can_lid_closed.png")
var trash_open_image = preload("res://art/trash_can_lid_open.png")
func trash_changed(trash_item : bool = false):
	if mouse_in_region and what_region_mouse_is_in == -1 and dragging_food:
		SoundSystem.play_sound("open trash", 3)
		$Trash/Lid.texture = trash_open_image
		$Trash/Lid.position = Vector2(71, 554)
	else:
		if not trash_item:
			SoundSystem.play_sound("close trash", 3)
		$Trash/Lid.texture = trash_closed_image
		$Trash/Lid.position = Vector2(76, 611)


var coins_object = preload("res://scene_objects/coins.tscn")

func customer_pays(amount : int, x_pos : int):
	#make some sort of effect to show that the money has been collected
	#clink sound effect
	#coins "fly" over to the coin ui to show the collection
	var coins = coins_object.instantiate()
	coins.value = amount
	coins.position.x = x_pos
	$Coins.add_child(coins)

func lose_money(amount : int):
	#lose money based on item's price
	get_tree().current_scene.lose_coins(amount)
