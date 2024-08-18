extends PieceContainer
class_name Board
## Class that represents a chessboard. Contains instances of Square 
## and a chessboard_map to easily find necessary information.

## Represents all the pieces on their respective places
static var chessboard_map = []
var gen = RandomNumberGenerator.new()
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
	var square = get_node(pos)
	add_to_the_map(pos, ".")
	var tween = get_tree().create_tween()
	tween.tween_property(piece, "modulate", Color.RED, 0.15)
	tween.tween_property(piece, "scale", Vector2(), 0.15)
	tween.tween_callback(square.remove_child.bind(piece))
	tween.tween_callback(piece.queue_free)
	#get_node(pos).remove_child(piece)
	#piece.queue_free()

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

## Returns 1, if colors are from the same team, 0 if neutral, -1 if enemies
static func get_status(col1: String, col2: String):
	return Global.teams.find_key(col1) * Global.teams.find_key(col2)

## Accepts two parameters:
## color - white or black
## pos - coordinates of the square that needs to be checked
## Returns true if checked square contains the piece of opposing color.
## False otherwise
static func is_enemy(color: String, pos: String) -> bool:
	var square = get_square(pos)
	if len(square) == 2:
		return get_status(square[0], color) == -1
	return false

## Accepts two parameters:
## color - white or black
## pos - coordinates of the square that needs to be checked
## Returns true if checked square contains the piece of the same color.
## False otherwise
static func is_ally(color: String, pos: String) -> bool:
	var square = get_square(pos)
	if len(square) == 2:
		return get_status(square[0], color) == 1
	return false

## Accepts two parameters:
## color - white or black
## pos - coordinates of the square that needs to be checked
## Returns true if checked square contains the piece of neutral color.
## False otherwise
static func is_neutral(color: String, pos: String) -> bool:
	var square = get_square(pos)
	if len(square) == 2:
		return get_status(square[0], color) == 0
	return false

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
			animated_move(piece, to)
			add_to_the_map(from, '.')
			add_to_the_map(to, piece.shortname)
			piece.move(to)

## Calculates coordinates and makes an animation for the piece
func animated_move(piece: BasePiece, to: String):
	var square_from = piece.get_parent()
	var square_to = get_node(to)
	
	var xy_from = coords_to_int(piece.coords)
	var xy_to = coords_to_int(to)
	
	var loc_from = Vector2((xy_from[0] - 0.5) * square_x_size,
	(xy_from[1] - 0.5) * square_y_size)
	var loc_to = Vector2((xy_to[0] - 0.5) * square_x_size,
	(xy_to[1] - 0.5) * square_y_size)
	
	var center = Vector2(square_x_size / 2, square_y_size / 2)
	
	var tween = get_tree().create_tween()
	tween.tween_callback(square_from.remove_child.bind(piece))
	tween.tween_callback(piece.set_position.bind(loc_from))
	tween.tween_callback(add_child.bind(piece))
	tween.tween_property(piece, "position", loc_to, 0.25)
	tween.tween_callback(remove_child.bind(piece))
	tween.tween_callback(piece.set_position.bind(center))
	tween.tween_callback(square_to.add_child.bind(piece))

## Active and Attacked Squares

## Changes is_active of given coordinates to opposite
func flip_active_squares(pos_array: Array):
	for pos in pos_array:
		get_node(pos).flip_activity()

## Changes is_attacked of given coordinates to opposite
func flip_attacked_squares(pos_array: Array):
	for pos in pos_array:
		get_node(pos).flip_attacked()

func get_visited_array(pos: String):
	var xy = coords_to_int(pos)
	var visited = []
	
	for i in range(board_width + 2):
		visited.append([])
		visited[-1].resize(board_width + 2)
		visited[-1].fill(false)
	visited[xy[1]][xy[0]] = true
	return visited
	

func get_blocks(k_avg: float, k_var: float, total: int):
	var list = []
	while total:
		var new_num = max(min(int(gen.randfn(k_avg, k_var)), total), 1)
		total -= new_num
		list.append(new_num)
	return list

func has_enough_space(pos: String, size: int):
	var square = get_node(pos)
	if square.terrain != "White" and square.terrain != "Black":
		return 0
	
	var visited = get_visited_array(pos)
	
	var square_queue = [pos]
	var free_space = 1
	while not square_queue.is_empty() and free_space < size:
		var new_pos = square_queue.pop_front()
		var neighbors = get_neighbors(new_pos, 1)
		for neighbor in neighbors:
			var xy = coords_to_int(neighbor)
			square = get_node(neighbor)
			if not visited[xy[1]][xy[0]]:
				if square.terrain == "White" or square.terrain == "Black":
					visited[xy[1]][xy[0]] = true
					square_queue.append(neighbor)
					free_space += 1
					if free_space == size:
						break
	return free_space >= size

func put_a_block(block_size: int, terrain: String):
	var has_space = false
	var new_square
	while not has_space:
		new_square = Board.int_to_coords([gen.randi_range(1, board_width), 
		gen.randi_range(1, board_height)])
		has_space = has_enough_space(new_square, block_size)
	
	var visited = get_visited_array(new_square)
	var square_queue = [new_square]
	get_node(new_square).set_terrain(terrain) 
	block_size -= 1
	while block_size > 0:
		var new_pos = square_queue.pop_front()
		var neighbors = get_neighbors(new_pos, 1)
		for neighbor in neighbors:
			var xy = coords_to_int(neighbor)
			var square = get_node(neighbor)
			if not visited[xy[1]][xy[0]]:
				if square.terrain == "White" or square.terrain == "Black":
					visited[xy[1]][xy[0]] = true
					square_queue.append(neighbor)
					get_node(neighbor).set_terrain(terrain)
					block_size -= 1
					if block_size == 0:
						break
	

func randomize_terrain():
	var terrains = ["Plain", "Forest", "Water", "Desert", "Marsh", "Mountain"]
	var board_size = board_height * board_width
	
	var k_min = [log(board_size) - 2, log(board_size) - 3, log(board_size) - 3,
	log(board_size) - 4, log(board_size) - 4, log(board_size) - 4]
	var k_max = [board_size / 16, board_size / 10, board_size / 10,
	board_size / 32, board_size / 32, board_size / 32, board_size / 32]
	
	var weights = [10, 17, 22, 25, 28, 30]
	var squares = get_children()
	var total_squares = [0, 0, 0, 0, 0, 0]
	for i in range(board_size):
		var rand_num = gen.randi_range(0, 29)
		for j in range(6):
			if rand_num < weights[j]:
				total_squares[j] += 1
				break
	
	var blocks = []
	var sum_len = 0
	for i in range(6):
		var k_avg = (k_min[i] + k_max[i]) / 2
		var k_var = (k_max[i] - k_avg) / 3
		blocks.append(get_blocks(k_avg, k_var, total_squares[i]))
		sum_len += len(blocks[-1])
		print(blocks[-1])
	
	while sum_len:
		var terrain_type = gen.randi_range(0, 5)
		if not blocks[terrain_type].is_empty():
			put_a_block(blocks[terrain_type].pop_front(), terrains[terrain_type])
			sum_len -= 1
	
