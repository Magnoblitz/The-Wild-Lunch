extends Control

@export var choose_name : Control
@export var choose_gender : Control
@export var char_info : Control
@export var start_menu : Control

func create_new_save() -> void:
	$SaloonBG.visible = true
	
	choose_name.get_node("NameTextEdit").text = ""
	male = true
	load_gender()
	$CustomizeCharacter.visible = true


const save_positions : Array[Vector2] = [
	Vector2(102, 98),
	Vector2(494, 98),
	Vector2(887, 98),
	Vector2(102, 409),
	Vector2(494, 409),
	Vector2(887, 409)
]

var current_page : int = 1

var save_display_obj = preload("res://scene_objects/save_display.tscn")
var male_symbol_image = preload("res://art/male_symbol.png")
var female_symbol_image = preload("res://art/female_symbol.png")

func load_saves_page():
	#Firstly, delete all of the existing save file papers
	for child in $Saves/Saves.get_children():
		if child.name != "NewSave":
			child.queue_free()
	
	var first_index = (current_page - 1) * 6
	var position_index = 0
	
	for n in range(0, min(6, Saving.saves.size() - first_index)):
		var save : SaveFile = Saving.saves[first_index + n]
		
		var obj = save_display_obj.instantiate()
		obj.id = first_index + n
		
		obj.position = save_positions[position_index]
		position_index += 1
		
		obj.get_node("SaveText").text = "Save " + str(first_index + n + 1)
		obj.get_node("PlayerName").text = save.player_name
		
		if save.male:
			obj.get_node("GenderImage").texture = male_symbol_image
		else:
			obj.get_node("GenderImage").texture = female_symbol_image
		
		obj.get_node("DayText").text = "Day " + str(save.day)
		obj.get_node("CustomersServed").text = str(save.customers_served) + " Customers Served"
		obj.get_node("CoinText").text = str(save.coins) + " Coins"
		
		$Saves/Saves.add_child(obj)
	
	#If there are less than 6 save files on screen, then add the "NewSave" paper and also get rid of the up arrow
	if position_index < 6:
		$Saves/Saves/NewSave.position = save_positions[position_index]
		$Saves/Saves/NewSave.visible = true
		$Saves/UpArrow.visible = false
	else:
		$Saves/Saves/NewSave.visible = false
		$Saves/UpArrow.visible = true
	
	#If the current_page is the first page do not draw the down arrow
	if current_page == 1:
		$Saves/DownArrow.visible = false
	else:
		$Saves/DownArrow.visible = true
	
	#Set the page number text to the current page number
	$Saves/PageNumber.text = "Pg " + str(current_page)

func _on_page_up_arrow_pressed() -> void:
	current_page += 1
	load_saves_page()

func _on_page_down_arrow_pressed() -> void:
	current_page -= 1
	load_saves_page()





func _ready():
	load_saves_page()
	
	load_gender()
	
	$SaloonBG.visible = false
	$CustomizeCharacter.visible = false
	$ChooseGamemode.visible = false
	$NewSaveCreated.visible = false

var male : bool = true

func load_gender():
	var man_head_obj : TextureButton = choose_gender.get_node("ManButton")
	var woman_head_obj : TextureButton = choose_gender.get_node("WomanButton")
	var gender_text : Label = choose_gender.get_node("GenderText")
	var name_text_edit = choose_name.get_node("NameTextEdit")
	
	if male:
		man_head_obj.modulate = Color(1,1,1,1)
		woman_head_obj.modulate = Color(1,1,1,0.4)
		gender_text.text = "You are male, click below to change gender."
		name_text_edit.placeholder_text = "John Doe"
	else:
		man_head_obj.modulate = Color(1,1,1,0.4)
		woman_head_obj.modulate = Color(1,1,1,1)
		gender_text.text = "You are female, click below to change gender."
		name_text_edit.placeholder_text = "Jane Doe"

