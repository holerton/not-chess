extends GameMode

var auto_pieces = []

func _ready():
	super()
	var positions = ["1-2", "2-1", 
	str(Global.board_width) + "-" + str(Global.board_height - 1),
	str(Global.board_width - 1) + "-"  + str(Global.board_height)
	]
	for pos in positions:
		auto_pieces.append(Zebra.new("neutral", pos))
		$ChessboardRect/Chessboard.set_piece(auto_pieces[-1])

func end_turn():
	for piece in auto_pieces:
		var pos = piece.auto_move()
		$ChessboardRect/Chessboard.traverse(piece, pos)
	super()
