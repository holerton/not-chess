extends BasePiece
class_name King
## Class for a King. Extends BasePiece

## Creates a new King. Accepts three parameters: color, coords and position. 
## Those parameters are used in parent's constructor.
## Also sets its textures.
func _init(color: String, coords: String, position: Vector2): 
	self.textures = [load("res://images/WKing.svg") if color == "white"
	else load("res://images/BKing.svg")]
	super(color, coords, position, "King")

func _process(_delta):
	pass
