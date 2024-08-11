@tool
extends Pawn
class_name Bishop

func _ready():
	range = 2
	speed = 1
	damage = 1
	self.texture = load("res://images/WBishop.svg") if Item_Color == "white" else load("res://images/BBishop.svg")

func _process(_delta):
	pass
