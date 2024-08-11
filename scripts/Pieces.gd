@tool
extends EditorPlugin


func _enter_tree():
	# Initialization of the plugin goes here.
	add_custom_type("Pawn", "Sprite2D", preload("res://scripts/pieces/Pawn.gd"), preload("res://images/WPawn.svg"))
	add_custom_type("King", "Sprite2D", preload("res://scripts/pieces/King.gd"), preload("res://images/WKing.svg"))
	add_custom_type("Bishop", "Sprite2D", preload("res://scripts/pieces/Bishop.gd"), preload("res://images/WBishop.svg"))
	add_custom_type("Knight", "Sprite2D", preload("res://scripts/pieces/Knight.gd"), preload("res://images/WKnight.svg"))
	add_custom_type("Queen", "Sprite2D", preload("res://scripts/pieces/Queen.gd"), preload("res://images/WQueen.svg"))
	add_custom_type("Rook", "Sprite2D", preload("res://scripts/pieces/Rook.gd"), preload("res://images/WRook.svg"))
	add_custom_type("Board", "FlowContainer", preload("res://scripts/Board.gd"), preload("res://images/WKing.svg"))


func _exit_tree():
	# Clean-up of the plugin goes here.
	remove_custom_type("Pawn")
	remove_custom_type("King")
	remove_custom_type("Bishop")
	remove_custom_type("Knight")
	remove_custom_type("Queen")
	remove_custom_type("Rook")