func change_gender(set_male: bool) -> void:
	male = set_male
	load_gender()

var allowed_name_characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-!@() "

func _on_name_text_edit_text_changed(_new_text : String) -> void:
	var name_text_edit = choose_name.get_node("NameTextEdit")
	
	var new_text = ""
	for c in name_text_edit.text:
		if c in allowed_name_characters:
			new_text += c
	
	var cursor_pos = name_text_edit.get_caret_column()
	name_text_edit.text = new_text
	name_text_edit.set_caret_column(min(cursor_pos, name_text_edit.text.length()))  



func _on_character_next_arrow_pressed() -> void:
	$CustomizeCharacter.visible = false
	$ChooseGamemode.visible = true

func _on_gamemode_back_button_pressed() -> void:
	$CustomizeCharacter.visible = true
	$ChooseGamemode.visible = false

func _on_character_back_button_pressed() -> void:
	$CustomizeCharacter.visible = false
	$SaloonBG.visible = false

func _on_new_save_back_button_pressed() -> void:
	$NewSaveCreated.visible = false


var man_head = preload("res://art/character_man.png")
var woman_head = preload("res://art/character_woman.png")
var cake_image = preload("res://art/cake.png")
var hat_image = preload("res://art/cowboy_hat.png")
var hardtack_image = preload("res://art/hardtack.png")

var gamemode : int = 0

func choose_gamemode(set_gamemode : int) -> void:
	gamemode = set_gamemode
	
	#Load in the NewSaveCreated screen and fill in the character details
	$NewSaveCreated.visible = true
	
	if male:
		char_info.get_node("Head").texture = man_head
	else:
		char_info.get_node("Head").texture = woman_head
	
	var char_name = choose_name.get_node("NameTextEdit").text
	var name_text_obj = char_info.get_node("NameText")
	if char_name.strip_edges().is_empty():
		#If the user didn't input a name for the character, the name will be John/Jane Doe depending on the gender
		if male:
			name_text_obj.text = "John Doe"
		else:
			name_text_obj.text = "Jane Doe"
	else:
		name_text_obj.text = char_name
	
	var gamemode_text_obj = char_info.get_node("GamemodeText")
	var gamemode_image_obj = char_info.get_node("GamemodeImage")
	if gamemode == 0:
		gamemode_image_obj.texture = cake_image
		gamemode_text_obj.text = "Piece of Cake Mode"
	elif gamemode == 1:
		gamemode_image_obj.texture = hat_image
		gamemode_text_obj.text = "Normal Mode"
	else:
		gamemode_image_obj.texture = hardtack_image
		gamemode_text_obj.text = "Hardtack Mode"
	
	start_menu.get_node("CutsceneButton").button_pressed = true

func start_button_pressed():
	Saving.saves.push_back(SaveFile.new(char_info.get_node("NameText").text, male))
	GlobalData.current_save = Saving.saves.size() - 1
	
	var cutscene = start_menu.get_node("CutsceneButton").button_pressed
	if cutscene:
		get_tree().change_scene_to_file("res://scenes/cutscene.tscn")
	else:
		GlobalData.start_day()


var save_to_remove : int = -1

func ask_remove_save(save : int):
	$Saves/AskRemoveSave/Text.text = "Are you sure you want to delete Save " + str(save + 1) + "? This action cannot be undone."
	$Saves/AskRemoveSave.visible = true
	save_to_remove = save

func remove_save():
	$Saves/AskRemoveSave.visible = false
	Saving.remove_save(save_to_remove)
	load_saves_page()

func no_remove_save():
	$Saves/AskRemoveSave.visible = false



func _on_back_to_menu_button_pressed() -> void:
	#Set the current_scene to be the title screen, but don't start playing the menu music again
	var title_screen = load("res://scenes/title_screen.tscn").instantiate()
	title_screen.play_menu_music = false
	get_tree().root.add_child(title_screen)
	get_tree().current_scene = title_screen
