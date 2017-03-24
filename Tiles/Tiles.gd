extends Node

var size = Vector2(20,20)
var count = 3

var connection_textures =[
	preload("res://Tiles/connection_top.png"),
	preload("res://Tiles/connection_right.png"),
	preload("res://Tiles/connection_down.png"),
	preload("res://Tiles/connection_left.png")
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
		'tex': preload("res://Tiles/Thruster.png")
	}
]



