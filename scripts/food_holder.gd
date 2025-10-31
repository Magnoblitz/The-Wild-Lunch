extends Node2D
class_name FoodHolder

@export var plate_state : PlateState
@export var empty_plate_state : PlateState

enum FoodDisplay { NORMAL, PLATED, PAN }
@export var food_display : FoodDisplay = FoodDisplay.NORMAL

func remove_item():
	plate_state = empty_plate_state

func drag_item():
	pass

func stop_drag_item():
	pass
