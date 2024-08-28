extends Weather
class_name Snow

func _init(terrain_types: Dictionary):
	super(terrain_types)
	self.appearance_probabilities = [
	95, 99, 99, 95, 50, 30, 20, 10, 5, 0, 0, 0, 7, 25, 65, 85
	]
	self.disappearance_probabilities = [
	2, 0, 0, 0, 4, 6, 8, 14, 20, 25, 30, 25, 12, 6, 5, 4
	]
	self.name = "Snow"
	self.initial_probability = 85
