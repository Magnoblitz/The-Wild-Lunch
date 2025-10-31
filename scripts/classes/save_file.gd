extends Resource
class_name SaveFile

var player_name : String = "Namey McName"
var male : bool = true
var coins : int = 0
var day : int = 1
var customers_served : int = 0
var food_served : Array[Vector2i] = []
var unlocked_food : Array[String] = [ "Rotgut" ]
var remaining_tutorials : Array[String] = [ "first", "cooking", "pan and hotsauce", "last pans" ]

func _init(_player_name : String = "Namey McName", _male : bool = true):
	player_name = _player_name
	male = _male
