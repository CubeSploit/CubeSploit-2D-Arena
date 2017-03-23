extends Node2D

var direction = {
	"TOP": 0,
	"RIGHT": 1,
	"DOWN": 2,
	"LEFT": 3,
	"COUNT": 4
}
var direction_iterator = range(4)


const Scenes = {
	"MAIN": preload("res://main.tscn"),
	"SHIP_EDITOR": preload("res://ship_editor/ship_editor.tscn")
}