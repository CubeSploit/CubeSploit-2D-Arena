extends Node

var size = Vector2(20,20)
var count = 2

func is_wire_mode( misc_tile_type ):
	return misc_tile_type == Type.LogicWire || misc_tile_type == Type.EnergyWire 

const Type = {
	'LogicWire': 0,
	'EnergyWire': 1
}

const Data = [
	{
		"name": "Logic Wire",
		"tex": preload("res://TilesMisc/logic_wire.png")
	},
	{
		"name": "Energy Wire",
		"tex": preload("res://TilesMisc/energy_wire.png")
	}
]