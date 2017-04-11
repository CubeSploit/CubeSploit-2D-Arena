extends Reference

var tiles = {}
var layers = []
var selected_layer_id = 0

func _init():
	pass
	
static func create_tile( tile_type ):
	return {
		"type": tile_type,
		"connections": [true,true,true,true],
		"background": false
	}
static func create_layer(name = "Default", color = Color(255,255,255)):
	return {
		"name": name,
		"color": color,
		"wires": {},
		"visible": true
	}
static func create_wire(wire_type, pin, pout):
	return {
		"type": wire_type,
		"pin": pin,
		"pout": pout
	}
	

func set_tiles(tiles):
	self.tiles = tiles
func get_tiles():
	return tiles

func set_tile(grid_pos, tile):
	tiles[grid_pos] = tile
func get_tile(grid_pos):
	return tiles[grid_pos]
func has_tile(grid_pos):
	return tiles.has(grid_pos)
func remove_tile(grid_pos):
	tiles.erase(grid_pos)


func set_layers(layers):
	self.layers = layers
func get_layers():
	return layers
func get_layers_count():
	return layers.size()
	
func set_layer(layer_id, layer):
	layers[layer_id] = layer
func add_layer(layer):
	layers.append(layer)
func get_layer(layer_id):
	return layers[layer_id]
func remove_layer(layer_id):
	layers.remove(layer_id)

func set_selected_layer_id(selected_layer_id):
	self.selected_layer_id = selected_layer_id
func get_selected_layer_id():
	return selected_layer_id

func set_selected_layer(selected_layer):
	self.selected_layer_id = layers.find(selected_layer)
func get_selected_layer():
	return layers[selected_layer_id]

func set_wires(layer, wires):
	layer.wires = wires
func get_wires(layer):
	return layer.wires

func set_wire(layer, grid_pos, wire):
	layer.wires[grid_pos] = wire
func get_wire(layer, grid_pos):
	return layer.wires[grid_pos]
func has_wire(layer, grid_pos):
	return layer.wires.has(grid_pos)
func remove_wire(layer, grid_pos):
	layer.wires.erase(grid_pos)




