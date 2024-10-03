extends GameMode

var auto_pieces = []
var season_counter = 0
var seasons: PieChart
var terrain_map: Dictionary
var climate: Climate

func _ready():
	super()
	spawner.anchors_preset = PRESET_CENTER_TOP
	self.terrain_map = board.randomize_terrain()
	self.climate = Climate.new(self.terrain_map)
	board.flip_weather(self.climate.initial_climate())
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
		auto_pieces.append(Zebra.new("n", positions[i]))
		board.set_piece(auto_pieces[-1])
	
	self.seasons = PieChart.new(Vector2($RightRect.size[0], $RightRect.size[0]))
	$RightRect.add_child(seasons)
	seasons.layout_mode = 1
	seasons.anchors_preset = PRESET_CENTER_BOTTOM
	seasons.change_month()
	
	start_turn()

func end_turn():
	spawner.disable_end_turn_button()
	var tween = get_tree().create_tween()
	var moved_pieces = []
	tween.set_parallel()
	tween.connect("finished", finish_auto_move.bind(moved_pieces))
	var someone_moved = false
	for piece in auto_pieces:
		if piece.speed > 0:
			someone_moved = true
			var pos = piece.move_in_direction(board)
			if pos != piece.coords:
				animated_move(piece, pos, tween)
				board.traverse(piece, pos)
				moved_pieces.append(piece)
		else:
			piece.skip_turn()
	if not someone_moved:
		tween.emit_signal("finished")

func finish_auto_move(moved_pieces: Array):
	finish_move(moved_pieces)
	change_climate()

func change_climate():
	season_counter = (season_counter + 1) % 32
	if season_counter % 2 == 0:
		self.seasons.change_month()
	var cleared_squares = board.flip_weather(
		self.climate.calc_climate(season_counter / 2)
	)
	for square in cleared_squares:
		var piece = board.get_piece(square)
		if piece.name != "Pawn" and piece.name != "King":
			piece.get_damage(piece.health)
			animated_death(piece)
			if players[0].has_piece(piece):
				players[0].remove_if_dead(piece)
			elif players[1].has_piece(piece):
				players[1].remove_if_dead(piece)
			else:
				auto_pieces.erase(piece)
	super.end_turn()
