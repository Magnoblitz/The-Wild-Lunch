extends Node2D
class_name GameManager

@export var tutorial_mode : bool = false

@export var allowed_orders : Array[int]
@export var allowed_customers : Array[CustomerInfo]

@export var customer_x_positions = [300, 640, 980]
var current_customer_positions = []

@export var starting_customers : int = 1
@export var coins : int = 0

var remaining_customers : int
var customers_served : int = 0
var customers_lost : int = 0

var food_served : Array[Vector2i]

var game_running : bool = false
@warning_ignore("UNUSED_SIGNAL")
signal change_game_running(running : bool)

var game_started : bool = false

@export var songs : Array[AudioInfo]
var current_song : int = -1



func _ready() -> void:
	$Timers/StartGame.start(4)
	$UI/SettingsButton.visible = false
	
	$UI/FadeIn.visible = true
	$UI/FadeIn/Title.text = "[center]Day " + str(GlobalData.get_current_save().day) + "[/center]"
	
	remaining_customers = starting_customers
	
	SoundSystem.music_finished.connect(next_song)
	songs.shuffle()

func next_song():
	current_song += 1
	if current_song >= songs.size():
		current_song = 0
	
	SoundSystem.play_sound(songs[current_song].sound_name)
	$UI.play_song(songs[current_song])


var loading_end_screen : bool = false
var loading_end_screen_waiting_for_coins : bool = false
var loading_end_screen_time : float = 0

func _process(delta: float) -> void:
	if not game_started:
		$UI/FadeIn/Blur.material.set_shader_parameter("blur_radius", $Timers/StartGame.time_left/2)
		$UI/FadeIn/Title.modulate = Color(1,1,1,$Timers/StartGame.time_left/4)
	
	if loading_end_screen:
		loading_end_screen_time += delta
		
		if not loading_end_screen_waiting_for_coins:
			$UI/EndOfDay/Blur.material.set_shader_parameter("blur_radius", loading_end_screen_time * 0.65)
			$UI/EndOfDay.modulate = Color(1,1,1,loading_end_screen_time/2)
			
			if loading_end_screen_time >= 2:
				loading_end_screen = false
				$UI/EndOfDay/Blur.material.set_shader_parameter("blur_radius", 1.3)
				$UI/EndOfDay.modulate = Color(1,1,1,1)
		elif $Kitchen/Coins.get_children().size() == 0:
			loading_end_screen_waiting_for_coins = false
			$UI/EndOfDay/CoinsText.text = str(coins) + " Coins Earned"


func add_coins(value : int):
	coins += value
	$UI/Coins/CanvasLayer/Particles.emitting = true
	$UI.load_ui()

func lose_coins(amount : int):
	coins -= amount
	$UI.load_ui()

var customer_object = preload("res://scene_objects/customer.tscn")
var customer_id : int = 0

@export var customer_wait_time : float = 25

func spawn_customer():
	#If there aren't any customers remaining, don't spawn more
	if remaining_customers <= 0:
		return
	
	#There are already 3 customers at the counter, don't spawn more
	if current_customer_positions.size() >= 3:
		return
	
	remaining_customers -= 1
	$UI.load_ui()
	
	var possible_positions = [0, 1, 2].filter(func(item): return not item in current_customer_positions)
	var customer_pos = possible_positions.pick_random()
	current_customer_positions.push_back(customer_pos)
	
	var customer : Customer = customer_object.instantiate()
	
	#Choose a random customer
	customer.customer_info = allowed_customers.pick_random()
	
	customer.id = customer_id
	customer_id += 1
	
	#Choose 1-3 random food items to order
	customer.order.push_back(allowed_orders.pick_random())
	var rand_amount = randi_range(1, 3)
	if rand_amount > 1:
		customer.order.push_back(allowed_orders.pick_random())
		if rand_amount > 2:
			customer.order.push_back(allowed_orders.pick_random())
	
	customer.standing_position = customer_x_positions[customer_pos]
	customer.screen_pos = customer_pos
	customer.starting_time = customer_wait_time + randf_range(-2, 4)
	$Customers.add_child(customer)


