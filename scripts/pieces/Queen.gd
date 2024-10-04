extends BasePiece
class_name Queen
## Class for a Queen. Extends BasePiece

## Creates a new Queen. Accepts two parameters: color, coords. 
## Those parameters are used in parent's constructor.
## Also sets its textures.
func _init(color: String, coords: Array):
	super(color, coords, "Queen")
