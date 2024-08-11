extends Control

var chosen_piece: Pawn = null
var players
signal start_turn
signal move_army(moved_piece)

var black: bool = false
var army_to_move = []
var active_chessboard_squares = []
var attacked_chessboard_squares = []

func _ready():
	players = [Player.new("white"), Player.new("black")]
	var kings = $ChessboardRect/Chessboard.basic_setup()
	players[0].spawn_piece(kings[0])
	players[1].spawn_piece(kings[1])
	$LeftRect/PieceSpawner.basic_setup()	
	start_turn.emit()

func set_chosen_piece(piece: Pawn):
	chosen_piece = piece

func get_chosen_piece():
	return chosen_piece

func _process(delta):
	pass

func clear_selection():
	flip_selection()
	active_chessboard_squares.clear()
	attacked_chessboard_squares.clear()

func flip_selection():
	$ChessboardRect/Chessboard.attack_squares(attacked_chessboard_squares)
	$ChessboardRect/Chessboard.flip_squares(active_chessboard_squares)

func _on_chessboard_existing_piece_selected(piece):
	clear_selection()
	if chosen_piece != piece:
		set_chosen_piece(piece)
		active_chessboard_squares = piece.find_traversable()
		attacked_chessboard_squares = chosen_piece.find_attackable()
		flip_selection()
		$LeftRect/PieceSpawner.enable_selection_button()
	else:
		move_army.emit(chosen_piece)

func _on_chessboard_piece_moved():
	var accessible = len(active_chessboard_squares)
	clear_selection()
	attacked_chessboard_squares = chosen_piece.find_attackable()
	if accessible == 1 or len(attacked_chessboard_squares) == 0:
		move_army.emit(chosen_piece)
	else:
		active_chessboard_squares = [chosen_piece.Position]
		flip_selection()
	
func _on_start_turn():
	if players[0].is_alive() and players[1].is_alive():
		var current_player = players[int(black)]
		var pieces = current_player.get_possible_pieces()
		$LeftRect/PieceSpawner.flip_squares(pieces, current_player.color)
	else:
		var message = "The winner is white" if players[0].is_alive() else "The winner is black"
		$AcceptDialog.dialog_text = message
		$AcceptDialog.show()


func _on_chessboard_piece_added():
	var current_player = players[int(black)]
	clear_selection()
	current_player.spawn_piece(chosen_piece)
	if chosen_piece.name == "Pawn":
		black = not black
		set_chosen_piece(null)
		start_turn.emit()
	else:
		army_to_move = current_player.get_army().duplicate(true)
		move_army.emit(chosen_piece)

func _on_move_army(moved_piece):
	clear_selection()
	set_chosen_piece(null)
	army_to_move.erase(moved_piece)
	if len(army_to_move) == 0:
		black = not black
		start_turn.emit()
	else:
		for piece in army_to_move:
			active_chessboard_squares.append(piece.Position)
		flip_selection()


func _on_chessboard_piece_attacked(other):
	clear_selection()
	chosen_piece.attack(other)
	var current_player = players[int(black)]
	var other_player = players[int(not black)]
	if other_player.destroy_if_dead(other):
		$ChessboardRect/Chessboard.clear_square(other)
		if not other_player.is_alive():
			clear_selection()
			set_chosen_piece(null)
			start_turn.emit()
			return
	if current_player.destroy_if_dead(chosen_piece):
		$ChessboardRect/Chessboard.clear_square(chosen_piece)
		army_to_move.erase(chosen_piece)
		move_army.emit(null)
	else:
		move_army.emit(chosen_piece)

func _on_piece_spawner_final_selection(new_piece):
	var current_player = players[int(black)]
	var pieces = current_player.get_possible_pieces()
	$LeftRect/PieceSpawner.flip_squares(pieces, current_player.color)	
	if new_piece != null:
		set_chosen_piece(new_piece)
		active_chessboard_squares = current_player.get_accessible(true if chosen_piece.name != "Pawn" else false)
		$ChessboardRect/Chessboard.flip_squares(active_chessboard_squares)
	else:
		army_to_move = current_player.get_army().duplicate(true)
		move_army.emit(null)
		
func _on_end_turn():
	clear_selection()
	set_chosen_piece(null)
	army_to_move = []
	black = not black
	start_turn.emit()
	
func cancel_selection():
	$LeftRect/PieceSpawner.disable_selection_button()
	move_army.emit(null)
