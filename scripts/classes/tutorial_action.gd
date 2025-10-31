extends Resource
class_name TutorialAction

enum Type { SPAWN_CUSTOMER, ENABLE_FOOD, START_NORMAL_GAME, TOGGLE_DRAGGING, TOGGLE_BURNING, TOGGLE_TRASH }
@export var type : Type
@export var customer_info : CustomerInfo
@export var int1 : int
@export var order : Array[int]
@export var bool1 : bool
@export var string1 : String
