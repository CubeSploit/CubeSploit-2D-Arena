extends Reference

var tiles = {}
var layers = []
var selected_layer_id

func _init():
	pass

func set_tiles(tiles):
	self.tiles = tiles
func get_tiles():
	return tiles
func remove_tile(grid_pos):
	tiles[grid_pos].erase(grid_pos)
func set_tile(grid_pos, tile):
	tiles[grid_pos] = tile
	
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


