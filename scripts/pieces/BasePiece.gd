extends Sprite2D
class_name BasePiece
## Base class for all the Pieces.
## Contains stats, coordinates in the PieceContainer and shortname for the map

## Defines color of the piece
var color: String

## Defines coordinates of the piece in the PieceContainer
var coords: String

## Defines how many damage piece deals
var damage: int = 0

## Defines how far the piece travels
var speed: int = 0

## Defines how far the piece attacks
var range: int = 0

## Defines maximal health of the piece
var health: int = 1

## Shortname used by the map of the container
var shortname: String

## If true, piece has a special action
var special_action: bool = false

## Stores all textures for the sprite
var textures: Array = [null]

## Non-traversable terrains
var forbidden_terrains: Array = ["Water"]

## Creates new piece given its color, coordinates in the container, position in the Square and name
func _init(color: String, coords: String, name: String = "#"):
	self.color = color
	self.coords = coords
	self.position = Vector2(Global.tile_size / 2, Global.tile_size / 2)
	self.name = name
	self.shortname = color[0] + str(name)[0]
	self.texture = self.textures[self.health - 1]

## Returns BasePiece with the same properties as the self except for coordinates, which are empty
func clone() -> BasePiece:
	var other = new(color, "")
	return other

## Uses DFS to fill and return the Array with coordinates of all of the reachable squares. 
func find_reachable(board: Board) -> Array:
	var xy = board.coords_to_int(coords)
	
	var visited = []
	for i in Global.board_height + 2:
		visited.append([])
		for j in Global.board_width + 2:
			visited[i].append(false)
	visited[xy[1]][xy[0]] = true
	
	var square_queue = [[coords, 0]] ## Queue saves last visited square and distance to it
	var reachable = [coords]
	
	while not square_queue.is_empty():
		var square = square_queue.reduce(func(a, b): return a if a[1] < b[1] else b)
		square_queue.erase(square)
		## When DFS reaches the point where distance equals to speed, return result
		if square[1] >= speed: 
			return reachable
		
		square[1] += 1 ## Distance increase
		var neighbors = board.get_neighbors(square[0], 1)
		
		for elem in neighbors: ## Going through neighbors
			xy = board.coords_to_int(elem)
			
			## Marking all of the visited squares (piece travels through black squares)
			if board.is_dark(elem) and not visited[xy[1]][xy[0]]:
				visited[xy[1]][xy[0]] = true
				var terrain = board.get_terrain(elem)
				if terrain not in self.forbidden_terrains:
					var dist = calc_distance(terrain, square[1])
					## If square is empty OR an enemy king, its reachable
					if board.is_empty(elem) or board.is_enemy_king(color[0], elem):
						reachable.append(elem)
						square_queue.append([elem, dist])
					elif board.is_ally(color[0], elem):
						square_queue.append([elem, dist])
	return reachable

## Finds all squares, distance from coords to which is not greater then range
## Returns only squares, that are attackable. 
func find_attackable(board: Board):
	var xy = Board.coords_to_int(coords)
	
	var visited = []
	for i in Global.board_height + 2:
		visited.append([])
		for j in Global.board_width + 2:
			visited[i].append(false)
	visited[xy[1]][xy[0]] = true
	
	var square_queue = [[coords, 0]] ## Queue saves last visited square and distance to it
	var attackable = []
	
	while not square_queue.is_empty():
		var square = square_queue.pop_front()
		
		## When DFS reaches the point where distance equals to speed, return result
		if square[1] == range: 
			return attackable
		
		square[1] += 1 ## Distance increase
		var neighbors = Board.get_neighbors(square[0], 1)
		
		for elem in neighbors: ## Going through neighbors
			xy = Board.coords_to_int(elem)
			
			## Marking all of the visited squares (piece travels through black squares)
			if not visited[xy[1]][xy[0]]:
				visited[xy[1]][xy[0]] = true
				
				## If square is an enemy AND not an enemy king, its attackable
				if Board.is_enemy(color[0], elem) and not Board.is_enemy_king(color[0], elem):
					attackable.append(elem)
				if not Board.is_neutral(color[0], elem):
					square_queue.append([elem, square[1]])
	return attackable

## Changes coordinates to a new value
func move(dest: String) -> void:
	coords = dest

func skips_turn(terrain: String):
	return terrain == "Mountain"

## Attacks an enemy piece. If distance between them is 1, gets attacked by an enemy piece
## Returns true, if piece has a special action after an attack. Otherwise false
func attack(enemy) -> bool:
	enemy.get_damage(damage)
	if Board.distance(coords, enemy.coords) == 1:
		get_damage(enemy.damage)
	return self.special_action and is_alive()

## Decreases health by damage and changes texture, if still alive
func get_damage(damage: int) -> void:
	self.health -= damage
	if is_alive():
		self.texture = self.textures[self.health - 1]

## Returns true if health of the piece is greater then 0. Otherwise false
func is_alive():
	return health > 0

func calc_distance(terrain: String, dist: int):
	if terrain == "Mountain":
		return self.speed
	return dist
