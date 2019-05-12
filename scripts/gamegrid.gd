extends Node2D

# Signals
signal scoreChanged

# Grid Variables
export (int) var xStart
export (int) var yStart
export (int) var offset
export (int) var numberStartingPawns
export (int) var width
export (int) var height

# Touch Variables
var first_touch = Vector2(0, 0);
var final_touch = Vector2(0, 0);
var last_direction = 0;

# Piece Variables
var possiblePawns = [
	preload("res://scenes/tile_2.tscn"),
	preload("res://scenes/tile_4.tscn")
]
var allPawns = []

func _ready():
	randomize()
	allPawns = NewArray2d()
	setup()

func NewArray2d():
	var array = []
	for i in width:
		array.append([])
		for j in height:
			array[i].append(null)
	return array

func setup():
	pass

func _process(delta):
	pass

func blank_space_on_board():
	for i in width:
		for j in height:
			if allPawns[i][j] == null:
				return true
	return false

