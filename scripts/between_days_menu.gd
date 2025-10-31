extends Control

var current_menu : String = "menu"

func _ready():
	$Settings/X.visible = false
	$Settings/MouseStopper.visible = false
	$Settings.mouse_filter = MouseFilter.MOUSE_FILTER_IGNORE
	$Settings/BG.visible = false
	$Settings.set_color(Color.BLACK)
	
	load_menu()

var male_head_image = preload("res://art/character_man.png")
var female_head_image = preload("res://art/character_woman.png")

func load_menu(menu : String = ""):
	if menu != "":
		current_menu = menu
	
	if current_menu == "map":
		$Menu.visible = false
		$Settings.visible = false
		$Map.visible = true
		$Buttons/MapButton/Darken.visible = false
		$Buttons/SettingsButton/Darken.visible = true
		$Buttons/MenuButton/Darken.visible = true
	elif current_menu == "menu":
		$Map.visible = false
		$Settings.visible = false
		$Menu.visible = true
		$Buttons/MenuButton/Darken.visible = false
		$Buttons/MapButton/Darken.visible = true
		$Buttons/SettingsButton/Darken.visible = true
	elif current_menu == "settings":
		$Map.visible = false
		$Menu.visible = false
		
		$Settings.visible = true
		$Settings.load_info()
		
		$Buttons/MenuButton/Darken.visible = true
		$Buttons/MapButton/Darken.visible = true
		$Buttons/SettingsButton/Darken.visible = false
	
	var save = GlobalData.get_current_save()
	
	$PlayerName.text = save.player_name
	$Day.text = "Day " + str(save.day)
	$Coins.text = str(save.coins)
	
	if save.male:
		$Head.texture = male_head_image
	else:
		$Head.texture = female_head_image


func _on_next_day_button_pressed() -> void:
	GlobalData.start_day()
