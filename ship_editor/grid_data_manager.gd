extends Node

onready var grid = get_node("../grid")
onready var layer_manager = get_node("../canvas_layer/ui/layer_manager")

var GridData = preload("res://ship_editor/grid_data.gd")
var grid_data = GridData.new()

var grid_data_changed = false
signal grid_data_changed()

func set_grid_data(grid_data):
	self.grid_data = grid_data
	emit_signal("grid_data_changed")
func get_grid_data():
	return grid_data

func set_tile( grid_pos, tile_type ):
	if( !grid.left_click_drag_mode ):
		doo()
	var tile = GridData.create_tile(tile_type)
	grid_data.set_tile(grid_pos, tile)
	emit_signal("grid_data_changed")
func remove_tile( grid_pos ):
	if( !grid.left_click_drag_mode ):
		doo()
	if( !grid_data.has_tile(grid_pos) ):
		return 
	grid_data.remove_tile(grid_pos)
	emit_signal("grid_data_changed")

var history_next_wire = false
func wire_click( ):
	if( !grid.left_click_drag_mode ):
		history_next_wire = true
func set_wire( p1, p2, p3, wire_type):
	if( grid_data.has_tile(p2) ):
		if( !grid.left_click_drag_mode || history_next_wire):
			doo()
			history_next_wire = false
		var layer = grid_data.get_selected_layer()
		var wire = GridData.create_wire(wire_type, p1, p3)
		grid_data.set_wire(layer, p2, wire)
		emit_signal("grid_data_changed")
		return true
	else:
		return false
	
func remove_wire( layer_id, grid_pos ):
	if( !grid.left_click_drag_mode ):
		doo()
	if( !grid_data.has_wire( grid_data.get_layer(layer_id), grid_pos ) ):
		return
	var layer = grid_data.get_layer(layer_id)
	grid_data.remove_wire(layer, grid_pos)
	emit_signal("grid_data_changed")

func get_layer_id_containing_wire( grid_pos ):
	var selected_layer = grid_data.get_selected_layer()
	if( grid_data.has_wire(selected_layer, grid_pos) ):
		return grid_data.get_selected_layer_id()
	for layer_id in range(grid_data.get_layers_count()):
		if( grid_data.has_wire(grid_data.get_layer(layer_id), grid_pos) ):
			return layer_id
	return -1

var undo_history = []
var redo_history = []
signal undo_history_empty()
signal undo_history_not_empty()
signal redo_history_empty()
signal redo_history_not_empty()


func doo():
	undo_history.push_front( var2bytes(inst2dict(grid_data)) )
	redo_history.clear()
	emit_signal("undo_history_not_empty")
	emit_signal("redo_history_empty")
func undo():
	redo_history.push_front( var2bytes(inst2dict(grid_data)) )
	grid_data = dict2inst(bytes2var( undo_history.pop_front()))

	layer_manager.load_layers(grid_data.get_layers())
	if( undo_history.empty() ):
		emit_signal("undo_history_empty")
	emit_signal("redo_history_not_empty")
	emit_signal("grid_data_changed")
func redo():
	undo_history.push_front(var2bytes(inst2dict(grid_data)))
	grid_data= dict2inst(bytes2var( redo_history.pop_front() ))
	layer_manager.load_layers(grid_data.get_layers())
	if( redo_history.empty() ):
		emit_signal("redo_history_empty")
	emit_signal("undo_history_not_empty")
	emit_signal("grid_data_changed")


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
	emit_signal("grid_data_changed")




func _on_layer_manager_default_layer_added( layer_id, layer_name, layer_color ):
	grid_data.add_layer( GridData.create_layer(layer_name, layer_color) )
func _on_layer_manager_layer_added( layer_id, layer_name, layer_color ):
	doo()
	grid_data.add_layer( GridData.create_layer(layer_name, layer_color) )
func _on_layer_manager_layer_color_changed( layer_id, layer_color ):
	doo()
	grid_data.get_layer(layer_id).color = layer_color
	emit_signal("grid_data_changed")
func _on_layer_manager_layer_deleted( layer_id ):
	if( grid_data.get_layers_count() > layer_id ):
		doo()
		grid_data.remove_layer(layer_id)
		if( layer_id == grid_data.get_selected_layer_id() ):
			grid_data.set_selected_layer_id(0)
		emit_signal("grid_data_changed")
func _on_layer_manager_layer_name_changed( layer_id, layer_name ):
	doo()
	grid_data.get_layer(layer_id).name = layer_name
func _on_layer_manager_layer_selected( layer_id ):
	grid_data.set_selected_layer_id( layer_id )
	emit_signal("grid_data_changed")
func _on_layer_manager_layer_sight_disabled( layer_id ):
	doo()
	grid_data.get_layer(layer_id).visible = false
	emit_signal("grid_data_changed")
func _on_layer_manager_layer_sight_enabled( layer_id ):
	doo()
	grid_data.get_layer(layer_id).visible = true
	emit_signal("grid_data_changed")

