extends BasePiece
class_name Rook
## Class for a Rook. Extends BasePiece

## Creates a new Rook. Accepts three parameters: color, coords. 
## Those parameters are used in parent's constructor.
## Also sets its range, speed, damage, health, special_action and textures.
func _init(color: String, coords: String):
	self.range = 1
	self.speed = 1
	self.damage = 1
	self.health = 2
	self.special_action = true
	self.terrain_weather_rules["Desert"] = self.speed
	super(color, coords, "Rook")
	

## Returns an Array with two Arrays. 
## First contains coordinates of Squares to be activated (Rooks position)
## Second contains coordinates of Squares to be attacked (Attackable squares without pawns)
func special_selection(board: Board, attacked_piece: BasePiece):
	var active_squares = [coords]
	var all_attacked_squares = find_attackable(board)
	var attacked_squares = []
	for square in all_attacked_squares:
		if Board.is_dark(square) and square != attacked_piece.coords:
			attacked_squares.append(square)
	return [active_squares, attacked_squares]
