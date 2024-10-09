extends Control

var current_width: int = 8
var current_height: int = 8

func _ready():
	$PawnLimit.select(1)
	$ArmyLimit.select(1)

func _on_submit_button_pressed():
	if (current_width - current_height) % 2 == 0:
		var avg_side = (current_width + current_height) / 2
		var pawn_limits = [3 * avg_side / 4, avg_side, 5 * avg_side / 4]
		var army_limits = [avg_side / 8, avg_side / 4, 3 * avg_side / 8]
		
		var parity = current_width % 2
		var max_width = 30 - parity # if width is even, 30, if odd - 29
		var max_height = 18 - parity
		var min_width = 6 - parity
		var min_height = 6 - parity
		
		Global.board_width = max(min(current_width, max_width), min_width)
		Global.board_height = max(min(current_height, max_height), min_height)
		
		var ind = $PawnLimit.get_selected_items()[0]
		Global.limits["Pawn"] = pawn_limits[ind]
		
		ind = $ArmyLimit.get_selected_items()[0]
		
		for piece_type in Global.limits:
			if piece_type != "King" and piece_type != "Pawn":
				Global.limits[piece_type] = army_limits[ind]
		
		get_tree().change_scene_to_file("res://scripts/menus/loading_scene.tscn")

func _on_size_changed():
	current_width = $Width.get_value() if $Width.get_value() > 0 else current_width
	current_height =$Height.get_value() if $Height.get_value() > 0 else current_height
