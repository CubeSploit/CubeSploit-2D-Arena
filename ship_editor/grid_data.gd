extends Reference

var tiles = {}
var layers = []
var selected_layer_id

func _init():
	pass

func to_dict():
	var dict = inst2dict(self)
	
	dict.tiles = {}
	var tiles_grid_pos = tiles.keys()
	var tiles_grid_pos_id_iterator = range(tiles_grid_pos.size())
	for i in tiles_grid_pos_id_iterator:
		dict.tiles[tiles_grid_pos[i]] = inst2dict(tiles[tiles_grid_pos[i]])
		var dict = inst2dict(tiles[tiles_grid_pos[i]])
		print(var2str(dict))
#		print(dict2inst(dict))  # bug???
		var p = {
			"@path":"res://ship_editor/grid_data.gd",
			"@subpath":"Tile",
			"background":false, 
			"connections":[true, true, true, true],
			"type": 1
		}
		print(dict2inst(p))
	
	dict.layers = []
	var layers_id_iterator = range(layers.size())
	for layer_id in layers_id_iterator:
		dict.layers.append( layers[layer_id].to_dict() )
	

	return dict

func from_dict():
	var tiles_grid_pos = tiles.keys()
	var tiles_grid_pos_id_iterator = range(tiles_grid_pos.size())
	for i in tiles_grid_pos_id_iterator:
		tiles[tiles_grid_pos[i]] = dict2inst(tiles[tiles_grid_pos[i]])

	var layers_id_iterator = range(layers.size())
	for layer_id in layers_id_iterator:
		layers[layer_id] = dict2inst(layers[layer_id])
		layers[layer_id].from_dict()

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
	tiles[grid_pos].erase(grid_pos)


func set_layers(layers):
	self.layers = layers
func get_layers():
	return layers
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

class Tile:
	var type
	var connections = [true,true,true,true]
	var background = false
	
	func _init(type):
		self.type = type

	
	func set_type(type):
		self.type = type
	func get_type():
		return type
		
	func set_connections(connections):
		self.connections = connections
	func get_connections():
		return connections
	func set_connection(connection_id, connection_value):
		connections[connection_id] = connection_value
	func get_connection(connection_id):
		return connections[connection_id]
	
	func set_background(background):
		self.background = background
	func is_background():
		return background

class Layer:
	var name = "Default"
	var color = Color(255,255,255)
	var wires = {}
	var visible = true
	
	func _init(name = "Default", color = Color(255,255,255)):
		self.name = name
		self.color = color
		
	func to_dict():
		var dict = inst2dict(self)
		
		dict.wires = {}
		var wires_grid_pos = wires.keys()
		var wires_grid_pos_id_iterator = range(wires_grid_pos.size())
		for i in wires_grid_pos_id_iterator:
			dict.wires[wires_grid_pos[i]] = inst2dict(wires[wires_grid_pos[i]])
		
		return dict
	func from_dict():
		var wires_grid_pos = wires.keys()
		var wires_grid_pos_id_iterator = range(wires_grid_pos.size())
		for i in wires_grid_pos_id_iterator:
			wires[wires_grid_pos[i]] = dict2inst(wires[wires_grid_pos[i]])
		
		
	func set_name(name):
		self.name = name
	func get_name():
		return name
	
	func set_color(color):
		self.color = color
	func get_color():
		return color
	
	func set_wires(wires):
		self.wires = wires
	func get_wires():
		return wires
	func set_wire(grid_pos, wire):
		wires[grid_pos] = wire
	func get_wire(grid_pos):
		return wires[grid_pos]
	func remove_wire(grid_pos):
		wires.erase(grid_pos)
	
	func set_visible(visible):
		self.visible = visible
	func is_visible():
		return visible

class Wire:
	var type
	var pin
	var pout

	func _init( type, pin, pout):
		self.type = type
		self.pin = pin
		self.pout = pout

	func set_type(type):
		self.type = type
	func get_type():
		return type
		
	func set_pin(pin):
		self.pin = pin
	func get_pin():
		return pin
		
	func set_pout(pout):
		self.pout = pout
	func get_pout():
		return pout

