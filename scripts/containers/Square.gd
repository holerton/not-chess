extends ColorRect
class_name Square
## Class for the square of the PieceContainer. Square can contain a BasePiece.  
## Uses ColorRect for the texture and Panel for tracking clicks.  

signal square_clicked(square: Square)

## Callable object that is executed every time the Panel detects a click
var on_click: Callable = func():
	square_clicked.emit(self)

var state: int = 0

## Constructor, takes three arguments: dark, size, name.
## dark defines whether the square is bright or dark;
## size defines the size of the rectangle;
## name defines the name that is used by BasePiece.
## Also creates an invisible Panel that reads clicks
func _init(dark: bool, size: Vector2, name: String, signal_reciever: Callable):
	if dark:
		self.colors = [Color.DARK_SLATE_GRAY, Color.DARK_BLUE, Color.MEDIUM_VIOLET_RED]
	else:
		self.colors = [Color.ALICE_BLUE, Color.BLUE, Color.PALE_VIOLET_RED]

	square_clicked.connect(signal_reciever)
	self.container_name = get_parent().name 
	self.set_custom_minimum_size(size)
	self.name = name
	var panel = Panel.new()
	panel.set_custom_minimum_size(size)
	panel.name = "Panel"
	panel.visible = false
	add_child(panel)

func is_empty() -> bool:
	return get_child_count() == 1

func set_action(action: Callable) -> void:
	on_click = action

func flip_activity() -> void:
	state = Global.ACTIVE if state == Global.PASSIVE else Global.PASSIVE

func flip_attacked() -> void:
	state = Global.ATTACKED if state == Global.PASSIVE else Global.PASSIVE

func get_piece() -> BasePiece:
	if not is_empty():
		return get_child(1)
	return null

## Calls on_click if Panel detects a click
func _input(event) -> void:
	var rect: Rect2 = $Panel.get_global_rect()
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if rect.has_point(event.position):
				on_click.call()

## Changes colors during the game according to the square state
func _process(delta) -> void:
	self.color = self.colors[self.state]
