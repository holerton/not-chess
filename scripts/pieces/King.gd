@tool
extends Pawn
class_name King

func _ready():
	self.texture = load("res://images/WKing.svg") if Item_Color == "white" else load("res://images/BKing.svg")

func _process(_delta):
	pass
