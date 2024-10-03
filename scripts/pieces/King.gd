extends BasePiece
class_name King
## Class for a King. Extends BasePiece

## Creates a new King. Accepts two parameters: color, coords. 
## Those parameters are used in parent's constructor.
## Also sets its textures.
func _init(color: String, coords: String): 
	super(color, coords, "King")
