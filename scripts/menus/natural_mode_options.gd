extends Control

var current_width: int = 8
var current_height: int = 8

func _ready():
	$PawnLimit.select(1)
	$ArmyLimit.select(1)

func _on_submit_button_pressed():
	if (current_width - current_height) % 2 == 0:
		var parity = current_width % 2
		var max_width = 30 - parity # if width is even, 30, if odd - 29
		var max_height = 18 - parity
		var min_width = 6 - parity
		var min_height = 6 - parity
		
		Global.board_width = max(min(current_width, max_width), min_width)
		Global.board_height = max(min(current_height, max_height), min_height)
		
		var ind = $PawnLimit.get_selected_items()[0]
		Global.limits["Pawn"] = int($PawnLimit.get_item_text(ind))
		
		ind = $ArmyLimit.get_selected_items()[0]
		var army_limit = int($ArmyLimit.get_item_text(ind))
		
		for piece_type in Global.limits:
			if piece_type != "King" and piece_type != "Pawn":
				Global.limits[piece_type] = army_limit
		
		get_tree().change_scene_to_file("res://scenes/natural_mode.tscn")

func update_limits(side: int):
	var pawn_limits = [str(3 * side / 4), str(side), str(5 * side / 4)]
	var army_limits = [str(side / 8), str(side / 4), str(3 * side / 8)]
	for i in range(3):
		$PawnLimit.set_item_text(i, pawn_limits[i])
		$ArmyLimit.set_item_text(i, army_limits[i])

func _on_size_changed():
	current_width = $Width.get_value() if $Width.get_value() > 0 else current_width
	current_height =$Height.get_value() if $Height.get_value() > 0 else current_height
	update_limits((current_height + current_width) / 2)
