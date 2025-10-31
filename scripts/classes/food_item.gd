extends Resource  

class_name FoodItem 

@export var name : String = ""
@export var internal_name : String = ""
@export var image : Texture2D = null
@export var id : int = -1

@export var price : float = 0

func _init(_name: String = "", _image: Texture2D = null, _id : int = -1, _price: int = 0):
	name = _name
	image = _image
	id = _id
	price = _price
