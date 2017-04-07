extends Node

var size = Vector2(20,20)
var count = 3
#
#var connection_textures =[
#	preload("res://Tiles/connection/connection_top.png"),
#	preload("res://Tiles/connection/connection_right.png"),
#	preload("res://Tiles/connection/connection_down.png"),
#	preload("res://Tiles/connection/connection_left.png")
#]
var connection_textures =[
	preload("res://Tiles/connection/connection_1.png"),
	preload("res://Tiles/connection/connection_2.png"),
	preload("res://Tiles/connection/connection_3.png"),
	preload("res://Tiles/connection/connection_4.png"),
	preload("res://Tiles/connection/connection_5.png"),
	preload("res://Tiles/connection/connection_6.png"),
	preload("res://Tiles/connection/connection_7.png"),
	preload("res://Tiles/connection/connection_8.png"),
	preload("res://Tiles/connection/connection_9.png"),
	preload("res://Tiles/connection/connection_10.png"),
	preload("res://Tiles/connection/connection_11.png"),
	preload("res://Tiles/connection/connection_12.png"),
	preload("res://Tiles/connection/connection_13.png"),
	preload("res://Tiles/connection/connection_14.png"),
	preload("res://Tiles/connection/connection_15.png")
]

const Type = {
	'Core': 0,
	'Hull': 1,
	'Thruster': 2
}


const Data = [
	{
		'name': 'Core',
		'tex': preload("res://Tiles/core.png")
	},
	{
		'name': 'Hull',
		'tex': preload("res://Tiles/hull.png")
	},
	{
		'name': 'Thruster',
		'tex': preload("res://Tiles/thruster.png")
	}
]

var tile_tileset = null
func get_tile_tileset():
	if( tile_tileset == null ):
		tile_tileset = TileSet.new()
		for i in range(count):
			tile_tileset.create_tile(i)
			tile_tileset.tile_set_name(i, Data[i].name)
			tile_tileset.tile_set_texture(i, Data[i].tex)

	return tile_tileset

var connection_tileset = null
func get_connection_tileset():
	if( connection_tileset == null ):
		connection_tileset = TileSet.new()
		
		for i in range(1, pow(2,4)):
			connection_tileset.create_tile(i)
			connection_tileset.tile_set_texture(i,connection_textures[i-1])
	return connection_tileset

func get_connection_id( connections ):
	var connection_id = 0
	for d in global.direction_iterator:
		if( connections[d] ):
			connection_id += pow(2,d)
	if (connection_id == 0):
		connection_id = -1
	return connection_id