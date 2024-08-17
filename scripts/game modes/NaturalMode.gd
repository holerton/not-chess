extends GameMode

var auto_pieces = []

func _ready():
	super()
	$ChessboardRect/Chessboard.randomize_terrain()
	var size = Global.board_height * Global.board_width 
	var num_of_zebras = min(size / 25, 16) # 64 / 25 = 2
	
	# two 4x4 squares: first in top left corner and second in bottom right corner
	var left_neighbors = Board.get_neighbors(Board.int_to_coords([0, 0]), 4)
	var right_neighbors = Board.get_neighbors(
	Board.int_to_coords([Global.board_width + 1, Global.board_height + 1]), 4)
	
	var positions = []
	var len = len(left_neighbors)
	for i in range(len):
		if Board.is_dark(left_neighbors[i]):
			positions.append(left_neighbors[i])
		if Board.is_dark(right_neighbors[len - i - 1]):
			positions.append(right_neighbors[len - i - 1])
	
	for i in range(num_of_zebras) :
		auto_pieces.append(Zebra.new("neutral", positions[i]))
		$ChessboardRect/Chessboard.set_piece(auto_pieces[-1])

func end_turn():
	for piece in auto_pieces:
		var pos = piece.move_in_direction()
		$ChessboardRect/Chessboard.traverse(piece, pos)
	super()
