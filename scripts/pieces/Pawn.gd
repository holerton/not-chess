extends BasePiece
class_name Pawn
## Class for a Pawn. Extends BasePiece

## Creates a new Pawn. Accepts two parameters: color, coords. 
## Those parameters are used in parent's constructor.
## Also sets its textures.
func _init(color: String, coords: Array):
	super(color, coords, "Pawn")
	self.terrain_weather_rules.clear()

