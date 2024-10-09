extends Node
class_name Terrain
## Terrain generation

var terrains: Dictionary = {"Plain": [], "Forest": [], "Water": [], 
"Desert": [], "Marsh": [], "Mountain": []}
var terrain_names: Array = ["Plain", "Forest", "Water", "Desert", "Marsh", "Mountain"]
signal update_status(value)
var terrain_blocks: Array
var full_board: Array
var all_blocks: int
## Returns neighbors of a given square on a component
func get_neighbors(component: Array, xy: Array) -> Array:
	var x = xy[0]
	var y = xy[1]
	var all_neighbors = [[x, y - 1, true], [x + 1, y, true],
	[x, y + 1, true], [x - 1, y, true]]
	var result = []
	for neighbor in all_neighbors:
		if neighbor in component:
			result.append(neighbor)
	return result

## Returns all reachable squares from xy on component
func dfs(component: Array, xy: Array) -> Array:
	var visited = []
	visited.resize(len(component))
	visited.fill(false)
	var ind = component.find(xy)
	visited[ind] = true
	
	var reachable = [xy]
	var queue = [xy]
	while not queue.is_empty():
		var top = queue.pop_front()
		var neighbors = get_neighbors(component, top)
		for neighbor in neighbors:
			ind = component.find(neighbor)
			if not visited[ind] and neighbor[2]:
				visited[ind] = true
				reachable.append(neighbor)
				queue.append(neighbor)
	
	return reachable

## Places a terrain and calculates difference in amount of components
func component_diff(component: Array, xy: Array) -> int:
	var neighbors = get_neighbors(component, xy)
	var component_tmp = component.duplicate(true)
	var ind = component_tmp.find(xy)
	component_tmp[ind][2] = false
	var diff = -1
	while not neighbors.is_empty():
		diff += 1
		var from = neighbors.pop_front()
		var dfs_from = dfs(component_tmp, from)
		for point in dfs_from:
			if point in neighbors:
				neighbors.erase(point)
	return diff

## Returns the square with minimal component difference
func find_best_square(component: Array, options: Array) -> Array:
	var min_diff = 4
	var diffs = []
	for option in options:
		var new_diff = component_diff(component, option)
		if new_diff < min_diff:
			min_diff = new_diff
		diffs.append(new_diff)
	var best = []
	for i in range(len(options)):
		if diffs[i] == min_diff:
			best.append(options[i])
	if best.is_empty():
		return []
	
	return best[randi() % len(best)]

## Fills a block with given terrain on component
func fill_terrain_block(full_board: Array, component: Array, num: int, terrain: String):
	var visited = []
	var ind = 0
	visited.resize(len(component))
	visited.fill(false)
	visited[ind] = true
	var options = [component[ind]]
	var block_squares = []
	for i in range(num):
		var new_square = find_best_square(component, options)
		if new_square.is_empty():
			return false
		block_squares.append(new_square.duplicate(true))
		var neighbors = get_neighbors(component, new_square)
		ind = component.find(new_square)
		component[ind][2] = false
		
		for neighbor in neighbors:
			ind = component.find(neighbor)
			if not visited[ind]:
				visited[ind] = true
				options.append(neighbor)
		options.erase(new_square)
		
		terrains[terrain].append(new_square)
	
	for sq in block_squares:
		ind = full_board.find(sq)
		full_board[ind][2] = false
	return true

## Returns separate components of a board
func get_components(component: Array):
	var component_tmp = component.duplicate(true)
	var components = []
	var ind = 0
	while true:
		while not component_tmp[ind][2]:
			ind += 1
			if ind == len(component_tmp):
				return components
		var new_component = dfs(component_tmp, component_tmp[ind])
		components.append(new_component.duplicate(true))
		for square in new_component:
			var j = component_tmp.find(square)
			component_tmp[j][2] = false

## Returns terrain blocks
func get_blocks(k_avg: float, k_var: float, total: int):
	var list = []
	var squares_left = total
	while squares_left > 0:
		var new_num = randfn(k_avg, k_var)
		var next_block = max(min(round(total / new_num), squares_left), 1)
		squares_left -= next_block
		list.append(next_block)
	return list

## Returns lengths of terrain blocks
func calc_block_lengths(cum_weights: Array):
	var board_size = Global.board_height * Global.board_width

	var total_weight = cum_weights[-1]
	var total_squares = [0, 0, 0, 0, 0, 0]
	for i in range(board_size):
		var rand_num = randi() % total_weight
		for j in range(6):
			if rand_num < cum_weights[j]:
				total_squares[j] += 1
				break
	
	return total_squares

## Sets random terrain
func randomize_terrain(cum_weights: Array):
	update_status.connect(Global.load_screen.on_update_status)
	var block_lengths = calc_block_lengths(cum_weights)
	var board_size = Global.board_height * Global.board_width
	var terrains = ["Plain", "Forest", "Water", "Desert", "Marsh", "Mountain"]
	
	var k_min = [log(board_size) - 2, log(board_size) - 3, log(board_size) - 3,
	log(board_size) - 4, log(board_size) - 4, log(board_size) - 4]
	
	var k_max = [board_size / 16.0, board_size / 10.0, board_size / 10.0,
	board_size / 32.0, board_size / 32.0, board_size / 32.0, board_size / 32.0]
	
	terrain_blocks = []
	all_blocks = 0
	for i in range(6):
		var k_avg = (k_min[i] + k_max[i]) / 2.0
		var k_var = (k_max[i] - k_avg) / 3.0
		var new_blocks = get_blocks(k_avg, k_var, block_lengths[i])
		terrain_blocks.append(new_blocks)
		all_blocks += len(terrain_blocks[-1])
	
	## Full board consists of squares. 
	## Every square is defined by coordinates and true/false value
	## True, if square doesn't have a terrain. False otherwise.
	full_board = []
	for i in range(1, Global.board_height + 1):
		for j in range(1, Global.board_width + 1):
			full_board.append([j, i, true])
	

func get_next_block(): 
	var block_placed = true
	var sum_len = terrain_blocks.reduce(
		func(accum, block): return accum + len(block), 0
	)
	if sum_len == 0:
		update_status.emit(1.0)
		return true
	var ind = randi() % 6
	while terrain_blocks[ind].is_empty():
		ind = randi() % 6
	
	var block_len = terrain_blocks[ind][0]
	terrain_blocks[ind].erase(block_len)
	var components = get_components(full_board)
	for component in components:
		if len(component) >= block_len:
			block_placed = fill_terrain_block(full_board, component,
			block_len, terrain_names[ind])
			sum_len -= 1
			update_status.emit(float(all_blocks - sum_len) / all_blocks)
			return false
	return true

func fill_last_spots():
	var comps = get_components(full_board)
	for comp in comps:
		var new_terrain = terrain_names[randi() % 6]
		fill_terrain_block(full_board, comp, len(comp), new_terrain)
	update_status.emit(1.0)
	return
