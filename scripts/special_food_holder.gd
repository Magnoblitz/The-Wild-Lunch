extends FoodHolder
class_name SpecialFoodHolder

@export var allowed_food : Array[PlateState]

func can_add_food(food : PlateState) -> bool:
	if plate_state != empty_plate_state:
		return false
	
	for item in allowed_food:
		if item == food:
			return true
	return false
	
func add_food(food : PlateState):
	plate_state = food
	$Food.texture = plate_state.image
