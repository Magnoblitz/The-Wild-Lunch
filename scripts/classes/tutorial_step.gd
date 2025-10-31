extends Resource
class_name TutorialStep

@export var text : String = ""

@export var right : bool = false
@export var shaded_bg : bool = false
@export var light_position : Vector2 = Vector2(0, 0)
@export var light_size : float = 0.85

@export var moving_hand : bool = false
@export var hand_movement_pos1 : Vector2
@export var hand_movement_pos2 : Vector2
@export var hand_movement_speed : float = 1

@export var start_trigger : TutorialTrigger
@export var end_trigger : TutorialTrigger    #This triggers the tutorial screen to end (and possibly go to the next one)

@export var starting_actions : Array[TutorialAction] = []
@export var ending_actions : Array[TutorialAction] = []
