@tool
extends Pawn
class_name Rook

func _ready():
	range = 1
	speed = 1
	damage = 1
	health = 2
	texture = load("res://images/WRook.svg") if Item_Color == "white" else load("res://images/BRook.svg")

func _process(_delta):
	if health == 1:
		texture = load("res://images/WRookU.svg") if Item_Color == "white" else load("res://images/BRookU.svg")
