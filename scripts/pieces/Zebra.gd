extends AutoPiece
class_name Zebra
## Class for a Zebra. Extends AutoPiece

## Creates a new Zebra. Accepts three parameters: color, coords and position. 
## Those parameters are used in parent's constructor.
## Also sets its textures.
func _init(color: String, coords: String):
	self.textures = [load("res://images/Zebra.svg")]
	super(color, coords, "Zebra")
	self.speed = 1
