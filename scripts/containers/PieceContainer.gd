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

## Stores current active chessboard squares
var active_squares: Array = []

## Stores current attacked chessboard squares
var attacked_squares: Array = []

## Creates an empty container with set parameters. If width or height are negative, returns. 
func _ready() -> void:
	
	if board_width < 0 or board_height < 0:
		return
		
	add_theme_constant_override("h_separation", 0)
	add_theme_constant_override("v_separation", 0)
	
	set_custom_minimum_size(Vector2(board_width * square_x_size,
	board_height * square_y_size))
	
	var is_black = func(x, y):
		return "Black" if board_width % 2 != (x + y) % 2 else "White"

	for i in range(board_height):
		for j in range(board_width):
			var type = is_black.call(i, j) 
			var size = Vector2(square_x_size, square_y_size)
			var reciever = get_node("../..")._on_square_clicked
			var new_square = Square.new(type, size, reciever)
			add_child(new_square)

## Creates a piece, sets it on the chosen square and returs it
func add_piece(piece: String, color: String, pos: Array) -> BasePiece:
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
	get_square(pos).add_child(new_piece)
	return new_piece

func flip_highlighted():
	for pos in self.active_squares:
		get_square(pos).flip_activity()
	for pos in self.attacked_squares:
		get_square(pos).flip_attacked()

func clear_highlighted():
	flip_highlighted()
	self.active_squares.clear()
	self.attacked_squares.clear()
	
func set_active_squares(active_squares: Array):
	self.active_squares = active_squares

func set_attacked_squares(attacked_squares: Array):
	self.attacked_squares = attacked_squares

func get_square(pos: Array) -> Square:
	return get_child((pos[0] - 1) + (pos[1] - 1) * board_width)
