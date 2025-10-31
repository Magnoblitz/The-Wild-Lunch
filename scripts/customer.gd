extends Sprite2D
class_name Customer

@export var customer_info : CustomerInfo
@export var order: Array[int]

var amount_to_pay : int = 0

@export var starting_time: float = 25
var time : float
enum Happiness { HAPPY, UNHAPPY, ANGRY }
var happiness : Happiness = Happiness.HAPPY
var have_timer : bool = true

@export var id : int

@export var standing_position : int = 640
var walking_time : float = 0
var walking_dist : float
var starting_pos : float
var walking : bool
var walking_off_screen : bool #here, make the customer walk off screen when done

var game_running : bool = false

#0 = left
#1 = mid
#2 = right
var screen_pos : int

func _ready() -> void:
	game_running = get_tree().current_scene.game_running
	get_tree().current_scene.change_game_running.connect(func(running : bool): game_running = running)
	
	#Does the customer need to walk any farther to reach their standing position?
	if position.x >= standing_position:
		position.x = standing_position
		walking = false
	else:
		walking = true
		walking_dist = standing_position - position.x
		starting_pos = position.x
	
	time = starting_time
	load_customer_data()

func load_customer_data():
	if happiness == Happiness.HAPPY:
		texture = customer_info.happy_image
	elif happiness == Happiness.UNHAPPY:
		texture = customer_info.unhappy_image
	else:
		texture = customer_info.angry_image
	
	$Request1.texture = null
	$Request2.texture = null
	$Request3.texture = null
	
	if order.size() > 0:
		$Request1.texture = GlobalData.food_items[order[0]].image
		if order.size() > 1:
			$Request2.texture = GlobalData.food_items[order[1]].image
			if order.size() > 2:
				$Request3.texture = GlobalData.food_items[order[2]].image
	
	var show_item : bool = not (walking or walking_off_screen)
	$Request1.visible = show_item
	$Request2.visible = show_item
	$Request3.visible = show_item
	$RequestBubble.visible = show_item
	$Satisfaction.visible = show_item
	
	if not have_timer:
		$Satisfaction.visible = false


const walking_speed : float = 0.2

func _process(delta: float) -> void:
	if not game_running:
		return
	
	if walking_off_screen:
		walking_time += delta * walking_speed
		position.x = standing_position + walking_dist * bezier(walking_time)
		position.y = 265 + sin(20 * walking_time) * 10;
		
		if walking_time >= 1:
			queue_free()
		return
	
	
	if walking:
		walking_time += delta * walking_speed
		position.x = starting_pos + walking_dist * bezier(walking_time)
		position.y = 265 + sin(20 * walking_time) * 10;
		
		if walking_time >= 1:
			position.x = standing_position
			walking = false
			load_customer_data()
			
			get_parent().get_parent().customer_arrived(self)
			
			#Play a sound when the customer orders
			if customer_info.male:
				SoundSystem.play_sound("man order", 3)
			else:
				SoundSystem.play_sound("woman order", 3)
	else:
		time -= delta
	
	if not have_timer:
		return
	
	if time <= 0:
		#if the customer has already been served an item or two, they must pay for those
		if amount_to_pay > 0:
			get_tree().current_scene.get_node("Kitchen").customer_pays(amount_to_pay, position.x)
		
		#the player is leaving because the time ran out and they haven't been fully served yet
		get_tree().current_scene.remove_customer(self, false)
	
	var h = min((time / starting_time) * 256, 256)
	$Satisfaction.region_rect.size.y = h
	$Satisfaction.region_rect.position.y = 256 - h
	$Satisfaction.position.y = -127 + (128 - h / 2) * $Satisfaction.scale.y
	
	var div = 1.0 - time / starting_time
	if div <= 0.516:
		texture = customer_info.happy_image
		happiness = Happiness.HAPPY
	elif happiness == Happiness.HAPPY and div <= 0.703:
		texture = customer_info.unhappy_image
		happiness = Happiness.UNHAPPY
	elif happiness == Happiness.UNHAPPY and div > 0.703:
		texture = customer_info.angry_image
		happiness = Happiness.ANGRY
		
		#Play an unhappy sound when the happiness bar enters the red
		if customer_info.male:
			SoundSystem.play_sound("man unhappy", 5)
		else:
			SoundSystem.play_sound("woman unhappy", 3)


func bezier(t : float):
	return t * t * (3 - 2 * t)

func mouse_entered_bubble() -> void:
	get_tree().current_scene.get_node("Kitchen").mouse_entered_region(id) 

func mouse_exited_bubble() -> void:
	get_tree().current_scene.get_node("Kitchen").mouse_exited_region() 



#Checks if this customer is ordering a certain food item
func is_ordering_food(food_id : int):
	return order.has(food_id)

func receive_food(food_id : int):
	#Remove this food item from the remaining order
	var index = order.find(food_id)
	if index != -1:
		order.remove_at(index)
	
	amount_to_pay += GlobalData.food_items[food_id].price
	
	load_customer_data()
	
	if order.size() == 0:
		var payment : int = amount_to_pay
		if have_timer:
			if happiness == Happiness.HAPPY:
				payment = int(float(payment) * 1.5)
			elif happiness == Happiness.UNHAPPY:
				payment = int(float(payment) * 1.25)
		
		get_tree().current_scene.get_node("Kitchen").customer_pays(payment, position.x)
		get_tree().current_scene.remove_customer(self, true)
		
		#Play sound when customer receives food
		if customer_info.male:
			SoundSystem.play_sound("man receive food", 3)
		else:
			SoundSystem.play_sound("woman receive food", 3)


var over_nose : bool = false
func _on_nose_mouse_entered() -> void:
	over_nose = true
func _on_nose_mouse_exited() -> void:
	over_nose = false

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed and over_nose:
			SoundSystem.play_sound("honk")
