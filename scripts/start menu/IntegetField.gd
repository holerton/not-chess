extends LineEdit
class_name IntegerField

var regex = RegEx.new()
var oldtext = ""

func _ready():
	regex.compile("^[0-9]*$")
	text_changed.connect(_on_IntegerField_text_changed)

func _on_IntegerField_text_changed(new_text):
	if regex.search(new_text):
		oldtext = new_text
	else:
		text = oldtext
	set_caret_column(text.length())

func get_value():
	return abs(int(text))
