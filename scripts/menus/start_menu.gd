extends Control

func _ready():
	$GameModes.select(0)

func _on_submit_pressed():
	var ind = $GameModes.get_selected_items()[0]
	var game_mode = $GameModes.get_item_text(ind).to_lower()
	var next_scene = "res://scenes/%s_mode_options.tscn" % game_mode 
	get_tree().change_scene_to_file(next_scene)
