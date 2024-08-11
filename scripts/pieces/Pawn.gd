@tool
extends Sprite2D
class_name Pawn

@export_enum("black", "white") var Item_Color

var Position: String = ""
var damage: int = 0
var speed: int = 0
var range: int = 0
var health: int = 1
var piece_name: String

#func _init(name, color, abs_pos, rel_pos):
	#name = name
	#Item_Color = color
	#position = abs_pos
	#Position = rel_pos
	#piece_name = name.substr(0, 1) + Position[0]

func find_traversable():
	var chessboard = Board.chessboard
	var visited = []
	for i in 10:
		visited.append([])
		for j in 10:
			visited[i].append(false)
	visited[int(Position[0])][int(Position[1])] = true
	var square_queue = [[Position, 0]]
	var traversable = [Position]
	while not square_queue.is_empty():
		var square = square_queue.pop_front()
		if square[1] == speed:
			return traversable
		square[1] += 1
		var neighbors = Board.get_neighbors(square[0])
		for elem in neighbors:
			var x = int(elem[0])
			var y = int(elem[1])
			if Board.is_dark(elem) and not visited[x][y]:
				visited[x][y] = true
				if Board.is_empty(elem) or Board.is_enemy_king(Item_Color[0], elem):
					traversable.append(elem)
					square_queue.append([elem, square[1]])
				elif Board.is_ally(Item_Color[0], elem):
					square_queue.append([elem, square[1]])

func find_attackable():
	var chessboard = Board.chessboard
	var visited = []
	for i in 10:
		visited.append([])
		for j in 10:
			visited[i].append(false)
	visited[int(Position[0])][int(Position[1])] = true
	var square_queue = [[Position, 0]]
	var attackable = []
	while not square_queue.is_empty():
		var square = square_queue.pop_front()
		if square[1] == range:
			return attackable
		square[1] += 1
		var neighbors = Board.get_neighbors(square[0])
		for elem in neighbors:
			var x = int(elem[0])
			var y = int(elem[1])
			if not visited[x][y]:
				visited[x][y] = true
				if Board.is_dark(elem):
					square_queue.append([elem, square[1]])
				if Board.is_enemy(Item_Color[0], elem) and not Board.is_enemy_king(Item_Color[0], elem):
					attackable.append(elem)

func move(dest: String):
	Position = dest

func attack(enemy):
	enemy.get_damage(damage)
	if Board.distance(Position, enemy.Position) == 1:
		get_damage(enemy.damage)
	
func get_damage(damage: int):
	health -= damage

func is_alive():
	return health > 0

func _ready():
	self.texture = load("res://images/WPawn.svg") if Item_Color == "white" else load("res://images/BPawn.svg")

func _process(_delta):
	pass

