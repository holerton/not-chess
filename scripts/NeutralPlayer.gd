extends Node
class_name NeutralPlayer

## Contains all neutral pieces
var pieces: Array

## Contains squares, where pieces can spawn
var spawn_squares: Array

## Limit of pieces
var limit: int

func _init(board: Board):
	self.limit = Global.board_height * Global.board_width / 25
	var get_next_coord = func(num):
		var mapped_num = (num - num % 2) / 2
		var x = mapped_num % (Global.board_width / 2)
		var y = mapped_num / (Global.board_width / 2)
		if num % 2:
			return [Global.board_width - x, Global.board_height - y]
		else:
			return [x + 1, y + 1]
	
	for num in range((Global.board_width ** 2) / 2):
		var coords = get_next_coord.call(num)
		if Board.is_dark(coords):
			spawn_squares.append(coords)
	
	for i in range(limit):
		var zebra = Zebra.new("n", [-1, -1])
		add_new_piece(board, zebra)

func move_piece(board: Board, piece: BasePiece):
	var route = []
	if piece.speed <= 0:
		piece.skip_turn()
	else:
		var pos = piece.move_to_dest(board)
		route = piece.get_route(board, pos)
	return route

func remove_piece(board: Board, piece: BasePiece):
	if piece in pieces:
		pieces.erase(piece)
		var new_piece = piece.clone()
		add_new_piece(board, new_piece)

func add_new_piece(board: Board, piece: BasePiece):
	while true:
		var square = spawn_squares[randi_range(0, len(spawn_squares) - 1)]
		var penalty = piece.calc_penalty(board.get_terrain(square),
		board.get_weather(square))
		if penalty < Global.MY_INF and board.is_empty(square):
			piece.coords = square
			pieces.append(piece)
			pieces[-1].set_destination(board)
			board.set_piece(pieces[-1])
			return

func check_arrival(board: Board, piece: BasePiece):
	if piece.coords == piece.dest:
		remove_piece(board, piece)
		return true
	return false
