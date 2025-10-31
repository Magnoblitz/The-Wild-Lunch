extends Control

func _ready():
	food_info_size = Vector2($FoodInfo.texture.get_width(), $FoodInfo.texture.get_height()) * $FoodInfo.scale
	$FoodInfo.visible = false
	
	$BG.queue_free()
	
	for c in $Lunch.get_children():
		if c.name.is_valid_int():
			c.material = c.material.duplicate(true)
			
			c.connect("mouse_entered", func(): mouse_over_food(c.name.to_int()))
			c.mouse_exited.connect(mouse_exited_food)
	
	load_lunch_menu()

func load_lunch_menu():
	$Lunch.visible = true
	
	var unlocked_food = GlobalData.get_current_save().unlocked_food
	
	for c in $Lunch.get_children():
		if not c.name.is_valid_int():
			continue
		
		var food : FoodItem = GlobalData.get_food_by_id(c.name.to_int())
		var food_name = food.internal_name
		if food_name == "":
			food_name = food.name
		
		if unlocked_food.has(food_name):
			c.material.set_shader_parameter("active", false)
		else:
			c.material.set_shader_parameter("active", true)

var showing_food_info : bool = false
var food_info_size : Vector2

func mouse_over_food(id : int):
	var food : FoodItem = GlobalData.get_food_by_id(id)
	
	var times_served : int = 0
	for f in GlobalData.get_current_save().food_served:
		if f.x == id:
			times_served = f.y
			break
	
	$FoodInfo/Name.text = food.name
	$FoodInfo/Price.text = "Price: " + str(food.price) + " coins"
	$FoodInfo/TimesServed.text = "Served " + str(times_served) + " times"
	$FoodInfo.visible = true
	
	showing_food_info = true

func mouse_exited_food():
	showing_food_info = false
	$FoodInfo.visible = false

func _process(_delta: float) -> void:
	if showing_food_info:
		var pos = get_global_mouse_position() - Vector2(0, food_info_size.y)
		pos.y = clamp(pos.y, 0, 720 - food_info_size.y)
		pos.x = clamp(pos.x, 0, 1280 - food_info_size.x)
		$FoodInfo.global_position = pos
