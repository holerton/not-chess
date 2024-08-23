extends Control

func _ready():
	$WidthOptions.select(0)
	$HeightOptions.select(0)

func _on_submit_button_pressed():
	Global.board_width = ($WidthOptions.get_selected_items()[0] + 1) * 8
	Global.board_height = ($HeightOptions.get_selected_items()[0] + 1) * 8
	var mult = Global.board_width * Global.board_height / 64
	for piece_type in Global.limits:
		if piece_type != "King":
			Global.limits[piece_type] *= mult
	get_tree().change_scene_to_file("res://scenes/classic_mode.tscn")
	
