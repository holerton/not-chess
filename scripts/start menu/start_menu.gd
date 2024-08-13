extends Control

func _on_submit_pressed():
	var height = $Height.get_value()
	var width = $Width.get_value()
	if (width - height) % 2 == 0:
		Global.board_width = width
		Global.board_height = height
		get_tree().change_scene_to_file("res://scenes/gui.tscn")
		
