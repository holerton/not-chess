extends FlowContainer
class_name PieceContainer
## Class for creating black-and-white boards and storing pieces.
## Parent class for Board, PieceSpawner, extends FlowContainer. 

## Defines, how many squares wide a container is
var board_width: int = 0

## Defines, how many squares high a container is
var board_height: int = 0

## Defines the x component of the size of the square
var square_x_size: int = 0

## Defines the y component of the size of the square
var square_y_size: int = 0

## Creates an empty container with set parameters. If width or height are negative, returns. 
func _ready() -> void:
	
	if board_width < 0 or board_height < 0:
		return

	set_custom_minimum_size(Vector2(board_width * square_x_size, board_height * square_y_size))
	
	for i in range(board_height):
		for j in range(board_width):
			var dark = (i + j) % 2
			var size = Vector2(square_x_size, square_y_size)
			var name = str(i + 1) + str(j + 1)
			var new_square = Square.new(dark, size, name)
			add_child(new_square)

## Creates a piece, sets it on the chosen square and returs it
func add_piece(piece: String, color: String, pos: String) -> BasePiece:
	var new_piece: BasePiece
	var center = Vector2(square_x_size / 2, square_y_size / 2)
	match piece:
		"Pawn":
			new_piece = Pawn.new(color, pos, center)
		"King":
			new_piece = King.new(color, pos, center)
		"Queen":
			new_piece = Queen.new(color, pos, center)
		"Night":
			new_piece = Knight.new(color, pos, center)
		"Rook":
			new_piece = Rook.new(color, pos, center)
		"Bishop":
			new_piece = Bishop.new(color, pos, center)
	get_node(pos).add_child(new_piece)
	return new_piece
