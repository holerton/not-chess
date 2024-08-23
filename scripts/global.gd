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

const TERRAIN_COLORS: Dictionary = {"Plain": Color.LAWN_GREEN,
"Forest": Color.FOREST_GREEN, "Water": Color.DODGER_BLUE,
"Desert": Color.CORNSILK, "Marsh": Color.DARK_OLIVE_GREEN,
"Mountain": Color.DARK_GRAY, "Black": Color.DARK_SLATE_GRAY, "White": Color.ALICE_BLUE}

func _ready():
	set_textures()

func set_textures():
	var terrains = ["Plain", "Forest", "Water", "Desert", "Marsh", "Mountain"]
	
	for terrain in terrains:
		TERRAIN_TEXTURES[terrain] = load("res://images/terrains/%s.png" % terrain)
	
	TERRAIN_TEXTURES["Black"] = create_gradient(Color.DARK_SLATE_GRAY)
	TERRAIN_TEXTURES["White"] = create_gradient(Color.ALICE_BLUE)

func create_gradient(color: Color):
	var grad = GradientTexture2D.new()
	grad.width = tile_size
	grad.height = tile_size
	grad.gradient = Gradient.new()
	grad.gradient.set_color(0, color)
	grad.gradient.remove_point(1)
	return grad
