extends PieceContainer
class_name Board
## Class that represents a chessboard. Contains instances of Square 
## and a chessboard_map to easily find necessary information.

## Represents all the pieces on their respective places
static var chessboard_map = []

## Chessboard creation

## Sets up the Board.
func _ready():
	
	## Adding custom parameters
	board_width = Global.board_width
	board_height = Global.board_height
	square_x_size = 50
	square_y_size = 50
	
	## Creating an empty chessboard_map
	clear_chessboard_map()
	
	## Calling parent's _ready() method
	super()


## Resizes and clears chessboard_map
func clear_chessboard_map():
	
	chessboard_map.append([])
	chessboard_map[0].resize(board_width + 2)
	chessboard_map[0].fill("#") ## Bounds are marked with "#"
	
	for i in range(1, board_height + 1):
		chessboard_map.append([])
		chessboard_map[i].resize(board_width + 2)
		chessboard_map[i].fill(".")
		chessboard_map[i][0] = "#"
		chessboard_map[i][-1] = "#"
	
	chessboard_map.append([])
	chessboard_map[-1].resize(board_width + 2)
	chessboard_map[-1].fill("#")

## Sets up starting position
func basic_setup():
	var coords = int_to_coords([1, board_height])
	var white_king = add_piece("King", "white", coords)
	
	coords = int_to_coords([board_width, 1])
	var black_king = add_piece("King", "black", coords)
	return [white_king, black_king]

## Overriding parent's method, additionally marks a piece on the map
func add_piece(piece: String, color: String, pos: String) -> BasePiece:
	var new_piece = super(piece, color, pos)
	add_to_the_map(pos, new_piece.shortname)
	return new_piece

## Sets a piece on the square and marks it on a map
func set_piece(piece: BasePiece):
	get_node(piece.coords).add_child(piece)
	add_to_the_map(piece.coords, piece.shortname)

## Sets value to a selected position on a map
func add_to_the_map(pos: String, value: String):
	var xy = coords_to_int(pos)
	chessboard_map[xy[1]][xy[0]] = value

## Deletes a piece from Square and map
func clear_square(piece: BasePiece):
	var pos = piece.coords
	add_to_the_map(pos, ".")
	get_node(pos).remove_child(piece)
	piece.queue_free()

## Replaces piece_to with piece_from
func replace(piece_from: BasePiece, piece_to: BasePiece):
	clear_square(piece_to)
	traverse(piece_from, piece_to.coords)

## Getters and Checkers

## Accepts two parameters: pos - position on a map, dist - maximal distance
## Returns Array with coordinates of squares, distance to which 
## is less or equals to dist
static func get_neighbors(pos: String, dist: int) -> Array:
	var xy = coords_to_int(pos)
	var neighbors = []
	for i in range(xy[0] - dist, xy[0] + dist + 1):
		for j in range(xy[1] - dist, xy[1] + dist + 1):
			var coord = int_to_coords([i, j])
			if coord != pos and is_in_bounds(coord):
				neighbors.append(coord)
	return neighbors

## Returns map mark for a given position
static func get_square(pos: String):
	var xy = coords_to_int(pos)
	return chessboard_map[xy[1]][xy[0]]

## Returns two integers from position string
static func coords_to_int(pos: String):
	var dash_index = pos.find("-")
	var x = int(pos.substr(0, dash_index))
	var y = int(pos.substr(dash_index + 1, len(pos) - dash_index))
	return [x, y]

## Returns true if a square corresponding to a given position is dark
## False otherwise
static func is_dark(pos: String):
	var xy = coords_to_int(pos)
	return (xy[0] + xy[1]) % 2 != len(chessboard_map) % 2

## Returns true if given position is inside the map, false otherwise
static func is_in_bounds(pos: String):
	var width = len(chessboard_map[0]) - 1
	var height = len(chessboard_map) - 1
	var xy = coords_to_int(pos)
	return 0 < xy[0] and xy[0] < width and 0 < xy[1] and xy[1] < height

## Returns true if square corresponding to a given position is empty
## False otherwise
static func is_empty(pos: String):
	return get_square(pos) == '.'

## Accepts two parameters:
## color - white or black
## pos - coordinates of the square that needs to be checked
## Returns true if checked square contains the piece of opposing color.
## False otherwise
static func is_enemy(color: String, pos: String):
	var square = get_square(pos)
	return len(square) == 2 and square[0] != color

## Accepts two parameters:
## color - white or black
## pos - coordinates of the square that needs to be checked
## Returns true if checked square contains the piece of the same color.
## False otherwise
static func is_ally(color: String, pos: String):
	var square = get_square(pos)
	return len(square) == 2 and square[0] == color

## Accepts two parameters:
## color - white or black
## pos - coordinates of the square that needs to be checked
## Returns true if checked square contains the king of opposing color.
## False otherwise
static func is_enemy_king(color: String, pos: String) -> bool:
	return is_enemy(color, pos) and get_square(pos)[1] == 'K'

## Movement

## Accepts two coordinates on the map.
## Returns number of squares between them.
static func distance(from: String, to: String) -> int:
	var from_xy = coords_to_int(from)
	var to_xy = coords_to_int(to)
	var dist_x = abs(from_xy[0] - to_xy[0])
	var dist_y = abs(from_xy[1] - to_xy[1])
	return max(dist_x, dist_y)

## Moves a piece to a square, clears up previous square
func traverse(piece: BasePiece, to: String):
	if piece != null:
		var from = piece.coords
		if is_in_bounds(to) and is_empty(to):
			get_node(from).remove_child(piece)
			add_to_the_map(from, '.')
			get_node(to).add_child(piece)
			add_to_the_map(to, piece.shortname)
			piece.move(to)

## Active and Attacked Squares

## Changes is_active of given coordinates to opposite
func flip_active_squares(pos_array: Array):
	for pos in pos_array:
		get_node(pos).flip_activity()

## Changes is_attacked of given coordinates to opposite
func flip_attacked_squares(pos_array: Array):
	for pos in pos_array:
		get_node(pos).flip_attacked()
