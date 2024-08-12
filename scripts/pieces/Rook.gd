extends BasePiece
class_name Rook
## Class for a Rook. Extends BasePiece

## Creates a new Rook. Accepts three parameters: color, coords and position. 
## Those parameters are used in parent's constructor.
## Also sets its range, speed, damage, health, special_action and textures.
func _init(color: String, coords: String, position: Vector2):
	self.range = 1
	self.speed = 1
	self.damage = 1
	self.health = 2
	self.special_action = true
	self.textures = [load("res://images/WRookU.svg") if color == "white" else load("res://images/BRookU.svg"),
	load("res://images/WRook.svg") if color == "white" else load("res://images/BRook.svg")]
	super(color, coords, position, "Rook")
	

## Returns an Array with two Arrays. 
## First contains coordinates of Squares to be activated (Rooks position)
## Second contains coordinates of Squares to be attacked (Attackable squares without pawns)
func special_selection():
	var active_squares = [coords]
	var attacked_squares = find_attackable()
	for square in attacked_squares:
		if not Board.is_dark(square):
			attacked_squares.erase(square)
	return [active_squares, attacked_squares]
