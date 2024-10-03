extends Node
class_name Climate

var weathers: Array = []

func _init(terrain_map: Dictionary):
	self.weathers.append_array([Snow.new(terrain_map), Rain.new(terrain_map)])

func initial_climate():
	var affected_squares: Dictionary = {}
	for weather in weathers:
		var changed_squares = weather.initial_weather()
		if weather.name == "Snow":
			affected_squares[weather.name] = changed_squares
		else:
			print(changed_squares)
	return affected_squares

func calc_climate(month: int):
	var affected_squares: Dictionary = {}
	for weather in weathers:
		var changed_squares = weather.change_weather(month)
		if weather.name == "Rain":
			for sq in changed_squares:
				if sq in affected_squares["Snow"]:
					print(sq, " Heavy Snow")
				if changed_squares.count(sq) > 1:
					print(sq, " Thunderstorm")
		else:
			affected_squares[weather.name] = changed_squares
	return affected_squares
