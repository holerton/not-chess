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
		
	add_theme_constant_override("h_separation", 0)
	add_theme_constant_override("v_separation", 0)
	
	set_custom_minimum_size(Vector2(board_width * square_x_size, board_height * square_y_size))
	
	var is_dark = func(x, y):
		return board_width % 2 != (x + y) % 2

	for i in range(board_height):
		for j in range(board_width):
			var dark = is_dark.call(i, j)
			var size = Vector2(square_x_size, square_y_size)
			var name = int_to_coords([j + 1, i + 1])
			var reciever = get_node("../..")._on_square_clicked
			var new_square = Square.new(dark, size, name, reciever)
			add_child(new_square)

## Returns coordinate string from two integers
static func int_to_coords(coords: Array):
	return str(coords[0]) + "-" + str(coords[1])

## Creates a piece, sets it on the chosen square and returs it
func add_piece(piece: String, color: String, pos: String) -> BasePiece:
	var new_piece: BasePiece
	match piece:
		"Pawn":
			new_piece = Pawn.new(color, pos)
		"King":
			new_piece = King.new(color, pos)
		"Queen":
			new_piece = Queen.new(color, pos)
		"Night":
			new_piece = Knight.new(color, pos)
		"Rook":
			new_piece = Rook.new(color, pos)
		"Bishop":
			new_piece = Bishop.new(color, pos)
	get_node(pos).add_child(new_piece)
	return new_piece
