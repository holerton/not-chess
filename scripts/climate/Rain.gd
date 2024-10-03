extends Weather
class_name Rain

var appear_num: Array = []
var disappear_num: Array = []


func _init(terrain_map):
	super(terrain_map)
	var s = Global.board_height * Global.board_width
	self.name = "Rain"
	self.appear_num = [0, 0, 0, 0, max(s / 33 - 2, 1), max(s / 29 - 2, 1),
	max(s / 22 - 2, 1), s / 10, s / 22, 0, s / 18 - 1,
	max(s / 22 - 2, 1), s / 17 - 1, s / 7 + 1, s / 17 - 1, 0]
	
	self.disappear_num = [0, 0, 0, 0, 0, max(s / 33 - 2, 1), max(s / 29 - 2, 1),
	max(s / 22 - 2, 1), s / 10 - 1, s / 22 + 1, 0, s / 18 - 1, 
	max(s / 22 - 2, 1), 0, s / 7 + s / 17, s / 17 - 1]

func initial_weather():
	return []

func change_weather(month):
	var deleted_rains = []
	var added_rains = []
	for i in range(disappear_num[month]):
		var ind = randi() % len(self.affected_squares)
		deleted_rains.append(affected_squares.pop_at(ind))
	
	for i in range(len(affected_squares)):
		deleted_rains.append(affected_squares[i])
		var new_square = move_weather(affected_squares[i])
		if new_square in deleted_rains:
			deleted_rains.erase(new_square)
		affected_squares[i] = new_square
		added_rains.append(new_square)
	
	var rains_left = appear_num[month]
	
	var lim1 = max(min(rains_left, len(terrain_types["Mountain"])), 0)
	var lim2 = max(min(rains_left - lim1, len(terrain_types["Water"])), 0)
	var lim3 = max(rains_left - lim1 - lim2, 0)

	var limits = [lim1, lim2, lim3]

	var terrains = ["Mountain", "Water", "Plain"]
	var num = 0
	
	for lim in limits:
		for i in range(lim):
			var terrain = terrains[num]
			var ind = randi() % len(terrain_types[terrain])
			var square = terrain_types[terrain][ind]
			added_rains.append(square)
			affected_squares.append(square)
			if square in deleted_rains:
				deleted_rains.erase(square)
		num += 1
	# print("Deleted: ", deleted_rains)
	# print("Added: ", added_rains)
	# print("Affected: ", affected_squares)
	added_rains.append_array(deleted_rains)
	# print("Changed: ", added_rains)
	return added_rains

func move_weather(pos: String):
	var neighbors = Board.get_neighbors(pos)
	var ind = randi() % len(neighbors)
	return neighbors[ind]

