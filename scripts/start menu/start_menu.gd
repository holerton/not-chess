extends Control

func _ready():
	$ItemList.select(0)

func _on_submit_pressed():
	var height = $Height.get_value()
	var width = $Width.get_value()
	var game_mode = $ItemList.get_selected_items()
	var next_scene = "res://scenes/" + ("classic_mode.tscn" if game_mode[0] == 0
	else "natural_mode.tscn")
	
	if (width - height) % 2 == 0:
		var parity = width % 2
		var max_width = 30 - parity # if width is even, 30, if odd - 29
		var max_height = 18 - parity
		var min_width = 6 - parity
		var min_height = 6 - parity
		
		Global.board_width = max(min(width, max_width), min_width)
		Global.board_height = max(min(height, max_height), min_height)
		get_tree().change_scene_to_file(next_scene)
