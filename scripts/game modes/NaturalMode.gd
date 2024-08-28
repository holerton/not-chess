extends GameMode

var auto_pieces = []
var season_counter = 0
var seasons: PieChart
var terrain_map: Dictionary
var climate: Climate

func _ready():
	super()
	$RightRect/PieceSpawner.anchors_preset = PRESET_CENTER_TOP
	self.terrain_map = $ChessboardRect/Chessboard.randomize_terrain()
	self.climate = Climate.new(self.terrain_map)
	$ChessboardRect/Chessboard.flip_weather(self.climate.initial_climate())
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
	
	self.seasons = PieChart.new(Vector2($RightRect.size[0], $RightRect.size[0]))
	$RightRect.add_child(seasons)
	seasons.layout_mode = 1
	seasons.anchors_preset = PRESET_CENTER_BOTTOM
	seasons.change_month()
	
	start_turn()

func end_turn():
	for piece in auto_pieces:
		if piece.speed > 0:
			var pos = piece.move_in_direction($ChessboardRect/Chessboard)
			$ChessboardRect/Chessboard.traverse(piece, pos)
		else:
			piece.skip_turn()
	super()
	season_counter = (season_counter + 1) % 32
	if season_counter % 2 == 0:
		self.seasons.change_month()
		var cleared_squares = $ChessboardRect/Chessboard.flip_weather(
			self.climate.calc_climate(season_counter / 2)
		)
		for square in cleared_squares:
			var piece = $ChessboardRect/Chessboard.get_piece(square)
			if piece.name != "Pawn" and piece.name != "King":
				piece.get_damage(piece.health)
				$ChessboardRect/Chessboard.clear_square(piece)
				if players[0].has_piece(piece):
					players[0].remove_if_dead(piece)
				elif players[1].has_piece(piece):
					players[1].remove_if_dead(piece)
				else:
					auto_pieces.erase(piece)
		
