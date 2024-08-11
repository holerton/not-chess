class_name PieceSpawner extends PieceContainer

signal final_selection(piece: Pawn)

var button
var end_turn_button
var cancel_selection_button

func _ready():
	Board_X_Size = 4
	Board_Y_Size = 2
	super()
	var squares = get_children()
	for square in squares:
		square.set_action(func(): 
			if square.is_active:
				var new_piece = square.get_child(1).duplicate()
				new_piece.piece_name = square.get_child(1).piece_name
				final_selection.emit(new_piece)
				)
	button = Button.new()
	button.text = "Move Army"
	button.pressed.connect(self._button_pressed)
	button.disabled = true
	add_child(button)
	
	end_turn_button = Button.new()
	end_turn_button.text = "End Turn"
	end_turn_button.pressed.connect(get_node('../..')._on_end_turn)
	end_turn_button.disabled = true
	add_child(end_turn_button)

	cancel_selection_button = Button.new()
	cancel_selection_button.pressed.connect(get_node('../..').cancel_selection)
	cancel_selection_button.set_text("Cancel Selection")
	cancel_selection_button.disabled = true
	add_child(cancel_selection_button)
	
func _button_pressed():
	final_selection.emit(null)

func basic_setup():
	var pieces = ["Rook", "Bishop", "Night", "Pawn"]
	var colors = ["white", "black"]
	var i = 1
	for color in colors:
		var j = 1
		for piece in pieces:
			var new_piece = add_piece(piece, color, str(i) + str(j))
			new_piece.Position += 's'
			j += 1
		i += 1

func flip_squares(pieces, piece_color):
	var i = "1" if piece_color == "white" else "2"
	var all_pieces = ["Rook", "Bishop", "Night", "Pawn"]
	for j in len(all_pieces):
		if all_pieces[j] in pieces:
			get_node(i + str(j + 1)).flip_activity()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func enable_selection_button():
	cancel_selection_button.disabled = false

func disable_selection_button():
	cancel_selection_button.disabled = true

func enable_end_button():
	end_turn_button.disabled = false

func disable_end_button():
	end_turn_button.disabled = true

func disable_move_button():
	button.disabled = true
	
func enable_move_button():
	button.disabled = false
