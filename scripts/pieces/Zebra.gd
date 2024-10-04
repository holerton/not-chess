extends AutoPiece
class_name Zebra
## Class for a Zebra. Extends AutoPiece

## Creates a new Zebra. Accepts three parameters: color, coords and position. 
## Those parameters are used in parent's constructor.
## Also sets its textures.
func _init(color: String, coords: Array):
	self.speed = 1
	self.terrain_weather_rules["Snow"] = 0
	super(color, coords, "Zebra")
