extends BasePiece
class_name Pawn
## Class for a Pawn. Extends BasePiece

## Creates a new Pawn. Accepts three parameters: color, coords and position. 
## Those parameters are used in parent's constructor.
## Also sets its textures.
func _init(color: String, coords: String, position: Vector2):
	self.textures = [load("res://images/WPawn.svg") if color == "white"
	else load("res://images/BPawn.svg")]
	super(color, coords, position, "Pawn")

