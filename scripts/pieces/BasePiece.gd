extends Sprite2D
class_name BasePiece
## Base class for all the Pieces.
## Contains stats, coordinates in the PieceContainer and shortname for the map

## Defines color of the piece
var color: String

## Defines coordinates of the piece in the PieceContainer
var coords: Array

## Defines how many damage piece deals
var damage: int = 0

## Defines how far the piece travels
var speed: int = 0

## Defines how far the piece attacks
var range: int = 0

## Defines maximal health of the piece
var health: int = 1

## Defines maximal speed of the piece
var max_speed: int

## Shortname used by the map of the container
var shortname: String

## If true, piece has a special action
var special_action: bool = false

## Stores all textures for the sprite
var textures: Array = [null]

## Special rules for weather-terrain combination
var terrain_weather_rules: Dictionary = {["Water", "None"]: Global.MY_INF, "Snow": 1}

## Map of distances to squares 
var distances_map: Array = []

## Creates new piece given its color, coordinates in the container, position in the Square and name
func _init(color: String, coords: Array, name: String = "#"):
	self.color = color
	self.coords = coords
	self.position = Vector2(Global.tile_size / 2, Global.tile_size / 2)
	self.name = name
	self.shortname = color + str(name)[0]
	self.textures = Global.PIECE_TEXTURES[self.shortname]
	self.texture = self.textures[self.health - 1]
	self.terrain_weather_rules["Mountain"] = self.speed
	self.max_speed = self.speed

## Returns BasePiece with the same properties as the self except for coordinates, which are empty
func clone() -> BasePiece:
	var other = new(color, [-1, -1])
	return other

## Returns mask Array filled with value
func fill_mask(value) -> Array:
	var mask = []
	for i in Global.board_height + 2:
		mask.append([])
		for j in Global.board_width + 2: 
			mask[-1].append(value.duplicate() 
			if typeof(value) == TYPE_ARRAY else value)
	return mask

## Returns an Array of reachable squares, finds them in distances_map
func get_reachable(board: Board) -> Array:
	var reachable = []
	get_distances(board)
	for entry in distances_map:
		if not board.is_ally(color, entry[0]):
			reachable.append(entry[0])
	return reachable

## Uses DFS to fill and return the Array with coordinates of all of the attackable squares.
func find_attackable(board: Board) -> Array:
	var visited = fill_mask(false)
	visited[coords[1]][coords[0]] = true
	
	var square_queue = [[coords, 0]] ## Queue saves last visited square and distance to it
	var attackable = []
	
	while not square_queue.is_empty():
		var square = square_queue.pop_front()
		
		## When DFS reaches the point where distance equals to speed, return result
		if square[1] == range: 
			return attackable
		
		square[1] += 1 ## Distance increase
		var neighbors = Board.get_neighbors(square[0])
		
		for xy in neighbors: ## Going through neighbors
			## Marking all of the visited squares (piece travels through black squares)
			if not visited[xy[1]][xy[0]]:
				visited[xy[1]][xy[0]] = true
				
				## If square is an enemy AND not an enemy king, its attackable
				if Board.is_enemy(color, xy) and \
				not Board.is_enemy_king(color, xy):
					attackable.append(xy)
				if not Board.is_neutral(color, xy):
					square_queue.append([xy, square[1]])
	return attackable

## Fills distances_map with distances to squares
func get_distances(board: Board, destination = null) -> void:
	# 0: coords, 1: where from, 2: distance
	distances_map = [[coords, [-1, -1], 0]]
	var visited = fill_mask(false)
	var distances = fill_mask(Global.MY_INF)
	distances[coords[1]][coords[0]] = 0
	var squares = [coords]
	while not squares.is_empty():
		var next_square = [-1, -1]
		var min_dist = Global.MY_INF
		for square in squares:
			if distances[square[1]][square[0]] < min_dist:
				next_square = square
				min_dist = distances[square[1]][square[0]]
		squares.erase(next_square)
		if next_square == destination or \
		(min_dist == self.speed and destination == null):
			break
		var neighbors = Board.get_neighbors(next_square)
		for xy in neighbors:
			if not visited[xy[1]][xy[0]] and Board.is_dark(xy):
				var new_dist = calc_dist_from(board, next_square, xy, min_dist)
				var current_dist = distances[xy[1]][xy[0]]
				if new_dist < current_dist:
					distances[xy[1]][xy[0]] = new_dist
					var ind = find_in_distances_map(xy)
					if ind == -1:
						distances_map.append([])
					distances_map[ind] = [xy, next_square, new_dist]
					if xy not in squares:
						squares.append(xy)
		visited[next_square[1]][next_square[0]] = true

## Changes coordinates to a new value, sets speed for the next turn
func move(dest: Array, board: Board) -> void:
	var dist = Board.distance(coords, dest)
	coords = dest
	var terrain = board.get_terrain(coords)
	var weather = board.get_weather(coords)
	calc_next_turn_speed(terrain, weather, dist)

func set_coords(pos: Array) -> void:
	self.coords = pos

## Attacks an enemy piece. If distance between them is 1, gets attacked by an enemy piece
## Returns true, if piece has a special action after an attack. Otherwise false
func attack(enemy: BasePiece) -> bool:
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
func is_alive() -> bool:
	return health > 0

## Calculates distance based on weather and terrain of from and to squares
func calc_dist_from(board: Board, from: Array, to: Array, dist: int) -> int:
	if board.is_empty(to) or board.is_enemy_king(color, to) or \
	board.is_ally(color, to): 
		var inc = 1
		var terrain: String = board.get_terrain(to)
		var weather: String = board.get_weather(to)
		if calc_penalty(terrain, weather) >= Global.MY_INF:
			return Global.MY_INF
		if from != coords:
			terrain = board.get_terrain(from)
			weather = board.get_weather(from)
			inc += calc_penalty(terrain, weather)
		return dist + inc
	else:
		return Global.MY_INF

## Returns penalty based on weather and terrain of the square
func calc_penalty(terrain: String, weather: String) -> int:
	return terrain_weather_rules.get([terrain, weather], 0) + \
	terrain_weather_rules.get(terrain, 0) + terrain_weather_rules.get(weather, 0)

## Calculates next turn speed based on the square the piece landed on
func calc_next_turn_speed(terrain: String, weather: String, dist: int) -> void:
	var dec = calc_penalty(terrain, weather) - \
	(terrain_weather_rules["Snow"] 
	if weather == "Snow" and dist < self.speed else 0)
	self.speed = self.max_speed - dec

## Increases self.speed
func skip_turn() -> void:
	self.speed = min(self.speed + self.max_speed, self.max_speed)

## Returns route to a destination, finding it from distances_map
func get_route(board: Board, to: Array) -> Array:
	var index = find_in_distances_map(to)
	if index == -1 or to == coords:
		return []
	var route = [to]
	var parent = distances_map[index][1]
	while parent != coords:
		route.append(parent)
		parent = distances_map[find_in_distances_map(parent)][1]
	route.reverse()
	return route
	
func find_in_distances_map(xy: Array):
	for i in range(len(distances_map)):
		if distances_map[i][0] == xy:
			return i
	return -1
