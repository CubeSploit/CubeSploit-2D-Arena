extends Node

onready var layer_manager = get_node("../canvas_layer/ui/layer_manager")

var GridData = preload("res://ship_editor/grid_data.gd")
var grid_data = GridData.new()

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
	layer_manager.load_layers(grid_data.layers)
	if( undo_history.empty() ):
		emit_signal("undo_history_empty")
	emit_signal("redo_history_not_empty")
	update()
func redo():
	undo_history.push_front(var2bytes(inst2dict(grid_data)))
	grid_data= dict2inst(bytes2var( redo_history.pop_front() ))
	layer_manager.load_layers(grid_data.layers)
	if( redo_history.empty() ):
		emit_signal("redo_history_empty")
	emit_signal("undo_history_not_empty")
	update()


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
	self.grid_data =  dict2inst(bytes2var(grid_data))
	layer_manager.load_layers(self.grid_data.layers)




func _on_layer_manager_default_layer_added( layer_id, layer_name, layer_color ):
	grid_data.add_layer( GridData.Layer.new(layer_name, layer_color) )
func _on_layer_manager_layer_added( layer_id, layer_name, layer_color ):
	doo()
	grid_data.add_layer( GridData.Layer.new(layer_name, layer_color) )
func _on_layer_manager_layer_color_changed( layer_id, layer_color ):
	doo()
	grid_data.get_layer(layer_id).set_color( layer_color )
	update()
func _on_layer_manager_layer_deleted( layer_id ):
	if( grid_data.get_layers().size() > layer_id ):
		doo()
		grid_data.remove_layer(layer_id)
func _on_layer_manager_layer_name_changed( layer_id, layer_name ):
	doo()
	grid_data.get_layer(layer_id).set_name( layer_name )
func _on_layer_manager_layer_sight_disabled( layer_id ):
	doo()
	grid_data.get_layer(layer_id).set_visible( false )
func _on_layer_manager_layer_sight_enabled( layer_id ):
	doo()
	grid_data.get_layer(layer_id).set_visible( true )