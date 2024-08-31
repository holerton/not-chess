extends Node

var board_width: int = 8
var board_height: int = 8
var tile_size: int = 50

## Amount of available pieces
var piece_num: int = 4

## Square states
const PASSIVE = 0
const ACTIVE = 1
const ATTACKED = 2

var teams = {-1: "b", 0: "n", 1: "w"}

var limits = {'Pawn': 8, "Night": 2, "Bishop": 2, "Rook": 2, "King": 1}

var TERRAIN_TEXTURES: Dictionary = {}

const TERRAIN_COLORS: Dictionary = {
"Plain": Color.LAWN_GREEN, "Forest": Color.FOREST_GREEN, 
"Water": Color.DODGER_BLUE, "Desert": Color.CORNSILK, 
"Marsh": Color.DARK_OLIVE_GREEN, "Mountain": Color.DARK_GRAY, 
"Black": Color.DARK_SLATE_GRAY, "White": Color.ALICE_BLUE 
}

func _ready():
	set_textures()

func set_textures():
	var terrains = ["Plain", "Forest", "Water", "Desert", "Marsh", "Mountain"]
	for terrain in terrains:
		TERRAIN_TEXTURES[terrain] = {}
		TERRAIN_TEXTURES[terrain]["None"] = load("res://images/terrains/%s.png" 
		% terrain)
		TERRAIN_TEXTURES[terrain]["Snow"] = create_gradient(TERRAIN_COLORS[terrain])
	
	TERRAIN_TEXTURES["Black"] = {} 
	TERRAIN_TEXTURES["Black"]["None"] = create_gradient(Color.DARK_SLATE_GRAY)
	TERRAIN_TEXTURES["White"] = {} 
	TERRAIN_TEXTURES["White"]["None"] = create_gradient(Color.ALICE_BLUE)

func create_gradient(color: Color) -> GradientTexture2D:
	var rect_texture = GradientTexture2D.new()
	rect_texture.width = tile_size
	rect_texture.height = tile_size
	rect_texture.gradient = Gradient.new()
	rect_texture.gradient.set_color(0, color)
	rect_texture.gradient.remove_point(1)
	return rect_texture
