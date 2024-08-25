extends Weather
class_name Ice

func _init(terrain_types: Dictionary):
	super(terrain_types)
	self.appearance_probabilities = [70, 88, 96, 96, 40, 30, 5, 1,
	1, 0, 0, 0, 1, 8, 24, 50]
	self.disappearance_probabilities = [6, 0, 0, 0, 15, 25, 60, 
	80, 99, 99, 99, 75, 50, 30, 15]
	self.name = "Ice"
	self.initial_probability = 50
