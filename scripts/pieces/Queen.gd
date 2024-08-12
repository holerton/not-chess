extends BasePiece
class_name Queen
## Class for a Queen. Extends BasePiece

## Creates a new Queen. Accepts three parameters: color, coords and position. 
## Those parameters are used in parent's constructor.
## Also sets its textures.
func _init(color: String, coords: String, position: Vector2):
	self.textures = [load("res://images/WQueen.svg") if color == "white"
	else load("res://images/BQueen.svg")]
	super(color, coords, position, "Queen")
