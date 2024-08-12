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

## Creates a new Player with the given color
func _init(color: String):
	self.color = color

## Accepts one parameter: 
## dark - if true, searches for the squares that are dark.
## Otherwise searches for white.
## Uses DFS to find coordinates of all squares of the said color
## that are accessible to clone piece to
## Returns an Array of coordinates.
func get_accessible(dark: bool):
	if is_alive():
		var accessible = []
		var x = int(king.coords[0])
		var y = int(king.coords[1])
		
		## Setting up visited and square_queue Arrays
		var square_queue = [king.coords]
		
		var visited = []
		for i in 10:
			visited.append([])
			for j in 10:
				visited[i].append(false)
		visited[x][y] = true
		
		for peasant in peasants:
			x = int(peasant.coords[0])
			y = int(peasant.coords[1])
			
			## Queue saves last visited square
			square_queue.append(peasant.coords) 
			visited[x][y] = true
		
		## When all of the Pawns and King are visited, returns result
		while not square_queue.is_empty():
			var square = square_queue.pop_front()
			var neighbors = Board.get_neighbors(square)
			for elem in neighbors: ## Checking neighbors
				x = int(elem[0])
				y = int(elem[1])
				
				## Accessible square must be not visited and empty
				if not visited[x][y] and Board.is_empty(elem):
					visited[x][y] = true
					
					## If the color fits, adds square to the resulting Array
					if is_dark(elem) == dark:
						accessible.append(elem)
		return accessible

## Returns true if the given coordinates correspond to a dark square.
## Otherwise false.
func is_dark(pos: String) -> bool:
	return (int(pos[0]) + int(pos[1])) % 2

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
func get_possible_pieces():
	var result = []
	if limit > 0:
		for piece in ["Rook", "Bishop", "Night"]:
			if available_pieces[piece] > 0:
				result.append(piece)
	if available_pieces["Pawn"] > 0:
		result.append("Pawn")
	return result

## Returns an army array
func get_army():
	return army

## Returns true if army array contains any piece, false otherwise
func has_army():
	return not army.is_empty()

## Returns true if king is not null, false otherwise
func is_alive():
	return king != null