func force_spawn_customer(customer_pos : int, customer_info : CustomerInfo, order : Array[int], have_timer : bool):
	remaining_customers -= 1
	$UI.load_ui()
	
	current_customer_positions.push_back(customer_pos)
	
	var customer : Customer = customer_object.instantiate()
	customer.customer_info = customer_info
	customer.id = customer_id
	customer_id += 1
	customer.order = order
	customer.standing_position = customer_x_positions[customer_pos]
	customer.screen_pos = customer_pos
	customer.have_timer = have_timer
	
	$Customers.add_child(customer)

func customer_arrived(customer : Customer):
	$UI/Tutorial.customer_arrived(customer)

func customer_received_food(customer : Customer, food_id : int):
	$UI/Tutorial.customer_received_food(customer, food_id)

func coins_collected():
	$UI/Tutorial.coins_collected()



func remove_customer(customer : Customer, served : bool):
	$UI/Tutorial.customer_left(customer)
	
	if served:
		customers_served += 1
		$UI/Tutorial.customer_fully_served(customer)
	else:
		customers_lost += 1
		
		#Play an angry sound when the customers leaves without being served
		if customer.customer_info.male:
			SoundSystem.play_sound("man angry", 3)
		else:
			SoundSystem.play_sound("woman angry", 3)
	
	customer.walking_time = 0
	customer.walking_off_screen = true
	customer.walking_dist = 1400 - customer.standing_position
	customer.load_customer_data()
	
	#Remove the customer's position from current_customer_positions because they are now leaving
	current_customer_positions = current_customer_positions.filter(func(x): return x != customer.screen_pos)
	
	#Determine if the day is done or not:
	
	#There are still customers to come
	if remaining_customers > 0:
		return
	
	#This checks whether the customers on screen are still ordering or are just walking off screen
	var not_done = false
	for c : Customer in $Customers.get_children():
		if !c.walking_off_screen:
			not_done = true
			break
	
	#If day is done, show the "end of day stats"
	if not not_done:
		end_day()


func end_day():
	$Timers/SpawnCustomer.stop()
	$UI/EndOfDay.visible = true
	$UI/EndOfDay.modulate = Color(1,1,1,0)
	loading_end_screen = true
	pause_game()
	
	$UI/EndOfDay/CustomersServed.text = str(customers_served) + " Customers Served"
	$UI/EndOfDay/CustomersLost.text = str(customers_lost) + " Customers Lost"
	$UI/EndOfDay/CoinsText.text = str(coins) + " Coins Earned"
	$UI/EndOfDay/Title.text = "[center]End of Day " + str(GlobalData.get_current_save().day) + "[/center]"
	
	if $Kitchen/Coins.get_children().size() > 0:
		loading_end_screen_waiting_for_coins = true
	
	var coins_value : int = coins
	
	for coin : CoinsObject in $Kitchen/Coins.get_children():
		coin.flying = true
		coins_value += coin.value
	
	var tut = $UI/Tutorial.current_tutorial
	if tut != null:
		var save = GlobalData.get_current_save()
		for t in range(0, save.remaining_tutorials.size()):
			if save.remaining_tutorials[t] == tut.tut_name:
				save.remaining_tutorials.remove_at(t)
				break
	
	GlobalData.save_day_data(coins_value, customers_served, food_served)

@export var customer_spawn_time : float = 8.0

func _on_spawn_customer_timeout() -> void:
	$Timers/SpawnCustomer.wait_time = randf_range(customer_spawn_time - 0.5, customer_spawn_time + 1.0)
	$Timers/SpawnCustomer.start()
	
	spawn_customer()

func _on_settings_button_pressed() -> void:
	$UI/Settings.toggle_visible()
	pause_game()


func pause_game():
	game_running = false
	emit_signal("change_game_running", false)
	$Timers/StartGame.paused = true
	$Timers/SpawnCustomer.paused = true

func unpause_game():
	game_running = true
	emit_signal("change_game_running", true)
	$Timers/StartGame.paused = false
	
	if not tutorial_mode:
		$Timers/SpawnCustomer.paused = false
	
func toggle_pause():
	if game_running:
		pause_game()
	else:
		unpause_game()


func _on_start_game_timeout() -> void:
	unpause_game()
	$UI/FadeIn.visible = false
	game_started = true
	
	if tutorial_mode:
		$UI/Tutorial.game_started()
	else:
		_on_spawn_customer_timeout()
		$UI/SettingsButton.visible = true
		
		#start playing music
		next_song()
