extends BasePiece
class_name AutoPiece

var gen = RandomNumberGenerator.new()
var current_direction: String = "NW"

func auto_move(board: Board):
	var reachable = find_reachable(board)
	var where_to = gen.randi_range(0, len(reachable) - 1)
	var pos = reachable[where_to]
	return pos

func give_move_in_direction(board: Board, dir: String):
	var xy = Board.coords_to_int(coords)
	var x = xy[0]
	var y = xy[1]
	var reachable = find_reachable(board)
	var result = []
	var append_stuff = func(mult1, mult2):
			for i in range(1, speed + 1):
				var square = Board.int_to_coords([x + i * mult1, y + i * mult2])
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

func move_in_direction(board):
	var directions = ["NW", "N", "NE", "E", "SE", "S", "SW", "W"]
	
	while directions[0] != current_direction:
		var dir = directions.pop_front()
		directions.push_back(dir)
	
	for dir in directions:
		var new_coords = give_move_in_direction(board, dir)
		if new_coords != []:
			var ind = gen.randi_range(0, len(new_coords) - 1)
			current_direction = dir
			return new_coords[ind]
	return coords
