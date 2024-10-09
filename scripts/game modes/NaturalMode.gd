extends GameMode

var season_counter = 0
var seasons: PieChart

var climate: Climate
var neutral_player: NeutralPlayer

func _ready():
	super()
	spawner.anchors_preset = PRESET_CENTER_TOP
	board.set_terrains(Global.terrain_map)
	self.climate = Climate.new(Global.terrain_map)
	board.flip_weather(self.climate.initial_climate())
	neutral_player = NeutralPlayer.new(board)
	self.seasons = PieChart.new(Vector2($RightRect.size[0], $RightRect.size[0]))
	$RightRect.add_child(seasons)
	seasons.layout_mode = 1
	seasons.anchors_preset = PRESET_CENTER_BOTTOM
	seasons.change_month()
	
	start_turn()

func end_turn():
	spawner.disable_end_turn_button()
	var someone_moved = false
	var tween = get_tree().create_tween()
	var moved_pieces = []
	for piece in neutral_player.pieces:
		var route = neutral_player.move_piece(board, piece)
		if not route.is_empty():
			someone_moved = true
			moved_pieces.append(piece)
			board.traverse(piece, route[-1])
			for square in route:
				animated_move(piece, square, tween)
	if someone_moved:
		await Signal(tween, "finished")
	
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
				neutral_player.remove_piece(board, piece)
	for piece in neutral_player.pieces:
		if neutral_player.check_arrival(board, piece):
			animated_arrival(piece)
	super.end_turn()

func animated_arrival(piece: BasePiece):
	var tween = create_tween()
	tween.tween_property(piece, "modulate", Color.SKY_BLUE, 0.15)
	tween.tween_property(piece, "scale", Vector2(), 0.15)
	await Signal(tween, "finished")
	board.clear_square(piece)
