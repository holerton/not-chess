extends Node
class_name Player
## Class that represents a player. Contains it's army, peasants and king

## Defines which color is the Player
var color: String

## Stores the data about availability of all pieces
var available_pieces: Dictionary = {'Pawn': 8, "Night": 2, "Bishop": 2, "Rook": 2, "King": 1}

## Stores all of the army pieces of the Player
var army: Array

## Stores all Pawns of the Player
var peasants: Array

## Stores the King of the Player
var king: King = null

## Represents how many more army pieces can Player add to his army 
var limit: int = 0

## Array of pieces, that skip next turn
var skipping_pieces: Dictionary = {}

## Terrains on which you cannot spawn. True for army, false for pawns
## TODO: Replace with terrain_weather_rules from BasePiece
var inaccessible_terrains = {true: [["Water", "None"]], false: []}
var inaccessible_terrains_new = {"Rook": [["Water", "None"]],
								 "Bishop": [["Water", "None"]],
								 "Night": [["Water", "None"], ["Forest","None"]],
								 "Pawn": []}

## Creates a new Player with the given color
func _init(color: String):
	self.color = color

## Accepts one parameter: 
## dark - if true, searches for the squares that are dark.
## Otherwise searches for white.
## Uses DFS to find coordinates of all squares of the said color
## that are accessible to clone piece to
## Returns an Array of coordinates.
func get_accessible(board: Board, dark: bool):
	if is_alive():
		var accessible = []
		
		## Setting up square_queue, which contains all pawns and a king
		var square_queue = [king.coords]
		for peasant in peasants:
			square_queue.append(peasant.coords)
		## When all of the Pawns and King are explored, returns accessible
		while not square_queue.is_empty():
			var square = square_queue.pop_front()
			var neighbors = Board.get_neighbors(square, 1)
			for neighbor in neighbors:
				## Accessible square must be the searched color and empty
				if Board.is_dark(neighbor) == dark and Board.is_empty(neighbor):
					var terrain = board.get_terrain(neighbor)
					var weather = board.get_weather(neighbor)
					if [terrain, weather] not in inaccessible_terrains[dark]:
						## If the square is not added yet, add
						if neighbor not in accessible:
							accessible.append(neighbor)
		return accessible
		
func get_accessible_new(board: Board, figure: String):
	var dark : bool
	if figure == "Pawn" :
		dark = false
	else :
		dark = true
		
	if is_alive():
		var accessible = []
		
		## Setting up square_queue, which contains all pawns and a king
		var square_queue = [king.coords]
		for peasant in peasants:
			square_queue.append(peasant.coords)
		## When all of the Pawns and King are explored, returns accessible
		while not square_queue.is_empty():
			var square = square_queue.pop_front()
			var neighbors = Board.get_neighbors(square, 1)
			for neighbor in neighbors:
				## Accessible square must be the searched color and empty
				if Board.is_dark(neighbor) == dark and Board.is_empty(neighbor):
					var terrain = board.get_terrain(neighbor)
					var weather = board.get_weather(neighbor)
					if [terrain, weather] not in inaccessible_terrains_new[figure]:
						## If the square is not added yet, add
						if neighbor not in accessible:
							accessible.append(neighbor)
		return accessible

## Adds an instance of BasePiece to the Player
func spawn_piece(piece: BasePiece):
	
	## Decreases the availability of the piece
	self.available_pieces[piece.name] -= 1
	
	## If it's a King, sets the king property and increases the limit
	if piece.name == "King":
		self.king = piece
		self.limit += 1
	
	## If it's a Pawn, adds to the peasants array and increases the limit
	elif piece.name == "Pawn":
		self.peasants.append(piece)
		self.limit += 1
	
	## If it's an army piece, adds to the army array and decreases the limit
	else:
		self.army.append(piece)
		self.limit -= 1

## Checks if piece is alive. If it's not, removes it and changes the limit
## Returns true if piece is removed, false otherwise
func remove_if_dead(piece: BasePiece):
	if not piece.is_alive():
		
		## Increases the availability of the piece
		self.available_pieces[piece.name] += 1
		
		## If it's a King, sets the king property to null and decreases the limit
		if piece.name == "King":
			self.king = null
			self.limit -= 1
			
		## If it's a Pawn, erases it from peasants array and decreases the limit
		elif piece.name == "Pawn":
			self.peasants.erase(piece)
			self.limit -= 1
		
		## If it's an army piece, erases it from army array and increases the limit	
		else:
			self.army.erase(piece)
			self.limit += 1
		return true
	return false

## Returns an Array with the names of all the pieces, 
## that are available to the Player
func get_possible_pieces(board: Board):
	var result = []
	for piece in ["Rook", "Bishop", "Night"]:
		if limit > 0 and not get_accessible_new(board, piece).is_empty():
			if available_pieces[piece] > 0:
				result.append(piece)
	if available_pieces["Pawn"] > 0:
		result.append("Pawn")
	return result

func skip_turn():
	for piece in army:
		piece.skip_turn()

## Returns an army array without pieces that skip turn
func get_army():
	var current_army = []
	for piece in army:
		if piece.speed > 0:
			current_army.append(piece)
		else:
			piece.skip_turn()
	return current_army

## Returns true if army array contains any piece, false otherwise
func has_army():
	for piece in army:
		if piece.speed > 0:
			return true
	return false

## Returns true if king is not null, false otherwise
func is_alive():
	return king != null

func has_piece(piece: BasePiece):
	if piece == king:
		return true
	if piece in peasants:
		return true
	if piece in army:
		return true
	return false

## Adds piece to skipping_pieces
func add_skipping_piece(piece: BasePiece, skips: int):
	skipping_pieces[piece] = skips

func update_limits():
	self.available_pieces = Global.limits.duplicate(true)
