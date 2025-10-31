extends Node

#Actions that can be done on food:
#0 = Add bowl
#1 = Add beans
#2 = Add cornbread mix
#3 = Cook in oven
#4 = Burn in oven
#5 = Cook in pan
#6 = Burn in pan
#7 = Add hotsauce

var food_items: Array = []

enum CookingState { IDLE, COOKING, WAITING_WITH_FOOD }

var current_save : int = 0

func _ready():
	var beans = (FoodItem.new("Bowl O' Beans", load("res://art/bowl_of_beans.png"), 0, 2))
	beans.internal_name = "Beans"
	food_items.append(beans)
	
	food_items.append(FoodItem.new("Cornbread", load("res://art/cornbread.png"), 1, 4))
	food_items.append(FoodItem.new("Rotgut", load("res://art/rot_gut.png"), 2, 2))
	food_items.append(FoodItem.new("Jerky", load("res://art/cooked_jerky.png"), 3, 3))
	
	var spicy_beans = FoodItem.new("Spicy Bowl O' Beans", load("res://art/spicy_bowl_of_beans.png"), 4, 5)
	spicy_beans.internal_name = "Hotsauce"
	food_items.append(spicy_beans)

func get_food_by_id(id : int) -> FoodItem:
	for f in food_items:
		if f.id == id:
			return f
	return null



var tutorials : Array[TutorialSequence] = [ preload("res://tutorials/first.tres"), preload("res://tutorials/cooking.tres"), preload("res://tutorials/pan_and_hotsauce.tres"), preload("res://tutorials/last_pans.tres") ]

func get_tut_by_name(tut_name : String) -> TutorialSequence:
	for t in tutorials:
		if t.tut_name == tut_name:
			return t
	return null



func apply_action_to_food(food : PlateState, action : int) -> PlateState:
	for state in food.next_states:
		if not state.action == action:
			continue
		return state.next_state
	return null


func play_action_sound(action : int):
	if action == 0:
		SoundSystem.play_sound("place bowl", 3)
	elif action == 1:
		SoundSystem.play_sound("beans", 2)
	elif action == 2:
		SoundSystem.play_sound("dough", 3)
	elif action == 7:
		SoundSystem.play_sound("beans", 2)

func save_day_data(coins : int, customers_served : int, food_served : Array[Vector2i]):
	var save = Saving.saves[current_save]
	save.day += 1
	save.coins += coins
	save.customers_served += customers_served
	
	for f in food_served:
		var added_food : bool = false
		
		for f1 in range(0, save.food_served.size()):
			if save.food_served[f1].x == f.x:
				save.food_served[f1].y += f.y
				added_food = true
				break
		
		if not added_food:
			save.food_served.push_back(f)

func get_current_save() -> SaveFile:
	if current_save >= Saving.saves.size() or current_save < 0:
		return SaveFile.new()
	return Saving.saves[current_save]



func use_tutorial(cause : TutorialCause) -> bool:
	if cause.type == TutorialCause.Type.NEED_TO_DO:
		return true
	if cause.type == TutorialCause.Type.GOT_TO_DAY and get_current_save().day >= cause.int1:
		return true
	if cause.type == TutorialCause.Type.CUSTOMERS_SERVED and get_current_save().customers_served >= cause.int1:
		return true
	
	return false

func start_day():
	SoundSystem.clear_sounds()
	
	var game = load("res://scenes/main_game.tscn").instantiate()
	
	var tutorial : TutorialSequence = null
	var save = get_current_save()
	for t in range(0, save.remaining_tutorials.size()):
		var tut = GlobalData.get_tut_by_name(save.remaining_tutorials[t])
		if use_tutorial(tut.cause):
			tutorial = tut
			break
	
	if tutorial == null:
		game.get_node("UI/Tutorial").active = false
		game.tutorial_mode = false
		game.starting_customers = randi_range(8, 12)
	else:
		game.get_node("UI/Tutorial").active = true
		game.get_node("UI/Tutorial").current_tutorial = tutorial
		game.tutorial_mode = true
		game.remaining_customers = tutorial.num_customers
	
	game.customer_spawn_time = 80.0 / (save.day + 12.9) + 6.6
	game.customer_wait_time = 80.0 / (save.day + 4.8) + 23.2
	
	get_tree().root.add_child(game)
	get_tree().current_scene.queue_free()
	get_tree().current_scene = game
