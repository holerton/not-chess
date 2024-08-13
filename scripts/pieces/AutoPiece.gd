extends BasePiece
class_name AutoPiece

var gen = RandomNumberGenerator.new()

func auto_move():
	var reachable = find_reachable()
	var where_to = gen.randi_range(0, len(reachable) - 1)
	var pos = reachable[where_to]
	return pos
