extends BasePiece
class_name Bishop
## Class for a Bishop. Extends BasePiece

## Creates a new Bishop. Accepts two parameters: color and coords. 
## Those parameters are used in parent's constructor.
## Also sets it's range, speed, damage and textures.
func _init(color: String, coords: Array):
	self.range = 2
	self.speed = 1
	self.damage = 1
	self.terrain_weather_rules["Desert"] = self.speed
	self.terrain_weather_rules["Snow"] = 0
	super(color, coords, "Bishop")

func find_attackable(board: Board):
	if board.get_terrain(coords) == "Forest":
		return []
	return super(board)
