extends Node

onready var grid_input_manager = get_node("../grid_input_manager")
onready var layer_manager = get_node("../canvas_layer/ui/layer_manager")

var Action = preload("res://ship_editor/action.gd")

var GridData = preload("res://ship_editor/grid_data.gd")
var grid_data = GridData.new()

var grid_data_changed = false
signal grid_data_changed()
signal tile_changed(tile_to_update)
signal wire_changed(wire_to_update)
signal layer_changed(layer_to_update)

func set_grid_data(grid_data):
	self.grid_data = grid_data
	emit_signal("grid_data_changed")
func get_grid_data():
	return grid_data

func set_tile( grid_pos, tile_type, tile_direction, continuous ):
	start_action(["tiles",grid_pos], continuous)
	
	var tile = GridData.create_tile(tile_type, tile_direction)
	grid_data.set_tile(grid_pos, tile)
	
	stop_action(continuous)
	emit_signal("tile_changed", grid_pos)
func remove_tile( grid_pos, continuous ):
	start_action(["tiles",grid_pos], continuous)
	
	if( grid_data.has_tile(grid_pos) ):
		grid_data.remove_tile(grid_pos)
	
	stop_action(continuous)
	emit_signal("tile_changed", grid_pos)

func set_wire( p1, p2, p3, wire_type, continuous):
	if( grid_data.has_tile(p2) ):
		start_action(["layers", grid_data.selected_layer_id, "wires", p2], continuous)
		
		var layer = grid_data.get_selected_layer()
		var wire = GridData.create_wire(wire_type, p1, p3)
		grid_data.set_wire(layer, p2, wire)
		
		stop_action(continuous)
		emit_signal("wire_changed", p2)
		return true
	else:
		return false
	
func remove_wire( layer_id, grid_pos, continuous ):
	start_action(["layers", layer_id, "wires", grid_pos], continuous)
		
	if( !grid_data.has_wire( grid_data.get_layer(layer_id), grid_pos ) ):
		return
	var layer = grid_data.get_layer(layer_id)
	grid_data.remove_wire(layer, grid_pos)
	
	stop_action(continuous)
	emit_signal("wire_changed", grid_pos)


# Undo/Redo mechanism
# Everytime a modification is being done on the grid data it is being saved in an Action object
# 

var current_actions = []
var undo_history = []
var redo_history = []
signal undo_history_empty()
signal undo_history_not_empty()
signal redo_history_empty()
signal redo_history_not_empty()

func start_action(path, continuous = false):
	var action = Action.new(grid_data, path)
	action.set_old_value()
	if( continuous ):
		current_actions = undo_history.pop_front()
	current_actions.push_front(action)
func stop_action(continuous = false):
	if( continuous ):
		current_actions[0].set_new_value()
	else:
		for i in range(current_actions.size()):
			current_actions[i].set_new_value()
	undo_history.push_front(current_actions)
	current_actions = []
	
	redo_history.clear()
	emit_signal("undo_history_not_empty")
	emit_signal("redo_history_empty")
func undo():
	current_actions = undo_history.pop_front()
	for i in range(current_actions.size()):
		current_actions[i].undo()
	redo_history.push_front( current_actions )
	current_actions = []
	
	layer_manager.load_layers(grid_data.get_selected_layer_id(), grid_data.get_layers())

	if( undo_history.empty() ):
		emit_signal("undo_history_empty")
	emit_signal("redo_history_not_empty")
	emit_signal("grid_data_changed")
func redo():
	current_actions = redo_history.pop_front()
	for i in range(current_actions.size()):
		current_actions[i].redo()
	undo_history.push_front( current_actions )
	current_actions = []

	layer_manager.load_layers(grid_data.get_selected_layer_id(), grid_data.get_layers())

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
	layer_manager.load_layers(grid_data.get_selected_layer_id(), grid_data.get_layers())
	emit_signal("grid_data_changed")




func _on_layer_manager_default_layer_added( layer_id, layer_name, layer_color ):
	grid_data.add_layer( GridData.create_layer(layer_name, layer_color) )
func _on_layer_manager_layer_added( layer_id, layer_name, layer_color ):
	start_action(["layers", layer_id])
	grid_data.add_layer( GridData.create_layer(layer_name, layer_color) )
func _on_layer_manager_layer_color_changed( layer_id, layer_color ):
	start_action(["layers", layer_id, "color"])
	grid_data.get_layer(layer_id).color = layer_color
	stop_action()
	emit_signal("layer_changed", layer_id)
func _on_layer_manager_layer_deleted( layer_id ):
	if( grid_data.get_layers_count() > layer_id ):
		start_action(["layers", layer_id])
		grid_data.remove_layer(layer_id)
		if( layer_id == grid_data.get_selected_layer_id() ):
			grid_data.set_selected_layer_id(0)
		emit_signal("layer_changed", layer_id)
func _on_layer_manager_layer_name_changed( layer_id, layer_name ):
	start_action(["layers", layer_id, "name"])
	grid_data.get_layer(layer_id).name = layer_name
	stop_action()
func _on_layer_manager_layer_selected( layer_id ):
	start_action(["selected_layer_id"])
	grid_data.set_selected_layer_id( layer_id )
	stop_action()
	emit_signal("layer_changed", layer_id)
func _on_layer_manager_layer_sight_disabled( layer_id ):
	start_action(["layers", layer_id, "visible"])
	grid_data.get_layer(layer_id).visible = false
	stop_action()
	emit_signal("layer_changed", layer_id)
func _on_layer_manager_layer_sight_enabled( layer_id ):
	start_action(["layers", layer_id, "visible"])
	grid_data.get_layer(layer_id).visible = true
	stop_action()
	emit_signal("layer_changed", layer_id)

