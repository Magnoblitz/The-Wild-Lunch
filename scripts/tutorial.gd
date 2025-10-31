extends Control

@export var current_tutorial : TutorialSequence
var current_step : int = 0
var active : bool = true

func _ready() -> void:
	hide_tutorial()


#Drag the bowl to the center plate to place it down. Then click the can of beans to add them to the bowl.
#start_hand_movement(Vector2(83, 321), Vector2(225, 303), 2)

var farmer_customer_info = preload("res://customers/farmer.tres")

func game_started():
	if not active:
		return
	
	var start_trigger = current_tutorial.steps[0].start_trigger
	if start_trigger == null or start_trigger.type == TutorialTrigger.Type.GAME_STARTS:
		start_step()


func start_step():
	if not active:
		return
	
	showing_tutorial = true
	
	if current_step >= current_tutorial.steps.size():
		end_tutorial()
		return
	
	var step = current_tutorial.steps[current_step]
	
	for a in current_tutorial.steps[current_step].starting_actions:
		do_action(a)

	show_message(step.text, step.right, step.shaded_bg, step.light_position, step.light_size)
	
	if step.moving_hand:
		start_hand_movement(step.hand_movement_pos1, step.hand_movement_pos2, step.hand_movement_speed)
	else:
		end_hand_movement()
	
	if step.end_trigger.type == TutorialTrigger.Type.CLICK_NEXT:
		$NextButton.visible = true
	else:
		$NextButton.visible = false
	
	if step.end_trigger.type == TutorialTrigger.Type.AUTO_END:
		last_step_ended()


var showing_tutorial : bool = false

func hide_tutorial():
	showing_tutorial = false
	
	$Indian.visible = false
	$IndianBG.visible = false
	$Text.visible = false
	$BG.visible = false
	$NextButton.visible = false
	$Hand.visible = false

func show_message(message : String, right : bool = true, shaded_bg : bool = false, light_position : Vector2 = Vector2(0, 0), light_size : float = 0.85):
	if message == "":
		$Text.visible = false
		$Indian.visible = false
		$IndianBG.visible = false
	else:
		$Text.visible = true
		$Indian.visible = true
		$IndianBG.visible = true
		$Text.text = "[wave]" + message + "[/wave]"
	
	if right:
		$Indian.position = Vector2(1056, 420)
		$IndianBG.position = Vector2(936, 240)
		$IndianBG.flip_h = true
		$Text.position = Vector2(941, 234)
		$NextButton.position = Vector2(945, 424)
	else:
		$Indian.position = Vector2(-12, 420)
		$IndianBG.position = Vector2(0, 240)
		$IndianBG.flip_h = false
		$Text.position = Vector2(6, 234)
		$NextButton.position = Vector2(208, 424)
	
	if shaded_bg:
		$BG.visible = true
		$BG.texture.fill_from = light_position
		$BG.texture.fill_to = light_position + Vector2(light_size, 0)
	else:
		$BG.visible = false



var moving_hand : bool = false
var hand_movement_pos1 : Vector2
var hand_movement_pos2 : Vector2
var hand_movement_time : float = 0
var hand_movement_speed : float = 1

func start_hand_movement(pos1 : Vector2, pos2 : Vector2, speed : float = 1.0):
	moving_hand = true
	$Hand.visible = true
	hand_movement_pos1 = pos1
	hand_movement_pos2 = pos2
	hand_movement_speed = speed

func end_hand_movement():
	moving_hand = false
	$Hand.visible = false

func _process(delta: float) -> void:
	if not active:
		return
	
	if moving_hand:
		hand_movement_time += delta
		var weight = 0.5 * sin(hand_movement_time * hand_movement_speed) + 0.5
		$Hand.position = hand_movement_pos1.lerp(hand_movement_pos2, weight)


func customer_arrived(_customer : Customer):
	check_trigger(TutorialTrigger.Type.CUSTOMER_ARRIVES)

func customer_received_food(_customer : Customer, _food_id : int):
	check_trigger(TutorialTrigger.Type.FOOD_SERVED)

func coins_collected():
	check_trigger(TutorialTrigger.Type.MONEY_COLLECTED)

func customer_fully_served(_customer : Customer):
	check_trigger(TutorialTrigger.Type.CUSTOMER_FULLY_SERVED)

func item_trashed(item : PlateState):
	if not active:
		return
	
	var step = current_tutorial.steps[current_step]
	
	if showing_tutorial and step.end_trigger.type == TutorialTrigger.Type.ITEM_TRASHED:
		var trigger = step.end_trigger
		if trigger.any or trigger.specification_int == item.id:
			last_step_ended()
	elif not showing_tutorial and step.start_trigger.type == TutorialTrigger.Type.ITEM_TRASHED:
		var trigger = step.start_trigger
		if trigger.any or trigger.specification_int == item.id:
			start_step()

