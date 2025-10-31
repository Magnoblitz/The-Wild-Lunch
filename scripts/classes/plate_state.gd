extends Resource  
class_name PlateState

@export var image: Texture2D = null
@export var plated_image : Texture2D = null
@export var pan_images : Array[Texture2D] = [null, null, null, null] ##In this order: btm left, top left, top right, btm right

@export var next_states: Array[FoodTransitionState] = []
@export var id : int = -1
@export var cooking_time : float = 0
@export var burning_time : float = 0 ##How long does it take for this item to burn after being cooked in the oven
@export var trash_value : int = 0 ##How much money will be docked if you throw this food away
@export var main_plate_action : int = -1 ##If this item is dragged onto the main plate, what will it do?
