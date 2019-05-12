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

# Swipe Variables
onready var SwipeDirections = preload("res://addons/swipe-detector/directions.gd").new()

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

# Swiping

func _on_SwipeDetector_swipe_ended( gesture ):
	pass

func _on_SwipeDetector_swiped( gesture ):
	if(SwipeDirections.DIRECTION_UP == gesture.get_direction()):
		_move_pawns_up()
	else: if(SwipeDirections.DIRECTION_RIGHT == gesture.get_direction()):
		_move_pawns_right()
	else: if(SwipeDirections.DIRECTION_DOWN == gesture.get_direction()):
		_move_pawns_down()
	else: if(SwipeDirections.DIRECTION_LEFT == gesture.get_direction()):
		_move_pawns_left()


#          ▴ Up
#          |
#       [][][][]
# Left  [][][][] Right
#  <--  [][][][] -->
#       [][][][]
#          |
#          ▾ Down

func _move_pawns_up():
	pass

func _move_pawns_right():
	pass

func _move_pawns_down():
	pass

func _move_pawns_left():
	pass