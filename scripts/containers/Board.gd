extends PieceContainer
class_name Board
## Class that represents a chessboard. Contains instances of Square 
## and a chessboard_map to easily find necessary information.

## Emitted when user selects a piece on a chessboard
signal existing_piece_selected(piece)

## Emitted when user attacks a piece on a chessboard
signal piece_attacked(other: BasePiece)

## Emitted when user selects an empty square
signal empty_square_selected(pos: String)

## Represents all the pieces on their respective places
static var chessboard_map = []

## Chessboard creation

## Sets up the Board.
func _ready():
	
	## Adding custom parameters
	board_width = 8
	board_height = 8
	square_x_size = 50
	square_y_size = 50
	
	## Creating an empty chessboard_map
	clear_chessboard_map()
	
	## Calling parent's _ready() method
	super()
	
	## Setting the action of the Squares
	var squares = get_children()
	for square in squares:
		square.set_action(func():
			
			## If the square is active AND empty, emits empty_square_selected
			## If the square is active AND not empty, emits existing_piece_selected  
			if square.is_active:
				var piece = square.get_piece()
				if piece == null:
					empty_square_selected.emit(square.name)
				else:
					existing_piece_selected.emit(piece)
			# If the square is attacked, emits piece_attacked
			elif square.is_attacked:
				piece_attacked.emit(square.get_child(1))
				)

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
	var white_king = add_piece("King", "white", "81")
	var black_king = add_piece("King", "black", "18")
	return [white_king, black_king]

## Overriding parent's method, additionally marks a piece on the map
func add_piece(piece: String, color: String, pos: String) -> BasePiece:
	var new_piece = super(piece, color, pos)
	add_to_the_map(pos, color[0] + piece[0])
	return new_piece

## Sets a piece on the square and marks it on a map
func set_piece(piece: BasePiece):
	get_node(piece.coords).add_child(piece)
	add_to_the_map(piece.coords, piece.shortname)

## Sets value to a selected position on a map
func add_to_the_map(pos: String, value: String):
	chessboard_map[int(pos[0])][int(pos[1])] = value

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

## Accepts one parameter: pos - position on a map
## Returns Array with coordinates of neighbors of said position
static func get_neighbors(pos: String) -> Array:
	var x_coord = int(pos[0])
	var y_coord = int(pos[1])
	var neighbors = []
	for i in range(x_coord - 1, x_coord + 2):
		for j in range(y_coord - 1, y_coord + 2):
			var coord = str(i) + str(j)
			if coord != pos and is_in_bounds(coord):
				neighbors.append(coord)
	return neighbors

## Returns map mark for a given position
static func get_square(pos: String):
	return chessboard_map[int(pos[0])][int(pos[1])]

## Returns true if a square corresponding to a given position is dark
## False otherwise
static func is_dark(pos: String):
	return (int(pos[0]) + int(pos[1])) % 2

## Returns true if given position is inside the map, false otherwise
static func is_in_bounds(pos: String):
	return 10 < int(pos) and int(pos) < 89

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
	if from == to:
		return 0
	var x = int(from[0])
	var y = int(from[1])
	 
	var neighbors_queue = []
	neighbors_queue.append([from, 0])
	var visited = []
	for i in 10:
		visited.append([])
		for j in 10:
			visited[i].append(false)
	visited[x][y] = true
	
	while not neighbors_queue.is_empty():
		var square = neighbors_queue.pop_front()
		var neighbors = get_neighbors(square[0])
		square[1] += 1
		for elem in neighbors:
			x = int(elem[0])
			y = int(elem[1])
			if elem == to:
				return square[1]
			if not visited[x][y]:
				neighbors_queue.append([elem, square[1]])
				visited[x][y] = true

	## Returns -1 if either of squares is unreachable
	return -1

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
