extends Control

func _ready():
	$ItemList.select(0)

func _on_submit_pressed():
	var height = $Height.get_value()
	var width = $Width.get_value()
	var game_mode = $ItemList.get_selected_items()
	var next_scene = "res://scenes/" + ("classic_mode.tscn" if game_mode[0] == 0 else "natural_mode.tscn")
	
	if (width - height) % 2 == 0:
		Global.board_width = width if width < 24 else 24
		Global.board_height = height if width < 18 else 18
		get_tree().change_scene_to_file(next_scene)
		
