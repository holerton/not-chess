extends ColorRect
class_name Square
## Class for the square of the PieceContainer. Square can contain a BasePiece.  
## Uses ColorRect for the texture and Panel for tracking clicks. 

## If dark is true, ColorRect is dark-colored, if false - bright-colored
var dark: bool = true 

## If is_active is true, ColorRect changes color to active.
## Dark shade or light shade depending on the dark property 
var is_active: bool = false

## If is_attacked is true, Color Rect changes color to attacked. 
## Dark shade or light shade depending on the dark property
var is_attacked: bool = false

## Callable object that is executed every time the Panel detects a click
var on_click: Callable

## Constructor, takes three arguments: dark, size, name.
## dark defines whether the square is bright or dark;
## size defines the size of the rectangle;
## name defines the name that is used by BasePiece.
## Also creates an invisible Panel that reads clicks
func _init(dark: bool, size: Vector2, name: String):
	self.dark = dark
	self.set_custom_minimum_size(size)
	self.name = name
	var panel = Panel.new()
	panel.set_custom_minimum_size(size)
	panel.name = "Panel"
	panel.visible = false
	add_child(panel)

## Returns true if the Square doesn't contain a BasePiece, false otherwise.
func is_empty() -> bool:
	return get_child_count() == 1

## Sets a Callable object to on_action property
func set_action(action: Callable) -> void:
	on_click = action

## Sets is_active to the opposite value: false to true, true to false
func flip_activity() -> void:
	is_active = not is_active

## Sets is_attacked to the opposite value: false to true, true to false
func flip_attacked() -> void:
	is_attacked = not is_attacked

## Returns a BasePiece if Square is not empty. Otherwise returns null
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

## Changes colors during the game according to the values of dark, is_active and is_attacked
func _process(delta) -> void:
	if is_attacked:
		color = Color.MEDIUM_VIOLET_RED if dark else Color.PALE_VIOLET_RED
	elif is_active:
		color = Color.DARK_BLUE if dark else Color.BLUE
	else:
		color = Color.DARK_SLATE_GRAY if dark else Color.ALICE_BLUE
