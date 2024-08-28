extends Node
class_name Climate

var weathers: Array = []

func _init(terrain_map: Dictionary):
	self.weathers.append(Ice.new({"Water": terrain_map["Water"]}))
	self.weathers.append(Snow.new({"Mountain": terrain_map["Mountain"]}))

func initial_climate():
	var affected_squares: Dictionary = {}
	for weather in weathers:
		var changed_squares = weather.initial_weather()
		if weather.name in affected_squares:
			affected_squares[weather.name].append_array(changed_squares)
		else:
			affected_squares[weather.name] = changed_squares
	return affected_squares

func calc_climate(month: int):
	var affected_squares: Dictionary = {}
	for weather in weathers:
		var changed_squares = weather.change_weather(month)
		if weather.name in affected_squares:
			affected_squares[weather.name].append_array(changed_squares)
		else:
			affected_squares[weather.name] = changed_squares
	return affected_squares
