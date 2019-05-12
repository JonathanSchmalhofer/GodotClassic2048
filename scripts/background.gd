extends Node2D

export (PackedScene) var background
var columns = 4
var rows = 4
export (int) var xStart
export (int) var yStart

func _ready():
	setup()

func setup():
	# Create anm instance of the background grid
	var grid = background.instance()
	grid.position = Vector2(xStart, yStart)
	add_child(grid)
	# Add tiles to the background grid
	var tilemap = grid.get_node("tilemap")
	var backgroundtile = tilemap.get_tileset().find_tile_by_name("background")
	var tilepostion : Vector2
	for i in columns:
		for j in rows:
			tilepostion = Vector2(i,j)
			tilemap.set_cellv(tilepostion, backgroundtile)