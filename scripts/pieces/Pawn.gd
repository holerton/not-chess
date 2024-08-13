extends BasePiece
class_name Pawn
## Class for a Pawn. Extends BasePiece

## Creates a new Pawn. Accepts two parameters: color, coords. 
## Those parameters are used in parent's constructor.
## Also sets its textures.
func _init(color: String, coords: String):
	self.textures = [load("res://images/WPawn.svg") if color == "white"
	else load("res://images/BPawn.svg")]
	super(color, coords, "Pawn")

