extends Control
class_name GameMode

## Stores the current piece which comes from cloning or moving 
var current_piece: BasePiece = null

## Stores players of the game
var players: Array

## Stores current unmoved army pieces
var army_to_move = []

## Stores current active chessboard squares
var active_chessboard_squares = []

## Stores current attacked chessboard squares
var attacked_chessboard_squares = []

## Prepares the game: creates two players and sets up Board and PieceSpawner
## After that calls method start_turn to begin the game
func _ready():
	construct_gui()
	
	players = [Player.new("white"), Player.new("black")]
	var kings = $ChessboardRect/Chessboard.basic_setup()
	$RightRect/PieceSpawner.basic_setup()
	players[0].update_limits()
	players[1].update_limits()
	
	players[0].spawn_piece(kings[0])
	players[1].spawn_piece(kings[1])
	
	start_turn()

## Adds children, sets every part of the gui in its place
func construct_gui():
	var window_size = Vector2(Global.board_width * Global.tile_size + 
	Global.tile_size * Global.piece_num, Global.board_height * Global.tile_size)
	get_window().size = window_size
	size = window_size
	
	var chessboard_rect = ColorRect.new()
	chessboard_rect.name = "ChessboardRect"
	chessboard_rect.size = Vector2(Global.board_width * Global.tile_size, window_size[1])
	add_child(chessboard_rect)
	
	var chessboard = Board.new()
	chessboard.name = "Chessboard"
	chessboard_rect.add_child(chessboard)
	
	var right_rect = ColorRect.new()
	right_rect.name = "RightRect"
	right_rect.color = Color.SEA_GREEN
	right_rect.size = Vector2(Global.tile_size * Global.piece_num, window_size[1])
	add_child(right_rect)
	right_rect.layout_mode = 1
	right_rect.anchors_preset = PRESET_TOP_RIGHT
	
	var piece_spawner = PieceSpawner.new()
	piece_spawner.name = "PieceSpawner"
	right_rect.add_child(piece_spawner)
	piece_spawner.layout_mode = 1
	piece_spawner.anchors_preset = PRESET_CENTER_RIGHT
	
	var dialog = AcceptDialog.new()
	dialog.name = "AcceptDialog"
	add_child(dialog)

## Handles clicks on squares. If PieceSpawner is clicked, clones a piece.
## If Chessboard is clicked, calls handle_chessboard_click
func _on_square_clicked(square: Square):
	var container = square.get_container_name()
	if container == "PieceSpawner":
		if square.state == Global.ACTIVE:
			final_selection(square.get_piece().clone())
	else:
		handle_chessboard_click(square)

func handle_chessboard_click(square: Square):
	var state = square.state
	var piece = square.get_piece()
	var coords = square.name
	if state == Global.ACTIVE:
		if piece != null:
			existing_piece_selected(piece)
		else:
			empty_square_selected(coords)
	elif state == Global.ATTACKED:
		piece_attacked(piece)

## Sets the value of current_piece to piece
func set_current_piece(piece: BasePiece):
	self.current_piece = piece

## Swaps two players, used at the beginning of each turn
func swap_players():
	self.players = [players[1], players[0]]

## Sets all highlighted squares to usual state
func clear_highlighted_squares():
	flip_buffered_squares()
	self.active_chessboard_squares.clear()
	self.attacked_chessboard_squares.clear()

## Changes is_active of active_chessboard_squares 
## and is_attacked of attacked_chessboard_squares to opposite
func flip_buffered_squares():
	$ChessboardRect/Chessboard.flip_active_squares(active_chessboard_squares)
	$ChessboardRect/Chessboard.flip_attacked_squares(attacked_chessboard_squares)

## If both players are alive, swaps them.
## Then highlights pieces that are available to clone.
## Otherwise stops the game and presents final dialog
func start_turn():
	$RightRect/PieceSpawner.disable_end_turn_button()
	$RightRect/PieceSpawner.disable_cancel_selection_button()
	if players[0].is_alive() and players[1].is_alive():
		var pieces = players[0].get_possible_pieces()
		if players[0].has_army():
			$RightRect/PieceSpawner.enable_move_army_button()
		$RightRect/PieceSpawner.flip_active_squares(pieces, players[0].color)
	else:
		$RightRect/PieceSpawner.disable_move_army_button()
		var message = "The winner is " + players[1].color
		$AcceptDialog.dialog_text = message
		$AcceptDialog.show()

## Called when army pieces move.
## First of all removes moved_piece from army_to_move Array
## If army_to_move is empty, there are no more pieces to move
## Calls end_turn()
## Otherwise highlights all pieces in army_to_move
func move_army(moved_piece):
	clear_highlighted_squares()
	set_current_piece(null)
	army_to_move.erase(moved_piece)
	if army_to_move.is_empty():
		end_turn()
	else:
		for piece in army_to_move:
			active_chessboard_squares.append(piece.coords)
		flip_buffered_squares()

## Called when the turn ends.
## Clears everything and calls start_turn
func end_turn():
	swap_players()
	clear_highlighted_squares()
	set_current_piece(null)
	army_to_move.clear()
	start_turn()

