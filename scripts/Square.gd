extends ColorRect

@export var dark: bool = true	
@export var is_active: bool = false
@export var is_attacked: bool = false
var on_click: Callable

func set_action(action: Callable):
	on_click = action

func flip_activity():
	is_active = not is_active

func flip_attacked():
	is_attacked = not is_attacked

func _input(event):
	var rect: Rect2 = $Panel.get_global_rect()
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if rect.has_point(event.position):
				on_click.call()

func is_empty():
	return get_child_count() == 1

func _ready():
	$Panel.set_custom_minimum_size(self.size)

func _process(delta):
	if is_attacked:
		color = Color.MEDIUM_VIOLET_RED if dark else Color.PALE_VIOLET_RED
	elif is_active:
		color = Color.DARK_BLUE if dark else Color.BLUE
	else:
		color = Color.DARK_SLATE_GRAY if dark else Color.ALICE_BLUE
