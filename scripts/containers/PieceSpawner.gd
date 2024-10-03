class_name PieceSpawner 
extends PieceContainer
## Class that stores the BasePieces used for cloning.
## Extends PieceContainer

signal move_army(piece: BasePiece)

## Button by pressing which the user indicates that he does not want to clone any BasePiece
var move_army_button: Button

## Button which ends the turn
var end_turn_button: Button

## Button which cancels selection of the BasePiece
var cancel_selection_button: Button

## Function, that sets up the PieceSpawner.
func _ready():
	## Defining custom parameters
	board_width = 4 
	board_height = 2
	square_x_size = 50
	square_y_size = 50
	
	## Calling parent's _ready() method
	super()
	
	move_army.connect(get_node("../..").final_selection)
	
	## Setting up the move_army_button
	move_army_button = Button.new()
	move_army_button.text = "Move Army"
	
	## Connecting the pressing of the button with the function
	move_army_button.pressed.connect(self._move_army_button_pressed)
	move_army_button.disabled = true
	add_child(move_army_button)
	
	## Setting up the end_turn_button
	end_turn_button = Button.new()
	end_turn_button.text = "End Turn"
	
	## Connecting the pressing of the button with the function in the main script
	end_turn_button.pressed.connect(get_node('../..').end_turn)
	end_turn_button.disabled = true
	add_child(end_turn_button)

	## Setting up the cancel_selection_button
	cancel_selection_button = Button.new()
	cancel_selection_button.set_text("Cancel Selection")
	
	## Connecting the pressing of the button with the function in the main script
	cancel_selection_button.pressed.connect(get_node('../..')._on_cancel_selection)
	cancel_selection_button.disabled = true
	add_child(cancel_selection_button)

## Emits final_selection signal with null which means that no piece will be cloned
func _move_army_button_pressed():
	move_army.emit(null)

## Creates all of the pieces in the PieceSpawner
func basic_setup():
	var pieces = ["Rook", "Bishop", "Night", "Pawn"]
	var colors = ["w", "b"]
	var i = 1
	for color in colors:
		var j = 1
		for piece in pieces:
			add_piece(piece, color, int_to_coords([j, i]))
			j += 1
		i += 1

func set_active_squares_from_pieces(pieces: Array, piece_color: String):
	var i = 1 if piece_color == "w" else 2
	var all_pieces = ["Rook", "Bishop", "Night", "Pawn"]
	for j in len(all_pieces):
		if all_pieces[j] in pieces:
			active_squares.append(int_to_coords([j + 1, i]))

## Enables cancel_selection_button
func enable_cancel_selection_button():
	cancel_selection_button.disabled = false

## Disables cancel_selection_button
func disable_cancel_selection_button():
	cancel_selection_button.disabled = true

## Enables end_turn_button
func enable_end_turn_button():
	end_turn_button.disabled = false

## Disables end_turn_button
func disable_end_turn_button():
	end_turn_button.disabled = true

## Enables move_army_button	
func enable_move_army_button():
	move_army_button.disabled = false

## Disables move_army_button
func disable_move_army_button():
	move_army_button.disabled = true
