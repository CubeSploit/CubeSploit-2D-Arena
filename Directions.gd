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

const Vec2ToDirection = {
	Vector2(0,-1): Up,
	Vector2(1,0): Right,
	Vector2(0,1): Down,
	Vector2(-1,0): Left
}
	

static func direction_to_rad(direction):
	return - direction * HalfPi

static func vector2_to_direction(vec):
	return Vec2ToDirection[vec]
	