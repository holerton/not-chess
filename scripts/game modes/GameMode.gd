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

	var total_size = Vector2(Global.board_width * Global.tile_size * 1.5,
	Global.board_height * Global.tile_size)
	get_window().size = total_size
	
	$ChessboardRect.size = Vector2(Global.board_width * Global.tile_size,
	Global.board_height * Global.tile_size)
	
	$LeftRect.size = Vector2(Global.board_width * Global.tile_size * 0.5,
	Global.board_height * Global.tile_size)
	$LeftRect.position = Vector2(total_size[0] / 1.5, 0)
	
	players = [Player.new("black"), Player.new("white")]
	var kings = $ChessboardRect/Chessboard.basic_setup()
	$LeftRect/PieceSpawner.basic_setup()
	players[0].spawn_piece(kings[1])
	players[1].spawn_piece(kings[0])
	
	start_turn()

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
	$LeftRect/PieceSpawner.disable_end_turn_button()
	$LeftRect/PieceSpawner.disable_cancel_selection_button()
	if players[0].is_alive() and players[1].is_alive():
		swap_players()
		var pieces = players[0].get_possible_pieces()
		if players[0].has_army():
			$LeftRect/PieceSpawner.enable_move_army_button()
		$LeftRect/PieceSpawner.flip_active_squares(pieces, players[0].color)
	else:
		$LeftRect/PieceSpawner.disable_move_army_button()
		var message = "The winner is " + players[0].color
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
	clear_highlighted_squares()
	set_current_piece(null)
	army_to_move.clear()
	start_turn()

## Reaction to a final_selection signal
## If new_piece is not null it means that player wants to clone a piece.
## Highlights squares, accessible to clone to
## Otherwise means that player wants to move army
## Fills army_to_move and calls move_army(null) 
func _on_piece_spawner_final_selection(new_piece):
	$LeftRect/PieceSpawner.disable_move_army_button()
	$LeftRect/PieceSpawner.enable_cancel_selection_button()
	var pieces = players[0].get_possible_pieces()
	$LeftRect/PieceSpawner.flip_active_squares(pieces, players[0].color)	
	if new_piece != null:
		set_current_piece(new_piece)
		active_chessboard_squares = players[0].get_accessible(true if current_piece.name != "Pawn" else false)
		$ChessboardRect/Chessboard.flip_active_squares(active_chessboard_squares)
	else:
		$LeftRect/PieceSpawner.enable_end_turn_button()
		army_to_move = players[0].get_army().duplicate(true)
		move_army(null)

## Reaction to empty_square_selected emission
## If current_piece coordinates are empty it means that player
## wants to clone a piece. Sets a piece on the board and calls piece_added()
## Otherwise means, that player moved a piece. 
## Moves a piece on a board and calls piece_moved() 
func _on_chessboard_empty_square_selected(pos):
	if current_piece.coords == "":
		current_piece.move(pos)
		$ChessboardRect/Chessboard.set_piece(current_piece)
		piece_added()
	else:
		$ChessboardRect/Chessboard.traverse(current_piece, pos)
		piece_moved()

## Called when new piece is cloned to an empty square
## If new piece is a Pawn, calls end_turn
## Otherwise forms army_to_move and calls move_army(current_piece)
func piece_added():
	clear_highlighted_squares()
	$LeftRect/PieceSpawner.disable_cancel_selection_button()
	$LeftRect/PieceSpawner.enable_end_turn_button()
	players[0].spawn_piece(current_piece)
	if current_piece.name == "Pawn":
		set_current_piece(null)
		end_turn()
	else:
		army_to_move = players[0].get_army().duplicate(true)
		move_army(current_piece)

## Called after piece moves to an empty square.
## If piece has any attackable squares, function highlights them and its position
## Otherwise calls move_army(current_piece)
func piece_moved():
	$LeftRect/PieceSpawner.disable_cancel_selection_button()
	clear_highlighted_squares()
	attacked_chessboard_squares = current_piece.find_attackable()
	if len(attacked_chessboard_squares) == 0:
		move_army(current_piece)
	else:
		active_chessboard_squares = [current_piece.coords]
		flip_buffered_squares()

## Reaction on the emission of exisiting_piece_selected signal.
##
## If selected_piece is a King it means, that current player beat the enemy king
## Replaces king with null and calls end_turn()
##
## If selected_piece is not the current_piece 
## it means that current player wants to move that piece
## Highlights reachable and attackable squares for that piece
##
## If selected_piece is the current_piece 
## it means that player wants to end the movement of that piece.
## Calls move_army(current_piece)
func _on_chessboard_existing_piece_selected(selected_piece):
	if selected_piece.name == "King":
		selected_piece.get_damage(1)
		players[1].remove_if_dead(selected_piece)
		$ChessboardRect/Chessboard.replace(current_piece, selected_piece)
		end_turn()
		return
	
	clear_highlighted_squares()
	
	if current_piece != selected_piece:
		set_current_piece(selected_piece)
		active_chessboard_squares = current_piece.find_reachable()
		attacked_chessboard_squares = current_piece.find_attackable()
		flip_buffered_squares()
		$LeftRect/PieceSpawner.enable_cancel_selection_button()
	
	else:
		move_army(current_piece)

## Reaction to the emission of piece_attacked signal
##
## Firstly current_piece attacks other_piece
## special_action contains true 
## if current_piece will perform a special action, false otherwise
##
## Secondly other_piece is removed, if it is dead
##
## Thirdly current_piece is removed, if it is dead
##
## Lastly if special_action is true
## Function highlights special squares for that action
## Otherwise calls move_army 
func _on_chessboard_piece_attacked(other_piece):
	clear_highlighted_squares()
	var special_action = current_piece.attack(other_piece)
	if players[1].remove_if_dead(other_piece):
		$ChessboardRect/Chessboard.clear_square(other_piece)
	if players[0].remove_if_dead(current_piece):
		$ChessboardRect/Chessboard.clear_square(current_piece)
		army_to_move.erase(current_piece)
		set_current_piece(null)
	if special_action:
		var selected_squares = current_piece.special_selection()
		active_chessboard_squares = selected_squares[0]
		attacked_chessboard_squares = selected_squares[1]
		flip_buffered_squares()
	else:
		move_army(current_piece)

## Reaction to a cancel_selection_button press.
## If current_piece coordinates are empty 
## it means that player cancels selection of piece to clone.
## Swaps players and calls end_turn to repeat the same selection
## Otherwise means that player wants to 
## cancel selection of an existing army piece.
## Calls move_army(null) to repeat choice 
func _on_cancel_selection():
	if current_piece == null or current_piece.coords == "":
		swap_players()
		end_turn()
	else:
		$LeftRect/PieceSpawner.disable_cancel_selection_button()
		move_army(null)
