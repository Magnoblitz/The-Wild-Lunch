extends Resource
class_name TutorialTrigger

enum Type { GAME_STARTS, CUSTOMER_ARRIVES, FOOD_SERVED, TIME_OUT, LAST_TUTORIAL_DONE, CLICK_NEXT, MONEY_COLLECTED, AUTO_END, CUSTOMER_FULLY_SERVED, ACTION_RECEIVED, ITEM_ADDED_TO_PAN, ITEM_DONE_COOKING, ITEM_ON_SMALL_PLATE, ITEM_TRASHED, CUSTOMER_LEAVES }
@export var type : Type = Type.CUSTOMER_ARRIVES
@export var any : bool = true
@export var specification_string : String = ""
@export var specification_float : float = 0
@export var specification_int : int = -1
