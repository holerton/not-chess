extends Node

var board_width: int = 8
var board_height: int = 8
var tile_size: int = 50

const PASSIVE = 0
const ACTIVE = 1
const ATTACKED = 2

var teams = {-1: "b", 0: "n", 1: "w"}
