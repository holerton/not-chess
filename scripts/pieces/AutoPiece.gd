extends BasePiece
class_name AutoPiece

var current_direction: String = "NW"
var dest: Array

func set_destination(board: Board):
	var dest_array = [1, 1]
	var rand_choice = randi() % 2
	var limits = [Global.board_width, Global.board_height]
	var get_new_pos: Callable
	
	if coords[0] < Global.board_width / 2:
		dest_array[rand_choice] = limits[rand_choice]
		get_new_pos = func(ind): return randi_range(2, limits[ind])
	else:
		dest_array[rand_choice] = 1
		get_new_pos = func(ind): return randi_range(1, limits[ind] - 1)
	rand_choice = (rand_choice + 1) % 2
	
	while dest_array[rand_choice] == 1 or \
	not Board.is_dark(self.dest) or board.get_terrain(self.dest) == "Water":
		dest_array[rand_choice] = get_new_pos.call(rand_choice)
		self.dest = dest_array

func move_to_dest(board: Board):
	get_distances(board, dest)
	var route = get_route(board, dest)
	if route.is_empty():
		return coords
	return route[0]

func auto_move(board: Board):
	var reachable = get_reachable(board)
	var where_to = randi_range(0, len(reachable) - 1)
	var pos = reachable[where_to]
	return pos

func give_move_in_direction(board: Board, dir: String):
	var x = coords[0]
	var y = coords[1]
	var reachable = get_reachable(board)
	var result = []
	var append_stuff = func(mult1, mult2):
			for i in range(1, speed + 1):
				var square = [x + i * mult1, y + i * mult2]
				if square in reachable:
					result.append(square)
	match dir:
		"NW":
			append_stuff.call(-1, -1)
		"N":
			append_stuff.call(0, -1)
		"NE":
			append_stuff.call(1, -1)
		"E":
			append_stuff.call(1, 0)
		"SE":
			append_stuff.call(1, 1)
		"S":
			append_stuff.call(0, 1)
		"SW":
			append_stuff.call(-1, 1)
		"W":
			append_stuff.call(-1, 0)
	return result

func move_in_direction(board: Board):
	var directions = ["NW", "N", "NE", "E", "SE", "S", "SW", "W"]
	
	while directions[0] != current_direction:
		var dir = directions.pop_front()
		directions.push_back(dir)
	
	for dir in directions:
		var new_coords = give_move_in_direction(board, dir)
		if new_coords != []:
			var ind = randi_range(0, len(new_coords) - 1)
			current_direction = dir
			return new_coords[ind]
	return coords
