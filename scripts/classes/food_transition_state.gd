extends Resource  

class_name FoodTransitionState 

@export var action : int
@export var next_state : PlateState

func _init(_action: int = 0, _next_state: PlateState = null):
	action = _action
	next_state = _next_state
