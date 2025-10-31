extends Resource
class_name CustomerInfo

@export var name : String = "John Doe" ##The customer's real name, ex: John Doe or Jane Doe
@export var role : String = "Farmer" ##The customer's "role" in the town such as farmer or prospector
@export var male : bool = true

enum CustomerType { NORMAL, OUTLAW }
@export var customer_type : CustomerType

@export var happy_image : Texture2D
@export var unhappy_image : Texture2D
@export var angry_image : Texture2D
