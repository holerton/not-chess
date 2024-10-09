extends Control
class_name LoadScreen

const target_scene_path = "res://scenes/natural_mode.tscn"
var started = false

@onready var progress_bar : ProgressBar = $ProgressBar

func on_update_status(value: float):
	progress_bar.value = (value * 100)

func _ready() -> void:
	Global.load_screen = self

func _process(_delta):
	if not started:
		started = true
		var terrain = Terrain.new()
		terrain.randomize_terrain([10, 17, 22, 25, 28, 30])
		var finished = false
		while not finished:
			finished = terrain.get_next_block()
			await Signal(self, "draw")
		terrain.fill_last_spots()
		Global.terrain_map = terrain.terrains
		get_tree().change_scene_to_file(target_scene_path)
	else:
		queue_redraw()
