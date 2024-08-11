extends Node
class_name Player

var color: String
var pieces: Dictionary = {'Pawn': 8, "Night": 2, "Bishop": 2, "Rook": 2, "King": 1}
var army: Array
var peasants: Array
var king: King = null
var limit: int = 0

func _init(color: String):
	self.color = color

func get_accessible(dark: bool):
	if is_alive():
		var accessible = []
		var visited = []
		for i in 10:
			visited.append([])
			for j in 10:
				visited[i].append(false)
		visited[int(king.Position[0])][int(king.Position[1])] = true
		var square_queue = [king.Position]
		for peasant in peasants:
			square_queue.append(peasant.Position)
			visited[int(peasant.Position[0])][int(peasant.Position[1])] = true
		while not square_queue.is_empty():
			var square = square_queue.pop_front()
			var neighbors = Board.get_neighbors(square)
			for elem in neighbors:
				var x = int(elem[0])
				var y = int(elem[1])
				if not visited[x][y] and Board.is_empty(elem):
					visited[x][y] = true
					if is_dark(elem) == dark:
						accessible.append(elem)
		return accessible

func is_dark(pos: String) -> bool:
	return (int(pos[0]) + int(pos[1])) % 2

func spawn_piece(piece: Pawn):
	pieces[piece.name] -= 1
	if piece.name == "King":
		king = piece
		limit += 1
	elif piece.name == "Pawn":
		peasants.append(piece)
		limit += 1
	else:
		army.append(piece)
		limit -= 1

func destroy_if_dead(piece: Pawn):
	if not piece.is_alive():
		pieces[piece.name] += 1
		if piece.name == "King":
			king = null
			limit -= 1
		elif piece.name == "Pawn":
			peasants.erase(piece)
			limit -= 1
		else:
			army.erase(piece)
			limit += 1
		return true
	return false

func get_possible_pieces():
	var result = []
	if limit > 0:
		for piece in ["Rook", "Bishop", "Night"]:
			if pieces[piece] > 0:
				result.append(piece)
	if pieces["Pawn"] > 0:
		result.append("Pawn")
	return result

func get_army():
	return army

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func is_alive():
	return king != null

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