func customer_left(_customer : Customer):
	check_trigger(TutorialTrigger.Type.CUSTOMER_LEAVES)

func item_on_small_plate(item : PlateState):
	if not active:
		return
	
	var step = current_tutorial.steps[current_step]
	
	if showing_tutorial and step.end_trigger.type == TutorialTrigger.Type.ITEM_ON_SMALL_PLATE:
		var trigger = step.end_trigger
		if trigger.any or trigger.specification_int == item.id:
			last_step_ended()
	elif not showing_tutorial and step.start_trigger.type == TutorialTrigger.Type.ITEM_ON_SMALL_PLATE:
		var trigger = step.start_trigger
		if trigger.any or trigger.specification_int == item.id:
			start_step()

func item_added_to_pan(item : PlateState):
	if not active:
		return
	
	var step = current_tutorial.steps[current_step]
	
	if showing_tutorial and step.end_trigger.type == TutorialTrigger.Type.ITEM_ADDED_TO_PAN:
		var trigger = step.end_trigger
		if trigger.any or trigger.specification_int == item.id:
			last_step_ended()
	elif not showing_tutorial and step.start_trigger.type == TutorialTrigger.Type.ITEM_ADDED_TO_PAN:
		var trigger = step.start_trigger
		if trigger.any or trigger.specification_int == item.id:
			start_step()

func done_cooking(item : PlateState):
	if not active:
		return
	
	var step = current_tutorial.steps[current_step]
	
	if showing_tutorial and step.end_trigger.type == TutorialTrigger.Type.ITEM_DONE_COOKING:
		var trigger = step.end_trigger
		if trigger.any or trigger.specification_int == item.id:
			last_step_ended()
	elif not showing_tutorial and step.start_trigger.type == TutorialTrigger.Type.ITEM_DONE_COOKING:
		var trigger = step.start_trigger
		if trigger.any or trigger.specification_int == item.id:
			start_step()

func receive_action(action : int):
	if not active:
		return
	
	var step = current_tutorial.steps[current_step]
	
	if showing_tutorial and step.end_trigger.type == TutorialTrigger.Type.ACTION_RECEIVED:
		var trigger = step.end_trigger
		if trigger.any or trigger.specification_int == action:
			last_step_ended()
	elif not showing_tutorial and step.start_trigger.type == TutorialTrigger.Type.ACTION_RECEIVED:
		var trigger = step.start_trigger
		if trigger.any or trigger.specification_int == action:
			start_step()

func check_trigger(trigger_type : TutorialTrigger.Type):
	if not active:
		return
	
	var step = current_tutorial.steps[current_step]
	
	if showing_tutorial and step.end_trigger.type == trigger_type:
		var trigger = step.end_trigger
		if trigger.any:
			last_step_ended()
	elif not showing_tutorial and step.start_trigger.type == trigger_type:
		var trigger = step.start_trigger
		if trigger.any:
			start_step()

func last_step_ended():
	if not active:
		return
	
	for a in current_tutorial.steps[current_step].ending_actions:
		do_action(a)
	
	current_step += 1
	if current_step >= current_tutorial.steps.size():
		end_tutorial()
		return
	
	if current_tutorial.steps[current_step].start_trigger.type == TutorialTrigger.Type.LAST_TUTORIAL_DONE:
		start_step()
	else:
		hide_tutorial()

func do_action(action : TutorialAction):
	if action.type == TutorialAction.Type.SPAWN_CUSTOMER:
		get_parent().get_parent().force_spawn_customer(action.int1, action.customer_info, action.order, action.bool1)
	elif action.type == TutorialAction.Type.ENABLE_FOOD:
		GlobalData.get_current_save().unlocked_food.push_back(action.string1)
		get_parent().get_parent().get_node("Kitchen").load_kitchen()
	elif action.type == TutorialAction.Type.TOGGLE_DRAGGING:
		get_parent().get_parent().get_node("Kitchen").dragging_enabled = action.bool1
	elif action.type == TutorialAction.Type.TOGGLE_BURNING:
		var kitchen = get_parent().get_parent().get_node("Kitchen")
		kitchen.get_node("Oven").burning_disabled = not action.bool1
		kitchen.get_node("Pans/0").burning_disabled = not action.bool1
		kitchen.get_node("Pans/1").burning_disabled = not action.bool1
		kitchen.get_node("Pans/2").burning_disabled = not action.bool1
		kitchen.get_node("Pans/3").burning_disabled = not action.bool1
	elif action.type == TutorialAction.Type.TOGGLE_TRASH:
		get_parent().get_parent().get_node("Kitchen").trash_enabled = action.bool1
	elif action.type == TutorialAction.Type.START_NORMAL_GAME:
		end_tutorial()


func end_tutorial():
	active = false
	hide_tutorial()
	get_parent().get_parent().tutorial_mode = false
	get_parent().get_parent()._on_start_game_timeout()
