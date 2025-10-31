extends Control

var manager : GameManager

func _ready() -> void:
	manager = get_parent()
	
	$MusicText.visible = false
	
	load_ui()

func load_ui():
	$Coins.text = str(manager.coins)
	$CustomersRemaining.text = str(manager.remaining_customers)

func play_song(audio : AudioInfo):
	$MusicText.text = "Now playing " + audio.song_name + " by " + audio.artist_name + "..."
	$MusicText.visible = true
	$MusicText/Anim.play("fade")




func _on_next_day_pressed() -> void:
	GlobalData.start_day()

func _on_back_to_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/between_days_menu.tscn")
