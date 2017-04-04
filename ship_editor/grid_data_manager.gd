extends Node

onready var grid = get_node("../grid")
onready var layer_manager = get_node("../canvas_layer/ui/layer_manager")

var GridData = preload("res://ship_editor/grid_data.gd")
var grid_data = GridData.new()

func set_grid_data(grid_data):
	self.grid_data = grid_data
func get_grid_data():
	return grid_data

func set_tile( grid_pos, tile_type ):
	if( !grid.left_click_drag_mode ):
		doo()
	var tile = GridData.Tile.new(tile_type)
	grid_data.set_tile(grid_pos, tile)
	grid.update()
func remove_tile( grid_pos, drag_mode ):
	if( !grid.left_click_drag_mode ):
		doo()
	grid_data.remove_tile(grid_pos)
	grid.update()

func set_wire( p1, p2, p3, wire_type):
	if( grid_data.has_tile(p2) ):
		if( !grid.left_click_drag_mode ):
			doo()
		var layer = grid_data.get_selected_layer()
		var wire = GridData.Wire.new(wire_type, p1, p3)
		layer.set_wire(p2, wire)
		grid.update()
		return true
	else:
		return false
	
func erase_wire( layer_id, grid_pos ):
	if( !grid.left_click_drag_mode ):
		doo()
	var layer = grid_data.get_layer(layer_id)
	layer.remove_wire(grid_pos)
	grid.update()

func get_layer_id_containing_wire( grid_pos ):
	var selected_layer = grid_data.get_selected_layer()
	if( selected_layer.get_wires().has(grid_pos) ):
		return selected_layer
	for layer_id in range(grid_data.get_layers().size()):
		if( grid_data.get_layer(layer_id).get_wires().has(grid_pos)):
			return layer_id
	return -1

var undo_history = []
var redo_history = []
signal undo_history_empty()
signal undo_history_not_empty()
signal redo_history_empty()
signal redo_history_not_empty()


func doo():
#	undo_history.push_front( var2bytes(inst2dict(grid_data)) )
	undo_history.push_front( var2bytes(grid_data.to_dict()) )
	redo_history.clear()
	emit_signal("undo_history_not_empty")
	emit_signal("redo_history_empty")
func undo():
#	redo_history.push_front( var2bytes(inst2dict(grid_data)) )
	redo_history.push_front( var2bytes(grid_data.to_dict()) )
	grid_data = dict2inst(bytes2var( undo_history.pop_front()))
	grid_data.from_dict()
	layer_manager.load_layers(grid_data.get_layers())
	if( undo_history.empty() ):
		emit_signal("undo_history_empty")
	emit_signal("redo_history_not_empty")
	grid.update()
func redo():
#	undo_history.push_front(var2bytes(inst2dict(grid_data)))
	undo_history.push_front( var2bytes(grid_data.to_dict()) )
	grid_data= dict2inst(bytes2var( redo_history.pop_front() ))
	grid_data.from_dict()
	layer_manager.load_layers(grid_data.get_layers())
	if( redo_history.empty() ):
		emit_signal("redo_history_empty")
	emit_signal("undo_history_not_empty")
	grid.update()


func save_grid_data( path ):
	var content = var2bytes(inst2dict(grid_data))
	var file = File.new()
	file.open(path, file.WRITE)
	file.store_var(content)
	file.close()
func load_grid_data( path ):
	var file = File.new()
	file.open(path, file.READ)
	var content = file.get_var()
	file.close()
	grid_data =  dict2inst(bytes2var(content))
	layer_manager.load_layers(grid_data.get_layers())




func _on_layer_manager_default_layer_added( layer_id, layer_name, layer_color ):
	grid_data.add_layer( GridData.Layer.new(layer_name, layer_color) )
func _on_layer_manager_layer_added( layer_id, layer_name, layer_color ):
	doo()
	grid_data.add_layer( GridData.Layer.new(layer_name, layer_color) )
func _on_layer_manager_layer_color_changed( layer_id, layer_color ):
	doo()
	grid_data.get_layer(layer_id).set_color( layer_color )
	grid.update()
func _on_layer_manager_layer_deleted( layer_id ):
	if( grid_data.get_layers().size() > layer_id ):
		doo()
		grid_data.remove_layer(layer_id)
		grid.update()
func _on_layer_manager_layer_name_changed( layer_id, layer_name ):
	doo()
	grid_data.get_layer(layer_id).set_name( layer_name )
func _on_layer_manager_layer_selected( layer_id ):
	grid_data.set_selected_layer_id( layer_id )
	grid.update()
func _on_layer_manager_layer_sight_disabled( layer_id ):
	doo()
	grid_data.get_layer(layer_id).set_visible( false )
	grid.update()
func _on_layer_manager_layer_sight_enabled( layer_id ):
	doo()
	grid_data.get_layer(layer_id).set_visible( true )
	grid.update()

