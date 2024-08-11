@tool
extends PieceContainer
class_name Board

signal existing_piece_selected(piece)
signal piece_moved
signal piece_added
signal piece_attacked(other: Pawn)

static var chessboard = []

func get_chosen_piece():
	return get_node("../..").get_chosen_piece()

func _ready():
	empty_chessboard()
	super()
	var squares = get_children()
	for square in squares:
		square.set_action(func(): 
			if square.is_active:
				if square.is_empty():
					var piece = get_chosen_piece()
					var pos2 = square.name
					var message = traverse(piece, pos2)
					message.emit()
				else:
					var piece = square.get_child(1)
					existing_piece_selected.emit(piece)
			elif square.is_attacked:
				piece_attacked.emit(square.get_child(1))
				)
		
#func action():
	#if is_active:
		#flip_activity()
		#if is_empty():
			#put_chosen_piece()
		#else:
			#set_chosen_piece(get_child(1))
	#elif is_attacked:
		#flip_attacked()

func empty_chessboard():
	chessboard.append([])
	chessboard[0].resize(Board_X_Size + 2)
	chessboard[0].fill("#")
	for i in range(1, Board_Y_Size + 1):
		chessboard.append([])
		chessboard[i].resize(Board_X_Size + 2)
		chessboard[i].fill(".")
		chessboard[i][0] = "#"
		chessboard[i][-1] = "#"
	chessboard.append([])
	chessboard[-1].resize(Board_X_Size + 2)
	chessboard[-1].fill("#")

func basic_setup():
	var white_king = add_piece("King", "white", "81")
	var black_king = add_piece("King", "black", "18")
	return [white_king, black_king]
	
func add_piece(Piece_Name: String, color: String, pos: String) -> Pawn:
	var piece = super(Piece_Name, color, pos)
	set_square(pos, color[0] + Piece_Name[0])
	return piece
	
static func print_chessboard():
	for line in chessboard:
		print(line)

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

static func get_square(pos: String):
	return chessboard[int(pos[0])][int(pos[1])]

static func set_square(pos: String, value: String):
	chessboard[int(pos[0])][int(pos[1])] = value

static func is_empty(pos: String):
	return get_square(pos) == '.'

static func is_in_bounds(pos: String):
	return get_square(pos) != '#'

static func is_enemy(color: String, pos: String):
	var square = get_square(pos)
	return len(square) == 2 and square[0] != color

static func is_ally(color: String, pos: String):
	var square = get_square(pos)
	return len(square) == 2 and square[0] == color

static func distance(pos1: String, pos2: String) -> int:
	if pos1 == pos2:
		return 0
	var dist = 0
	var neighbors_queue = []
	neighbors_queue.append([pos1, 0])
	var visited = []
	for i in 10:
		visited.append([])
		for j in 10:
			visited[i].append(false)
	visited[int(pos1[0])][int(pos1[1])] = true
	while true:
		var square = neighbors_queue.pop_front()
		var neighbors = get_neighbors(square[0])
		square[1] += 1
		for elem in neighbors:
			if elem == pos2:
				return square[1]
			if not visited[int(elem[0])][int(elem[1])]:
				neighbors_queue.append([elem, square[1]])
				visited[int(elem[0])][int(elem[1])] = true
	return -1

static func is_dark(pos: String):
	return (int(pos[0]) + int(pos[1])) % 2

func traverse(piece: Pawn, pos2: String) -> Signal:
	var resulting_signal: Signal = piece_added
	if piece != null:
		var pos1 = piece.Position
		if is_in_bounds(pos2) and is_empty(pos2):
			if len(pos1) == 2:
				get_node(pos1).remove_child(piece)
				set_square(pos1, '.')
				resulting_signal = piece_moved
			get_node(pos2).add_child(piece)
			set_square(pos2, piece.piece_name)
			piece.move(pos2)
	return resulting_signal

func flip_squares(pos_array: Array):
	var squares = []
	for pos in pos_array:
		get_node(pos).flip_activity()
		
func attack_squares(pos_array: Array):
	var squares = []
	for pos in pos_array:
		get_node(pos).flip_attacked()
		
func clear_square(piece: Pawn):
	var pos = piece.Position
	set_square(pos, ".")
	get_node(pos).remove_child(piece)
	piece.queue_free()
