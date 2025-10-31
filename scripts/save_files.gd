extends Node

var saves : Array[SaveFile]

func _ready() -> void:
	load_settings()
	load_save_files()



func generate_settings_file():
	var file = FileAccess.open("user://settings.json", FileAccess.WRITE)
	if file:
		var data = {}
		
		data["brightness"] = General.brightness
		data["music_volume"] = SoundSystem.music_volume
		data["music_muted"] = SoundSystem.music_muted
		data["sfx_volume"] = SoundSystem.sfx_volume
		data["sfx_muted"] = SoundSystem.sfx_muted
		
		file.store_string(JSON.stringify(data, "\t"))
		file.close()

func load_settings():
	var file_path = "user://settings.json"
	
	if not FileAccess.file_exists(file_path):
		return
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file:
		var content = file.get_as_text()
		var data = JSON.parse_string(content)
		
		#ensure the JSON is valid
		if typeof(data) == TYPE_DICTIONARY:
			General.brightness = data["brightness"]
			
			SoundSystem.set_music_volume(data["music_volume"])
			if data["music_muted"]:
				SoundSystem.mute_music()
			else:
				SoundSystem.unmute_music()
			
			SoundSystem.set_sfx_volume(data["sfx_volume"])
			if data["sfx_muted"]:
				SoundSystem.mute_sfx()
			else:
				SoundSystem.unmute_sfx()
		
		file.close()




func generate_save_files():
	#make sure there is a folder for the save files
	var dir = DirAccess.open("user://")
	if not dir.dir_exists("user://saves"):
		dir.make_dir("user://saves")
	
	#delete all existing save files
	var save_dir = DirAccess.open("user://saves")
	save_dir.list_dir_begin()
	var file_name = save_dir.get_next()
	while file_name != "":
		if file_name.ends_with(".json"):
			save_dir.remove("user://saves/" + file_name)
		file_name = save_dir.get_next()
	
	var file_iterator : int = 0
	
	for save_file : SaveFile in saves:
		var file = FileAccess.open("user://saves/save" + str(file_iterator) + ".json", FileAccess.WRITE)
		if file:
			file_iterator += 1
			
			var data = {}
			
			data["player_name"] = save_file.player_name
			data["male"] = save_file.male
			data["coins"] = save_file.coins
			data["day"] = save_file.day
			data["customers_served"] = save_file.customers_served
			data["unlocked_food"] = save_file.unlocked_food
			data["remaining_tutorials"] = save_file.remaining_tutorials
			
			#serialize the food_served array before adding it to the data
			var food_served_array = []
			for v in save_file.food_served:
				food_served_array.append([v.x,v.y])
			data["food_served"] = food_served_array
			
			
			file.store_string(JSON.stringify(data, "\t"))
			file.close()

func load_save_files():
	var dir = DirAccess.open("user://saves")
	if not dir or not dir.dir_exists("user://saves"):
		return
	
	#clear current saves array before loading
	saves.clear()  
	
	#get all files in the saves directory
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if file_name.ends_with(".json"):
			var file = FileAccess.open("user://saves/" + file_name, FileAccess.READ)
			if file:
				var content = file.get_as_text()
				var json = JSON.new()
				var parse_result = json.parse(content)
				if parse_result == OK:
					var data = json.data
					if typeof(data) == TYPE_DICTIONARY:
						var save_file = SaveFile.new()
						save_file.player_name = data.get("player_name", "")
						save_file.male = data.get("male", false)
						save_file.coins = data.get("coins", 0)
						save_file.day = data.get("day", 1)
						save_file.customers_served = data.get("customers_served", 0)
						
						#convert the unlocked_food array back to a proper string array
						var unlocked_food_array: Array[String] = []
						for v in data.get("unlocked_food", []):
							unlocked_food_array.push_back(v)
						save_file.unlocked_food = unlocked_food_array
						
						#convert the remaining_tutorials array back to a proper string array
						var remaining_tutorials_array: Array[String] = []
						for v in data.get("remaining_tutorials", []):
							remaining_tutorials_array.push_back(v)
						save_file.remaining_tutorials = remaining_tutorials_array
						
						#convert the food_served array back to a proper vector2i array
						var food_served_array: Array[Vector2i] = []
						for v in data.get("food_served", []):
							food_served_array.push_back(Vector2i(v[0], v[1]))
						save_file.food_served = food_served_array
						
						
						saves.append(save_file)
				file.close()
		file_name = dir.get_next()

func remove_save(save : int):
	saves.remove_at(save)




func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST: #The player has just closed the window
		save_and_quit()
		get_tree().quit()

func save_and_quit():
	generate_save_files()
	generate_settings_file()
	get_tree().quit()
