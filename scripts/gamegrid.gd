extends Node2D

# Signals
signal scoreChanged

# External Grid Variables
export (PackedScene) var gamegrid;
export (Vector2) var gridPosition
export (Vector2) var gridSize
export (Vector2) var tileSize
export (bool) var performUnitTests

# Internal Grid Varibles
var grid
var tilepostion : Vector2

# Swipe Variables
onready var SwipeDirections = preload("res://addons/swipe-detector/directions.gd").new()

# Pawn Variables
var possiblePawns = [
	preload("res://scenes/tile_2.tscn"),
	preload("res://scenes/tile_4.tscn")
]

var allPawns = []

# Example of 4x4 grid
# ------------------> x
# |              ▴ Up
# |              |
# |         [A][B][C][D]
# |   Left  [E][F][G][H] Right
# |    <--  [I][J][K][L] -->
# |         [M][N][O][P]
# ▾              |
# y              ▾ Down

const kLeftDirection : int = 0
const kUpDirection : int = 1
const kRightDirection : int = 2
const kDownDirection : int = 3

#########################################################################################################

# Setting up

func _ready():
	randomize()
	allPawns = NewArray2d(gridSize)
	createGrid()

func createGrid():
	grid = gamegrid.instance()
	grid.position = gridPosition
	add_child(grid)
	addRandomPawn()
	if performUnitTests:
		unitTests()

# 2048 Game Mechanics
func squeezeAndMerge(direction: int) -> void:
	var addNewTileAfterMove : bool = false
	var iterationLimit = 0
	if direction == kLeftDirection or direction == kRightDirection:
		iterationLimit = gridSize.x
	else: if direction == kUpDirection or direction == kDownDirection:
		iterationLimit = gridSize.y
	var printString : String
	for i in iterationLimit:
		var tilesetCoordinates = []
		match direction:
			kLeftDirection:
				tilesetCoordinates = getCoordinatesOfRowWithYEqual(i)
			kUpDirection:
				tilesetCoordinates = getCoordinatesOfColumnWithXEqual(i)
			kRightDirection:
				tilesetCoordinates = getCoordinatesOfReverseRowWithYEqual(i)
			kDownDirection:
				tilesetCoordinates = getCoordinatesOfReverseColumnWithXEqual(i)
		#####################################
		var somethingChanged  = false
		for idx in range(tilesetCoordinates.size()): # start at second element (via currentPointer) and shift upward
			var currentChanged = false
			var currentPointer = idx - 1
			if !(null == allPawns[tilesetCoordinates[idx].x][tilesetCoordinates[idx].y]): # only move non-empty tiles
				while currentPointer >= 0 && null == allPawns[tilesetCoordinates[currentPointer].x][tilesetCoordinates[currentPointer].y]:
					#### TODO
					# - put in separate function
					#var currentPawn = allPawns[tilesetCoordinates[currentPointer+1].x][tilesetCoordinates[currentPointer+1].y]
					#allPawns[tilesetCoordinates[currentPointer].x][tilesetCoordinates[currentPointer].y] = currentPawn
					#allPawns[tilesetCoordinates[currentPointer+1].x][tilesetCoordinates[currentPointer+1].y] = null
					currentPointer -= 1
					somethingChanged = true
					currentChanged = true
				if currentChanged:
					currentPointer += 1 # we have to revert the last decremt operation that was performed, as that was the cause for leaving the while-loop
					var currentPawn = allPawns[tilesetCoordinates[idx].x][tilesetCoordinates[idx].y]
					# do the animation
					currentPawn.move(gridToPixelPosition(Vector2(tilesetCoordinates[currentPointer].x, tilesetCoordinates[currentPointer].y)))
					# Copy over the tile object from old position to new position
					allPawns[tilesetCoordinates[currentPointer].x][tilesetCoordinates[currentPointer].y] = currentPawn
					allPawns[tilesetCoordinates[idx].x][tilesetCoordinates[idx].y] = null
		#####################################
		for tile in tilesetCoordinates:
			var value = 0
			if allPawns[tile.x][tile.y] != null:
				value = allPawns[tile.x][tile.y].value
			printString += " (" + str(tile.x) + "," + str(tile.y) + ") = " + str(value) + ","
		printString += "\n"
	print(printString)


