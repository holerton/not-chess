extends BasePiece
class_name Bishop
## Class for a Bishop. Extends BasePiece

## Creates a new Bishop. Accepts three parameters: color, coords and position. 
## Those parameters are used in parent's constructor.
## Also sets it's range, speed, damage and textures.
func _init(color: String, coords: String, position: Vector2):
	self.range = 2
	self.speed = 1
	self.damage = 1
	self.textures = [load("res://images/WBishop.svg") if color == "white"
	else load("res://images/BBishop.svg")]
	super(color, coords, position, "Bishop")
