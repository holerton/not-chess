@tool
extends Pawn
class_name Queen

func _ready():
	self.texture = load("res://images/WQueen.svg") if Item_Color == "white" else load("res://images/BQueen.svg")

func _process(_delta):
	pass
