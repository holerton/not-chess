extends Node
class_name Weather

var terrain_types: Dictionary = {}
var affected_squares: Array = []
var appearance_probabilities: Array = []
var disappearance_probabilities: Array = []
var movable: bool = false
var initial_probability: int = 0

func _init(terrain_types: Dictionary):
	self.terrain_types = terrain_types

func initial_weather():
	var changed_squares = []
	for terrain in terrain_types:
		for square in terrain_types[terrain]:
			var square_status = appear_or_disappear(square, 
			initial_probability, 0)
			if square_status:
				changed_squares.append(square)
	return changed_squares

func appear_or_disappear(square: String, app_prob: int, dis_prob: int):
	var status = 0
	if square in affected_squares:
		var chance = randi_range(1, 100)
		if chance <= dis_prob:
			status = -1
			affected_squares.erase(square)
	if square not in affected_squares:
		var chance = randi_range(1, 100)
		if chance <= app_prob:
			status += 1
			affected_squares.append(square)
	return status

func change_weather(month: int):
	var changed_squares = []
	for terrain in terrain_types:
		for square in terrain_types[terrain]:
			var square_status = appear_or_disappear(square,
			appearance_probabilities[month], disappearance_probabilities[month])
			if square_status != 0:
				changed_squares.append(square)
	return changed_squares

