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
	var white_king = add_piece("King", "w", [1, board_height])
	var black_king = add_piece("King", "b", [board_width, 1])
	return [white_king, black_king]

## Overriding parent's method, additionally marks a piece on the map
func add_piece(piece: String, color: String, pos: Array) -> BasePiece:
	var new_piece = super(piece, color, pos)
	add_to_the_map(pos, new_piece.shortname)
	return new_piece

## Sets a piece on the square and marks it on a map
func set_piece(piece: BasePiece):
	get_square(piece.coords).add_child(piece)
	add_to_the_map(piece.coords, piece.shortname)

## Sets value to a selected position on a map
func add_to_the_map(pos: Array, value: String):
	chessboard_map[pos[1]][pos[0]] = value

## Deletes a piece from Square and map
func clear_square(piece: BasePiece):
	add_to_the_map(piece.coords, ".")
	get_square(piece.coords).remove_child(piece)
	piece.queue_free()

## Getters and Checkers

## Accepts two parameters: pos - position on a map, dist - maximal distance
## Returns Array with coordinates of squares, distance to which 
## is less or equals to dist
static func get_neighbors(pos: Array, dist: int = 1) -> Array:
	var neighbors = []
	for i in range(pos[0] - dist, pos[0] + dist + 1):
		for j in range(pos[1] - dist, pos[1] + dist + 1):
			if [i, j] != pos and is_in_bounds([i, j]):
				neighbors.append([i, j])
	return neighbors

## Returns map mark for a given position
static func get_mark(pos: Array):
	return chessboard_map[pos[1]][pos[0]]

## Returns true if a square corresponding to a given position is dark
## False otherwise
static func is_dark(pos: Array) -> bool:
	return (pos[0] + pos[1]) % 2 != len(chessboard_map) % 2

## Returns true if given position is inside the map, false otherwise
static func is_in_bounds(pos: Array) -> bool:
	return 0 < pos[0] and pos[0] <= Global.board_width and \
	0 < pos[1] and pos[1] <= Global.board_height

## Returns true if square corresponding to a given position is empty
## False otherwise
static func is_empty(pos: Array) -> bool:
	return get_mark(pos) == '.'

## Returns 1, if colors are from the same team, 0 if neutral, -1 if enemies
static func get_status(col1: String, col2: String) -> int:
	return Global.teams.find_key(col1) * Global.teams.find_key(col2)

## Accepts two parameters:
## color - white or black
## pos - coordinates of the square that needs to be checked
## Returns true if checked square contains the piece of opposing color.
## False otherwise
static func is_enemy(color: String, pos: Array) -> bool:
	var square = get_mark(pos)
	if len(square) == 2:
		return get_status(square[0], color) == -1
	return false

## Accepts two parameters:
## color - white or black
## pos - coordinates of the square that needs to be checked
## Returns true if checked square contains the piece of the same color.
## False otherwise
static func is_ally(color: String, pos: Array) -> bool:
	var square = get_mark(pos)
	if len(square) == 2:
		return get_status(square[0], color) == 1
	return false

## Accepts two parameters:
## color - white or black
## pos - coordinates of the square that needs to be checked
## Returns true if checked square contains the piece of neutral color.
## False otherwise
static func is_neutral(color: String, pos: Array) -> bool:
	var square = get_mark(pos)
	if len(square) == 2:
		return get_status(square[0], color) == 0
	return false

## Accepts two parameters:
## color - white or black
## pos - coordinates of the square that needs to be checked
## Returns true if checked square contains the king of opposing color.
## False otherwise
static func is_enemy_king(color: String, pos: Array) -> bool:
	return is_enemy(color, pos) and get_mark(pos)[1] == 'K'

## Movement

## Accepts two coordinates on the map.
## Returns number of squares between them.
static func distance(from: Array, to: Array) -> int:
	var dist_x = abs(from[0] - to[0])
	var dist_y = abs(from[1] - to[1])
	return max(dist_x, dist_y)

## Moves a piece to a square, clears up previous square
func traverse(piece: BasePiece, to: Array):
	if piece != null:
		if is_in_bounds(to) and is_empty(to):
			var loc_from = Vector2((piece.coords[0] - 0.5) * Global.tile_size,
			(piece.coords[1] - 0.5) * Global.tile_size)
			get_square(piece.coords).remove_child(piece)
			piece.set_position(loc_from)
			add_child(piece)
			
			add_to_the_map(piece.coords, '.')
			add_to_the_map(to, piece.shortname)
			piece.move(to, self)

func flip_weather(weather_dict: Dictionary):
	var cleared_squares = []
	for weather in weather_dict:
		for square in weather_dict[weather]:
			if get_terrain(square) == "Water" and get_weather(square) == "Snow":
				if not is_empty(square):
					cleared_squares.append(square)
			get_square(square).flip_weather(weather)
	return cleared_squares

func set_terrains(terrain_map: Dictionary):
	for terrain in terrain_map:
		for square in terrain_map[terrain]:
			get_square(square).set_terrain(terrain)

func get_terrain(pos: Array):
	return get_square(pos).terrain

func get_weather(pos: Array):
	return get_square(pos).weather

func get_piece(pos: Array):
	return get_square(pos).get_piece()
