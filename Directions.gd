extends Node

const Up = 0
const Right = 1
const Down = 2
const Left = 3

const Count = 4

const HalfPi = PI/2

const TilemapCellOptions = [
	{
		"flip_x": false,
		"flip_y": false,
		"transpose": false
	},
	{
		"flip_x": true,
		"flip_y": false,
		"transpose": true
	},
	{
		"flip_x": false,
		"flip_y": true,
		"transpose": false
	},
	{
		"flip_x": false,
		"flip_y": false,
		"transpose": true
	}
]

static func direction_to_rad(direction):
	return - direction * HalfPi