## Reaction to a final_selection signal
## If new_piece is not null it means that player wants to clone a piece.
## Highlights squares, accessible to clone to
## Otherwise means that player wants to move army
## Fills army_to_move and calls move_army(null) 
func final_selection(new_piece):
	$RightRect/PieceSpawner.disable_move_army_button()
	$RightRect/PieceSpawner.enable_cancel_selection_button()
	var pieces = players[0].get_possible_pieces()
	$RightRect/PieceSpawner.flip_active_squares(pieces, players[0].color)	
	if new_piece != null:
		set_current_piece(new_piece)
		active_chessboard_squares = players[0].get_accessible($ChessboardRect/Chessboard, 
		true if current_piece.name != "Pawn" else false)
		$ChessboardRect/Chessboard.flip_active_squares(active_chessboard_squares)
	else:
		$RightRect/PieceSpawner.enable_end_turn_button()
		army_to_move = players[0].get_army()
		move_army(null)

## Called when empty square on chessboard selected
##
## If current player has current_piece it means that player moved a piece.
## Moves a piece on a board and calls piece_moved().
## Otherwise means, that player wants to clone a piece
## Sets a piece on the board and calls piece_added(). 
func empty_square_selected(pos):
	if players[0].has_piece(current_piece):
		var square = $ChessboardRect/Chessboard.traverse(current_piece, pos)
		if current_piece.skips_turn(square.terrain):
			players[0].add_skipping_piece(current_piece)
		piece_moved()
	else:
		current_piece.move(pos)
		$ChessboardRect/Chessboard.set_piece(current_piece)
		piece_added()

## Called when new piece is cloned to an empty square
## If new piece is a Pawn, calls end_turn
## Otherwise forms army_to_move and calls move_army(current_piece)
func piece_added():
	clear_highlighted_squares()
	$RightRect/PieceSpawner.disable_cancel_selection_button()
	$RightRect/PieceSpawner.enable_end_turn_button()
	players[0].spawn_piece(current_piece)
	if current_piece.name == "Pawn":
		set_current_piece(null)
		players[0].clear_skipping_pieces()
		end_turn()
	else:
		army_to_move = players[0].get_army()
		move_army(current_piece)

## Called after piece moves to an empty square.
## If piece has any attackable squares, function highlights them and its position
## Otherwise calls move_army(current_piece)
func piece_moved():
	$RightRect/PieceSpawner.disable_cancel_selection_button()
	clear_highlighted_squares()
	attacked_chessboard_squares = current_piece.find_attackable($ChessboardRect/Chessboard)
	if len(attacked_chessboard_squares) == 0:
		move_army(current_piece)
	else:
		active_chessboard_squares = [current_piece.coords]
		flip_buffered_squares()


## If selected_piece is a King it means, that current player captured the enemy king
## Replaces enemy king with null and calls end_turn()
##
## If selected_piece is not the current_piece 
## it means that current player wants to move that piece
## Highlights reachable and attackable squares for that piece
##
## If selected_piece is the current_piece 
## it means that player wants to end the movement of that piece.
## Calls move_army(current_piece)
func existing_piece_selected(selected_piece):
	if selected_piece.name == "King":
		selected_piece.get_damage(1)
		players[1].remove_if_dead(selected_piece)
		$ChessboardRect/Chessboard.replace(current_piece, selected_piece)
		end_turn()
		return
	
	clear_highlighted_squares()
	
	if current_piece != selected_piece:
		set_current_piece(selected_piece)
		active_chessboard_squares = current_piece.find_reachable($ChessboardRect/Chessboard)
		attacked_chessboard_squares = current_piece.find_attackable($ChessboardRect/Chessboard)
		flip_buffered_squares()
		$RightRect/PieceSpawner.enable_cancel_selection_button()
	
	else:
		move_army(current_piece)

## Firstly current_piece attacks other_piece, 
## resulting special_action contains true 
## if current_piece will perform a special action, false otherwise
##
## Secondly other_piece is removed, if it is dead
##
## Thirdly current_piece is removed, if it is dead
##
## Lastly if special_action is true 
## function highlights special squares for that action
## Otherwise calls move_army 
func piece_attacked(other_piece):
	clear_highlighted_squares()
	var special_action = current_piece.attack(other_piece)
	if players[1].remove_if_dead(other_piece):
		$ChessboardRect/Chessboard.clear_square(other_piece)
	if players[0].remove_if_dead(current_piece):
		$ChessboardRect/Chessboard.clear_square(current_piece)
		army_to_move.erase(current_piece)
		set_current_piece(null)
	if special_action:
		var selected_squares = current_piece.special_selection($ChessboardRect/Chessboard, other_piece)
		attacked_chessboard_squares = selected_squares[1]
		
		if attacked_chessboard_squares.is_empty():
			move_army(current_piece)
		else:
			active_chessboard_squares = selected_squares[0]
			flip_buffered_squares()
	else:
		move_army(current_piece)

## Reaction to a cancel_selection_button press.
##
## If player has current_piece it means that player wants to 
## cancel selection of an existing army piece.
## Calls move_army(null) to repeat choice.
##
## Otherwise player wants to cancel selection of a piece to clone.
## Clears highlighted squares, calls start_turn to repeat selection 
func _on_cancel_selection():
	$RightRect/PieceSpawner.disable_cancel_selection_button()
	if players[0].has_piece(current_piece):
		move_army(null)
	else:
		clear_highlighted_squares()
		set_current_piece(null)
		start_turn()
