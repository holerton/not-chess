extends Control

var chosen_piece: Pawn = null
var players
signal start_turn
signal move_army(moved_piece)

var army_to_move = []
var active_chessboard_squares = []
var attacked_chessboard_squares = []

func _ready():
	players = [Player.new("black"), Player.new("white")]
	var kings = $ChessboardRect/Chessboard.basic_setup()
	players[0].spawn_piece(kings[1])
	players[1].spawn_piece(kings[0])
	$LeftRect/PieceSpawner.basic_setup()	
	start_turn.emit()

func set_chosen_piece(piece: Pawn):
	chosen_piece = piece

func get_chosen_piece():
	return chosen_piece

func swap_players():
	self.players = [players[1], players[0]]

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
	if piece.name == "King":
		piece.get_damage(1)
		players[1].destroy_if_dead(piece)
		$ChessboardRect/Chessboard.clear_square(piece)
		$ChessboardRect/Chessboard.traverse(chosen_piece, piece.Position)
		_on_end_turn()
		return
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
	$LeftRect/PieceSpawner.disable_selection_button()
	var accessible = len(active_chessboard_squares)
	clear_selection()
	attacked_chessboard_squares = chosen_piece.find_attackable()
	if accessible == 1 or len(attacked_chessboard_squares) == 0:
		move_army.emit(chosen_piece)
	else:
		active_chessboard_squares = [chosen_piece.Position]
		flip_selection()
	
func _on_start_turn():
	$LeftRect/PieceSpawner.disable_end_button()
	$LeftRect/PieceSpawner.disable_selection_button()
	swap_players()
	if players[0].is_alive() and players[1].is_alive():
		var pieces = players[0].get_possible_pieces()
		if players[0].has_army():
			$LeftRect/PieceSpawner.enable_move_button()
		$LeftRect/PieceSpawner.flip_squares(pieces, players[0].color)
	else:
		$LeftRect/PieceSpawner.disable_move_button()
		var message = "The winner is white" if players[0].is_alive() else "The winner is black"
		$AcceptDialog.dialog_text = message
		$AcceptDialog.show()


func _on_chessboard_piece_added():
	clear_selection()
	$LeftRect/PieceSpawner.disable_selection_button()
	$LeftRect/PieceSpawner.enable_end_button()
	players[0].spawn_piece(chosen_piece)
	if chosen_piece.name == "Pawn":
		set_chosen_piece(null)
		_on_end_turn()
	else:
		army_to_move = players[0].get_army().duplicate(true)
		move_army.emit(chosen_piece)

func _on_move_army(moved_piece):
	clear_selection()
	set_chosen_piece(null)
	army_to_move.erase(moved_piece)
	if len(army_to_move) == 0:
		_on_end_turn()
	else:
		for piece in army_to_move:
			active_chessboard_squares.append(piece.Position)
		flip_selection()


func _on_chessboard_piece_attacked(other):
	clear_selection()
	chosen_piece.attack(other)
	if players[1].destroy_if_dead(other):
		$ChessboardRect/Chessboard.clear_square(other)
		#if not players[1].is_alive():
			#clear_selection()
			#set_chosen_piece(null)
			#_on_end_turn()
			#return
	if players[0].destroy_if_dead(chosen_piece):
		$ChessboardRect/Chessboard.clear_square(chosen_piece)
		army_to_move.erase(chosen_piece)
		move_army.emit(null)
	else:
		move_army.emit(chosen_piece)

func _on_piece_spawner_final_selection(new_piece):
	$LeftRect/PieceSpawner.disable_move_button()
	$LeftRect/PieceSpawner.enable_selection_button()
	var pieces = players[0].get_possible_pieces()
	$LeftRect/PieceSpawner.flip_squares(pieces, players[0].color)	
	if new_piece != null:
		set_chosen_piece(new_piece)
		active_chessboard_squares = players[0].get_accessible(true if chosen_piece.name != "Pawn" else false)
		$ChessboardRect/Chessboard.flip_squares(active_chessboard_squares)
	else:
		$LeftRect/PieceSpawner.enable_end_button()
		army_to_move = players[0].get_army().duplicate(true)
		move_army.emit(null)
		
func _on_end_turn():
	clear_selection()
	set_chosen_piece(null)
	army_to_move = []
	start_turn.emit()
	
func cancel_selection():
	if chosen_piece in players[0].army:
		$LeftRect/PieceSpawner.disable_selection_button()
		move_army.emit(null)
	else:
		swap_players()
		_on_end_turn()
