extends BasePiece
class_name Knight
## Class for a Knight. Extends BasePiece

## Creates a new Knight. Accepts three parameters: color, coords and position. 
## Those parameters are used in parents's constructor.
## Also sets it's range, speed, damage and textures.
func _init(color: String, coords: String, position: Vector2):
	self.range = 1
	self.speed = 2
	self.damage = 1
	self.textures = [load("res://images/WKnight.svg") if color == "white"
	else load("res://images/BKnight.svg")]
	super(color, coords, position, "Night")