func _process(delta):
	pass

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

# Helpers

func NewArray2d(size: Vector2):
	var array = []
	for i in size.x:
		array.append([])
		for j in size.y:
			array[i].append(null)
	return array

func _move_pawns_up():
	print("UP")
	squeezeAndMerge(kUpDirection)

func _move_pawns_right():
	print("RIGHT")
	squeezeAndMerge(kRightDirection)

func _move_pawns_down():
	print("DOWN")
	squeezeAndMerge(kDownDirection)

func _move_pawns_left():
	print("LEFT")
	squeezeAndMerge(kLeftDirection)

func gridToPixelPosition(pixelCoordinates: Vector2) -> Vector2:
	return (grid.get_node("tilemap").map_to_world(pixelCoordinates) + grid.position + tileSize/2)

func addPawnAt(coordinates: Vector2, index: int) -> bool:
	# x-coordinate is too big --> error
	if allPawns.size() <= coordinates.x or allPawns.size() == 0:
		return false
	# y-coordinate is too big --> error
	if typeof(allPawns[0]) != TYPE_ARRAY or allPawns[0].size() <= coordinates.y or allPawns[0].size() == 0:
		return false
	# index too big --> error
	if possiblePawns.size() <= index:
		return false
	# already pawn at that position
	if allPawns[coordinates.x][coordinates.y] != null:
		return false
	# Add pawn
	var piece = possiblePawns[index].instance()
	add_child(piece)
	piece.position = gridToPixelPosition(coordinates)
	allPawns[coordinates.x][coordinates.y] = piece
	return true

func addRandomPawn() -> bool:
	var list = getListOfEmptyTiles()
	if list.empty():
		return false
	else:
		randomize()
		var positionIndex = randi() % list.size() #int(randi() % list.size())
		var valueIndex = 0
		if randf()  < 0.9: # 90% probability for index 0
			valueIndex = 0
		else: # rest 10% probability equally distributed
			valueIndex = randiRangeFromTo(1, possiblePawns.size() - 1)
		var coordinates : Vector2 = list[positionIndex]
		return addPawnAt(coordinates, valueIndex)

func anyEmptyTileOnGrid():
	for x in gridSize.x:
		for y in gridSize.y:
			if allPawns[x][y] == null:
				return true
	return false

func getListOfEmptyTiles():
	var list = []
	for x in gridSize.x:
		for y in gridSize.y:
			if allPawns[x][y] == null:
				list.append(Vector2(x,y))
	return list

func randiRangeFromTo(from: int, to: int) -> int:
	return range(from,to+1)[randi()%range(from,to+1).size()]

func getCoordinatesOfColumnWithXEqual(index: int):
	var result = []
	for y in range(gridSize.y):
		result.append(Vector2(index, y))
	return result

func getCoordinatesOfReverseColumnWithXEqual(index: int):
	var result = []
	for y in range(gridSize.y-1, -1, -1):
		result.append(Vector2(index, y))
	return result

func getCoordinatesOfRowWithYEqual(index: int):
	var result = []
	for x in range(gridSize.x):
		result.append(Vector2(x, index))
	return result

func getCoordinatesOfReverseRowWithYEqual(index: int):
	var result = []
	for x in range(gridSize.x-1, -1, -1):
		result.append(Vector2(x, index))
	return result

# Testing

func unitTests():
	unitTestAddPawnAt()

func unitTestAddPawnAt():
	print("Unit Tests addPawnAt()")
	print(addPawnAt(Vector2(0,0), 0) == true)
	print(addPawnAt(Vector2(0,0), 0) == false)
	print(addPawnAt(Vector2(0,1), 0) == true) 
	print(addPawnAt(Vector2(1,0), 1) == true)
	print(addPawnAt(Vector2(3,3), 1) == true) 
	print(addPawnAt(Vector2(3,4), 1) == false)
	print(addPawnAt(Vector2(4,3), 1) == false)
	print(addPawnAt(Vector2(2,2), 2) == false)
	print("==================================")