extends GameMode

var auto_pieces = []

func _ready():
	super()
	var size = Global.board_height * Global.board_width 
	var num_of_zebras = size / 30 # 64 / 30 = 2
	var positions = [Board.int_to_coords([1, 2]),
	Board.int_to_coords([Global.board_width, Global.board_height - 1]), 
	Board.int_to_coords([Global.board_width - 3, Global.board_height]) ,
	Board.int_to_coords([4, 1]),
	Board.int_to_coords([Global.board_width - 1, Global.board_height]),
	Board.int_to_coords([2, 1]),
	Board.int_to_coords([1, 4]),
	Board.int_to_coords([Global.board_width, Global.board_height - 3]),
	Board.int_to_coords([3, 2]),
	Board.int_to_coords([Global.board_width - 2, Global.board_height - 1]),
	Board.int_to_coords([Global.board_width - 1, Global.board_height - 2]),
	Board.int_to_coords([2, 3]),
	Board.int_to_coords([6, 1]),
	Board.int_to_coords([Global.board_width - 5, Global.board_height])
	]
	for i in range(num_of_zebras) :
		auto_pieces.append(Zebra.new("neutral", positions[i]))
		$ChessboardRect/Chessboard.set_piece(auto_pieces[-1])

func end_turn():
	for piece in auto_pieces:
		var pos = piece.move_in_direction()
		$ChessboardRect/Chessboard.traverse(piece, pos)
	super()
