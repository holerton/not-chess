@tool
extends Pawn
class_name Knight

func _ready():
	range = 1
	speed = 2
	damage = 1
	self.texture = load("res://images/WKnight.svg") if Item_Color == "white" else load("res://images/BKnight.svg")

func _process(_delta):
	pass
