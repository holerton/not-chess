extends Node
class_name Weather

var terrain_types: Dictionary = {}
var affected_squares: Array = []
var appearance_probabilities: Dictionary = {}
var disappearance_probabilities: Dictionary = {}
var movable: bool = false

func _init(terrain_types: Dictionary):
	self.terrain_types = terrain_types

func initial_weather():
	var changed_squares = []
	for terrain in terrain_types:
		var prob = appearance_probabilities[terrain][-1]
		for square in terrain_types[terrain]:
			var square_status = appear_or_disappear(square, prob, 0)
			if square_status:
				changed_squares.append(square)
	return changed_squares

func appear_or_disappear(square: Array, app_prob: int, dis_prob: int):
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
		var app_prob = appearance_probabilities[terrain][month]
		var dis_prob = disappearance_probabilities[terrain][month]
		for square in terrain_types[terrain]:
			var square_status = appear_or_disappear(square, app_prob, dis_prob)
			if square_status != 0:
				changed_squares.append(square)
	return changed_squares

