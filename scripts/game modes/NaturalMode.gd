extends GameMode

var auto_pieces = []

func _ready():
	super()
	var positions = [Board.int_to_coords([1, 2]), Board.int_to_coords([2, 1]), 
	Board.int_to_coords([Global.board_width, Global.board_height - 1]),
	Board.int_to_coords([Global.board_width - 1, Global.board_height])
	]
	for pos in positions:
		auto_pieces.append(Zebra.new("neutral", pos))
		$ChessboardRect/Chessboard.set_piece(auto_pieces[-1])

func end_turn():
	for piece in auto_pieces:
		var pos = piece.auto_move()
		$ChessboardRect/Chessboard.traverse(piece, pos)
	super()
