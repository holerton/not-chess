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
func find_reachable() -> Array:
	var xy = Board.coords_to_int(coords)
	
	var visited = []
	for i in Global.board_height + 2:
		visited.append([])
		for j in Global.board_width + 2:
			visited[i].append(false)
	visited[xy[0]][xy[1]] = true
	
	var square_queue = [[coords, 0]] ## Queue saves last visited square and distance to it
	var reachable = [coords]
	
	while not square_queue.is_empty():
		var square = square_queue.pop_front()
		
		## When DFS reaches the point where distance equals to speed, return result
		if square[1] == speed: 
			return reachable
		
		square[1] += 1 ## Distance increase
		var neighbors = Board.get_neighbors(square[0], 1)
		
		for elem in neighbors: ## Going through neighbors
			xy = Board.coords_to_int(elem)
			
			## Marking all of the visited squares (piece travels through black squares)
			if Board.is_dark(elem) and not visited[xy[0]][xy[1]]:
				visited[xy[0]][xy[1]] = true
				
				## If square is empty OR an enemy king, its reachable
				if Board.is_empty(elem) or Board.is_enemy_king(color[0], elem):
					reachable.append(elem)
					square_queue.append([elem, square[1]])
				elif Board.is_ally(color[0], elem):
					square_queue.append([elem, square[1]])
	return reachable

## Finds all squares, distance from coords to which is not greater then range
## Returns only squares, that are attackable. 
func find_attackable():
	var neighbors = Board.get_neighbors(coords, range)
	var attackable = []
	for neighbor in neighbors:
		if Board.is_enemy(color[0], neighbor) and not Board.is_enemy_king(color[0], neighbor):
			attackable.append(neighbor)
	return attackable

## Changes coordinates to a new value
func move(dest: String) -> void:
	coords = dest

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
