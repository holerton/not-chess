extends BasePiece
class_name Knight
## Class for a Knight. Extends BasePiece

## Creates a new Knight. Accepts two parameters: color, coords. 
## Those parameters are used in parents's constructor.
## Also sets it's range, speed, damage and textures.
func _init(color: String, coords: String):
	self.range = 1
	self.speed = 2
	self.damage = 1
	self.textures = [load("res://images/WKnight.svg") if color == "white"
	else load("res://images/BKnight.svg")]
	self.terrain_rules["Forest"] = INF
	self.terrain_rules["Marsh"] = 1
	super(color, coords, "Night")

func calc_next_turn_speed(terrain: String, weather: String, dist: int):
	super(terrain, weather, dist)
	self.speed += int(terrain == "Marsh")
