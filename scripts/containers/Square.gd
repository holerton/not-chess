extends ColorRect
class_name Square
## Class for the square of the PieceContainer. Square can contain a BasePiece.  
## Uses ColorRect for the texture and Panel for tracking clicks.  

signal square_clicked(square: Square)

## Callable object that is executed every time the Panel detects a click
var on_click: Callable = func():
	square_clicked.emit(self)

var state: int = 0
var terrain: String = "Black"
var colors: Array = [Color.ORANGE, Color.CRIMSON]
const TERRAIN_COLORS: Dictionary = {"Plain": Color.LAWN_GREEN,
"Forest": Color.FOREST_GREEN, "Water": Color.DODGER_BLUE,
"Desert": Color.CORNSILK, "Marsh": Color.DARK_OLIVE_GREEN,
"Mountain": Color.DARK_GRAY, "Black": Color.DARK_SLATE_GRAY, "White": Color.ALICE_BLUE}

## Constructor, takes three arguments: dark, size, name.
## dark defines whether the square is bright or dark;
## size defines the size of the rectangle;
## name defines the name that is used by BasePiece.
## Also creates an invisible Panel that reads clicks
func _init(type: String, size: Vector2, name: String, signal_reciever: Callable):
	self.terrain = type
	
	square_clicked.connect(signal_reciever)
	self.set_custom_minimum_size(size)
	self.name = name
	
	var panel = Panel.new()
	panel.set_custom_minimum_size(size)
	panel.name = "Panel"
	panel.visible = false
	add_child(panel)
	
	var selection_square = ColorRect.new()
	selection_square.offset_top=45
	selection_square.set_custom_minimum_size(Vector2(size[0], size[1] * 0.1))
	selection_square.name = "Selection"
	selection_square.visible = false
	add_child(selection_square)
	selection_square.layout_mode = 2
	selection_square.anchors_preset = PRESET_CENTER

func is_empty() -> bool:
	return get_child_count() == 2

func set_action(action: Callable) -> void:
	on_click = action

func get_container_name() -> String:
	return get_parent().name

func flip_activity() -> void:
	state = Global.ACTIVE if state == Global.PASSIVE else Global.PASSIVE
	#$Selection.color = Color(Color.DARK_ORCHID, 0.7) 
	#$Selection.visible = not $Selection.visible

func flip_attacked() -> void:
	state = Global.ATTACKED if state == Global.PASSIVE else Global.PASSIVE
	#$Selection.color = Color(Color.CRIMSON, 0.7) 
	#$Selection.visible = not $Selection.visible

func get_piece() -> BasePiece:
	if not is_empty():
		return get_child(2)
	return null

## Calls on_click if Panel detects a click
func _input(event) -> void:
	var rect: Rect2 = $Panel.get_global_rect()
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if rect.has_point(event.position):
				on_click.call()

func set_terrain(type: String):
	self.terrain = type

## Changes colors during the game according to the square state
func _process(delta) -> void:
	self.color = TERRAIN_COLORS[self.terrain]
	if self.state == 0:
		$Selection.visible = false
	else:
		$Selection.visible = true
		$Selection.color = self.colors[self.state - 1]

