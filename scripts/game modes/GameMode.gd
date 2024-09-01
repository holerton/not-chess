extends Control
class_name GameMode

## Stores the current piece which comes from cloning or moving 
var current_piece: BasePiece = null

## Stores players of the game
var players: Array

## Stores current unmoved army pieces
var army_to_move = []

var board: Board

var spawner: PieceSpawner

var autoplayer_color: String

## Prepares the game: creates two players and sets up Board and PieceSpawner
## After that calls method start_turn to begin the game
func _ready():
	construct_gui()
	self.board = $ChessboardRect/Chessboard
	self.spawner = $RightRect/PieceSpawner
	self.autoplayer_color = "black"#!!!
	if autoplayer_color == "black":
		players = [Player.new("white"), AutoPlayer.new("black")]
	else:
		players = [AutoPlayer.new("white"), Player.new("black")]
	var kings = board.basic_setup()
	spawner.basic_setup()
	players[0].update_limits()
	players[1].update_limits()
	
	players[0].spawn_piece(kings[0])
	players[1].spawn_piece(kings[1])

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

## If both players are alive, swaps them.
## Then highlights pieces that are available to clone.
## Otherwise stops the game and presents final dialog
func start_turn():
	spawner.enable_end_turn_button()
	spawner.disable_cancel_selection_button()
	if players[0].is_alive() and players[1].is_alive():
		autoplayer()
		var pieces = players[0].get_possible_pieces(board)
		if players[0].has_army():
			spawner.enable_move_army_button()
		spawner.set_active_squares_from_pieces(pieces, players[0].color)
		spawner.flip_highlighted()
	else:
		spawner.disable_end_turn_button()
		spawner.disable_move_army_button()
		var message = "The winner is " + players[1].color
		$AcceptDialog.dialog_text = message
		$AcceptDialog.show()

## Called when army pieces move.
## First of all removes moved_piece from army_to_move Array
## If army_to_move is empty, there are no more pieces to move
## Calls end_turn()
## Otherwise highlights all pieces in army_to_move
func move_army(moved_piece):
	board.clear_highlighted()
	army_to_move.erase(moved_piece)
	if army_to_move.is_empty():
		end_turn()
	else:
		var active_chessboard_squares = []
		for piece in army_to_move:
			active_chessboard_squares.append(piece.coords)
		board.set_active_squares(active_chessboard_squares)
		board.flip_highlighted()

## Called when the turn ends.
## Clears everything and calls start_turn
func end_turn():
	spawner.clear_highlighted()
	board.clear_highlighted()
	if current_piece == null:
		players[0].skip_turn()
	swap_players()
	set_current_piece(null)
	army_to_move.clear()
	start_turn()

## Reaction to a final_selection signal
## If new_piece is not null it means that player wants to clone a piece.
## Highlights squares, accessible to clone to
## Otherwise means that player wants to move army
## Fills army_to_move and calls move_army(null) 
func final_selection(new_piece):
	spawner.disable_move_army_button()
	spawner.enable_cancel_selection_button()
	var pieces = players[0].get_possible_pieces(board)
	spawner.clear_highlighted()
	if new_piece != null:
		set_current_piece(new_piece)
		board.set_active_squares(players[0].get_accessible(board, current_piece))
		board.flip_highlighted()
	else:
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
		var tween = create_tween()
		tween.connect("finished", finish_move.bind([current_piece]))
		var route = current_piece.find_route(board, pos)
		board.traverse(current_piece, pos)
		for square in route:
			animated_move(current_piece, square, tween)
		
		piece_moved()
	else:
		current_piece.set_coords(pos)
		board.set_piece(current_piece)
		piece_added()

## Called when new piece is cloned to an empty square
## If new piece is a Pawn, calls end_turn
## Otherwise forms army_to_move and calls move_army(current_piece)
func piece_added():
	board.clear_highlighted()
	spawner.disable_cancel_selection_button()
	players[0].spawn_piece(current_piece)
	if current_piece.name == "Pawn":
		players[0].skip_turn()
		end_turn()
	else:
		army_to_move = players[0].get_army()
		move_army(current_piece)

## Called after piece moves to an empty square.
## If piece has any attackable squares, function highlights them and its position
## Otherwise calls move_army(current_piece)
func piece_moved():
	spawner.disable_cancel_selection_button()
	board.clear_highlighted()
	if current_piece.speed > 0:
		var attacked_chessboard_squares = current_piece.find_attackable(board)
		if len(attacked_chessboard_squares) > 0:
			board.set_active_squares([current_piece.coords])
			board.set_attacked_squares(attacked_chessboard_squares)
			board.flip_highlighted()
			return
	move_army(current_piece)

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
		board.clear_square(selected_piece)
		
		var tween = create_tween()
		tween.connect("finished", finish_move.bind([current_piece]))
		var route = current_piece.find_route(board, selected_piece.coords)
		board.traverse(current_piece, selected_piece.coords)
		for square in route:
			animated_move(current_piece, square, tween)
		end_turn()
		return
	
	board.clear_highlighted()
	
	if current_piece != selected_piece:
		set_current_piece(selected_piece)
		board.set_active_squares(current_piece.find_reachable(board))
		board.set_attacked_squares(current_piece.find_attackable(board))
		board.flip_highlighted()
		spawner.enable_cancel_selection_button()
	
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
	board.clear_highlighted()
	var special_action = current_piece.attack(other_piece)
	if players[1].remove_if_dead(other_piece):
		animated_death(other_piece)
	if players[0].remove_if_dead(current_piece):
		animated_death(current_piece)
	if special_action:
		var selected_squares = current_piece.special_selection(board, other_piece)
		var attacked_chessboard_squares = selected_squares[1]
		
		if attacked_chessboard_squares.is_empty():
			move_army(current_piece)
		else:
			board.set_active_squares(selected_squares[0])
			board.set_attacked_squares(selected_squares[1])
			board.flip_highlighted()
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
	spawner.disable_cancel_selection_button()
	if players[0].has_piece(current_piece):
		move_army(null)
	else:
		board.clear_highlighted()
		set_current_piece(null)
		start_turn()

func animated_move(piece: BasePiece, to: String, tween: Tween):
	var xy_to = Board.coords_to_int(to)
	var loc_to = Vector2((xy_to[0] - 0.5) * Global.tile_size,
	(xy_to[1] - 0.5) * Global.tile_size)
	
	tween.tween_property(piece, "position", loc_to, 0.25)

func finish_move(moved_pieces: Array):
	for piece in moved_pieces:
		board.remove_child(piece)
		piece.set_position(Vector2(Global.tile_size / 2, Global.tile_size / 2))
		board.get_node(piece.coords).add_child(piece)

func animated_death(piece: BasePiece):
	var tween = create_tween()
	tween.connect("finished", board.clear_square.bind(piece))
	tween.tween_property(piece, "modulate", Color.RED, 0.15)
	tween.tween_property(piece, "scale", Vector2(), 0.15)

func autoplayer():
	if players[0].color == autoplayer_color:
		players[0].autoplayer_turn()
		end_turn()
