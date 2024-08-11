extends FlowContainer
class_name PieceContainer

@export var Board_X_Size = 8
@export var Board_Y_Size = 8

@export var Tile_X_Size: int = 50
@export var Tile_Y_Size: int = 50
var chosen_piece: Pawn

var action = Callable()

func _ready():
	
	if Board_X_Size < 0 || Board_Y_Size < 0:
		return
	
	self.size.y = Board_Y_Size * Tile_Y_Size
	self.size.x = Board_X_Size * Tile_X_Size
	for i in range(Board_Y_Size):
		for j in range(Board_X_Size):
			var new_square = load("res://scenes/square.tscn").instantiate()
			new_square.dark = (i + j) % 2
			new_square.set_custom_minimum_size(Vector2(Tile_X_Size, Tile_Y_Size))
			new_square.set_name(str(i + 1) + str(j + 1))
			# new_square.set_action(action)
			add_child(new_square)
	
func add_piece(Piece_Name: String, color: String, pos: String) -> Pawn:
	var Piece
	match Piece_Name:
		"Pawn":
			Piece = Pawn.new()
			Piece.name = "Pawn"
		"King":
			Piece = King.new()
			Piece.name = "King"
		"Queen":
			Piece = Queen.new()
			Piece.name = "Queen"
		"Night":
			Piece = Knight.new()
			Piece.name = "Night"
		"Rook":
			Piece = Rook.new()
			Piece.name = "Rook"
		"Bishop":
			Piece = Bishop.new()
			Piece.name = "Bishop"
	Piece.Item_Color = color
	Piece.Position = pos
	Piece.position = Vector2(Tile_X_Size / 2, Tile_Y_Size / 2)
	Piece.piece_name = color[0] + Piece_Name[0]
	get_node(pos).add_child(Piece)
	return Piece

func set_chosen_piece(piece: Pawn):
	chosen_piece = piece

func get_chosen_piece():
	return chosen_piece
