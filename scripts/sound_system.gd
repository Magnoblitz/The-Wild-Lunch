extends Node

var audios : Array[AudioInfo] = [
	preload("res://audio/info/can.tres"),
	preload("res://audio/info/cutscene_music.tres"),
	preload("res://audio/info/dough.tres"),
	preload("res://audio/info/fire.tres"),
	preload("res://audio/info/honk.tres"),
	preload("res://audio/info/menu_music.tres"),
	preload("res://audio/info/sizzle.tres"),
	preload("res://audio/info/smoke.tres"),
	preload("res://audio/info/ding.tres"),
	preload("res://audio/info/ingame_music1.tres"),
	preload("res://audio/info/ingame_music2.tres"),
	preload("res://audio/info/ingame_music3.tres"),
	preload("res://audio/info/ingame_music4.tres"),
	preload("res://audio/info/trash_can_open.tres"),
	preload("res://audio/info/trash_can_close.tres"),
	preload("res://audio/info/trash_can_trash_item.tres"),
	preload("res://audio/info/man_unhappy.tres"),
	preload("res://audio/info/woman_unhappy.tres"),
	preload("res://audio/info/man_angry.tres"),
	preload("res://audio/info/woman_angry.tres"),
	preload("res://audio/info/oven.tres"),
	preload("res://audio/info/man_order.tres"),
	preload("res://audio/info/woman_order.tres"),
	preload("res://audio/info/man_receive_food.tres"),
	preload("res://audio/info/woman_receive_food.tres"),
	preload("res://audio/info/put_bowl_down.tres"),
	preload("res://audio/info/beans.tres"),
	preload("res://audio/info/coins.tres"),
]

var volume_dictionary : Dictionary = {}

var current_id : int = 0

func get_audio_info(sound : String) -> AudioInfo:
	for info : AudioInfo in audios:
		if info.sound_name == sound:
			return info
	return null

func play_sound(sound : String, volume : float = 0, pitch : float = 1) -> int:
	var info : AudioInfo = get_audio_info(sound)
	
	if info == null:
		print("Sound: " , sound , " not found")
		return -1
	
	current_id += 1
	
	var obj = AudioStreamPlayer2D.new()
	obj.stream = info.audio_file
	obj.pitch_scale = pitch
	obj.name = str(current_id)
	add_child(obj)
	obj.playing = true
	obj.connect("finished", func(): destroy_obj(obj))
	
	var type_tag = Node.new()
	if info.type == AudioInfo.AudioType.MUSIC:
		type_tag.name = "MUSIC"
	else:
		type_tag.name = "SFX"
	obj.add_child(type_tag)
	
	#Mute the audio if necessary
	if music_muted and type_tag.name == "MUSIC":
		obj.attenuation = 1000000
	elif sfx_muted and type_tag.name == "SFX":
		obj.attenuation = 1000000
	
	#Save the volume in the volume dictionary and set the object's volume
	volume_dictionary[current_id] = volume
	if type_tag.name == "MUSIC":
		obj.volume_db = volume + usable_music_volume
	else:
		obj.volume_db = volume + usable_sfx_volume
	
	return current_id

func stop_sound(id : int):
	if id < 1 or id > current_id:
		return
	
	var node = get_node(str(id))
	if node:
		node.queue_free()

@warning_ignore("UNUSED_SIGNAL")
signal music_finished()

func destroy_obj(obj: AudioStreamPlayer2D):
	if obj.get_child(0).name == "MUSIC":
		emit_signal("music_finished")
	
	obj.queue_free()

func clear_sounds():
	for child in get_children():
		child.queue_free()



var music_muted : bool = false

func mute_music():
	music_muted = true
	for child in get_children():
		if child.get_child(0).name == "MUSIC":
			child.attenuation = 1000000

func unmute_music():
	music_muted = false
	for child in get_children():
		if child.get_child(0).name == "MUSIC":
			child.attenuation = 0

func toggle_mute_music():
	if music_muted:
		unmute_music()
	else:
		mute_music()



var sfx_muted : bool = false

func mute_sfx():
	sfx_muted = true
	for child in get_children():
		if child.get_child(0).name == "SFX":
			child.attenuation = 1000000

func unmute_sfx():
	sfx_muted = false
	for child in get_children():
		if child.get_child(0).name == "SFX":
			child.attenuation = 0

func toggle_mute_sfx():
	if sfx_muted:
		unmute_sfx()
	else:
		mute_sfx()


var music_volume : int = 100
var usable_music_volume : float = 0

func set_music_volume(volume: int):
	music_volume = volume
	
	if volume <= 0:
		usable_music_volume = -80
	else:
		usable_music_volume = 10 * log(float(music_volume) / 100)
	
	for child in get_children():
		if child.get_child(0).name == "MUSIC":
			child.volume_db = usable_music_volume


var sfx_volume : int = 100
var usable_sfx_volume : float = 0

func set_sfx_volume(volume: int):
	sfx_volume = volume
	
	if volume <= 0:
		usable_sfx_volume = -80
	else:
		usable_sfx_volume = 20 * log(float(sfx_volume) / 100)
	
	for child in get_children():
		if child.get_child(0).name == "SFX":
			child.volume_db = volume_dictionary[child.name.to_int()] + usable_sfx_volume
