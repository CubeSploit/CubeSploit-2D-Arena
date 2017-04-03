extends Node2D

onready var ship_editor = get_parent()
onready var camera = get_node("../camera_2d")
onready var grid_layer = get_node("parallax_bg/parallax_layer")
onready var grid_texture = get_node("parallax_bg/parallax_layer/texture_frame")
onready var cursor = get_node("cursor")
onready var selected_tile_wire_1 = get_node("selected_tile_wire_1")
onready var selected_tile_wire_2 = get_node("selected_tile_wire_2")
onready var layer_manager = get_node("../canvas_layer/ui/layer_manager")

var grid_texture_virtual_size = OS.get_window_size()

var left_click_last_mouse_pos
var left_click_drag_mode = false
var wheel_pressed = false

var grid_data = {
	"tiles": {},
	"wires": {},
	"layers": []
}
var selected_layer = 0

var undo_history = []
var redo_history = []
signal undo_history_empty()
signal undo_history_not_empty()
signal redo_history_empty()
signal redo_history_not_empty()



func _ready():
	set_process_unhandled_input(true)


func set_tile( grid_pos, tile_type ):
	if( !left_click_drag_mode ):
		doo()
	grid_data.tiles[grid_pos] = {
		"type": tile_type,
		"connections": [true,true,true,true]
	}
	update()
func erase_tile( grid_pos ):
	if( !left_click_drag_mode ):
		doo()
	grid_data.tiles.erase(grid_pos)
	update()

var wire_click_first
var wire_click_second
func wire_click( grid_pos, wire_type ):
	var reset = false
	if( wire_click_first == null ):
		wire_click_first = grid_pos
	elif( wire_click_second == null ):
		if( grid_pos.distance_to(wire_click_first) == 1 ):
			wire_click_second = grid_pos
		else:
			reset = true
	else:
		if( grid_pos.distance_to(wire_click_second) == 1 ):
			set_wire( wire_click_first, wire_click_second, grid_pos, wire_type )
			wire_click_first = wire_click_second
			wire_click_second = grid_pos
		else:
			reset = true
	if( reset ):
		wire_click_first = grid_pos
		wire_click_second = null

	update_wire_mode_selected_tiles_cursor()

func set_wire( p1, p2, p3, wire_type):
	if( grid_data.tiles.has(p2) ):
		if( !left_click_drag_mode ):
			doo()
#		grid_data.layers
		grid_data.layers[selected_layer].wires[p2] = {
			"type": wire_type,
			"pin": p1,
			"pout": p3
		}
		update()
	else:
		reset_wire_mode()

func erase_wire( layer_id, grid_pos ):
	if( !left_click_drag_mode ):
		doo()
	grid_data.layers[layer_id].wires.erase(grid_pos)
	update()

func reset_wire_mode():
	wire_click_first = null
	wire_click_second = null
	selected_tile_wire_1.hide()
	selected_tile_wire_2.hide()
	update_wire_mode_selected_tiles_cursor()
	
func update_wire_mode_selected_tiles_cursor():
	if( wire_click_first != null ):
		selected_tile_wire_1.show()
		selected_tile_wire_1.set_pos( grid_pos_to_pos( wire_click_first ))
	else:
		selected_tile_wire_1.hide()
		
	if( wire_click_second != null ):
		selected_tile_wire_2.show()
		selected_tile_wire_2.set_pos( grid_pos_to_pos( wire_click_second ))
	else:
		selected_tile_wire_2.hide()


func doo():
	undo_history.push_front( var2bytes(grid_data) )
	redo_history.clear()
	emit_signal("undo_history_not_empty")
	emit_signal("redo_history_empty")
func undo():
	redo_history.push_front( var2bytes(grid_data) )
	grid_data = bytes2var( undo_history.pop_front())
	layer_manager.load_layers(grid_data.layers)
	if( undo_history.empty() ):
		emit_signal("undo_history_empty")
	emit_signal("redo_history_not_empty")
	update()
func redo():
	undo_history.push_front(var2bytes(grid_data))
	grid_data= bytes2var( redo_history.pop_front() )
	layer_manager.load_layers(grid_data.layers)
	if( redo_history.empty() ):
		emit_signal("redo_history_empty")
	emit_signal("undo_history_not_empty")
	update()

func get_grid_data():
	return var2bytes(grid_data)
func load_grid_data(grid_data):
	self.grid_data = bytes2var(grid_data)
	layer_manager.load_layers(self.grid_data.layers)
	update()

func zoom_in():
	zoom("in")
func zoom_out():
	zoom("out")
func zoom_reset():
	zoom("reset")
func zoom(zoom_where):
	var new_size
	var new_zoom
	
	if( zoom_where == "reset" ):
		new_size = OS.get_window_size()
		new_zoom = Vector2(1,1)
		camera.set_pos(Vector2(0,0))
	else:
		var tiles_screen_dim = OS.get_window_size()/Tiles.size/10
		var added_size = Tiles.size * tiles_screen_dim
		if( zoom_where == "in" ):
			added_size *= -1
		new_size = grid_texture_virtual_size+added_size
		new_zoom = new_size/OS.get_window_size()

	if( new_zoom.x < 0.3 || new_zoom.y < 0.3):
		return
	
	camera.set_zoom( new_zoom )
	grid_layer.set_motion_scale(new_zoom)
	# texture size should be changed only on zoom superior to 1, else it is buggy
	# dunno why...
	if( new_zoom.x >= 1 || new_zoom.y >= 1 ):
		grid_texture.set_size(new_size)
	grid_texture_virtual_size = new_size

	
func _draw():
	var keys = grid_data.tiles.keys()
	var key_index_range = range(keys.size())
	for i in key_index_range:
		var key = keys[i]
		var tile = grid_data.tiles[key]
		var pos = grid_pos_to_pos(key)
		draw_texture( Tiles.Data[tile.type].tex, pos)
		for d in global.direction_iterator:
			if( tile.connections[0] ):
				draw_texture( Tiles.connection_textures[d], pos )
	
	var layers_id_iterator = range(grid_data.layers.size())
	for layer_id in layers_id_iterator:
		if( layer_id != selected_layer ):
			var layer = grid_data.layers[layer_id]
			if( layer.visible ):
				var wires_grid_pos = layer.wires.keys()
				var wires_grid_pos_iterator = range(wires_grid_pos.size())
				for wire_grid_pos_id in wires_grid_pos_iterator:
					var wire_grid_pos = wires_grid_pos[wire_grid_pos_id]
					var wire = layer.wires[wire_grid_pos]
					var wire_pos = grid_pos_to_pos(wire_grid_pos)
					if( wire.type == TilesMisc.Type.LogicWire ):
						draw_logic_wire( wire.pin, wire_pos, wire.pout, layer.color)
					elif( wire.type == TilesMisc.Type.EnergyWire ):
						draw_energy_wire( wire.pin, wire_pos, wire.pout, layer.color )
	
	var layer = grid_data.layers[selected_layer]
	if( layer.visible ):
		var wires_grid_pos = layer.wires.keys()
		var wires_grid_pos_iterator = range(wires_grid_pos.size())
		for wire_grid_pos_id in wires_grid_pos_iterator:
			var wire_grid_pos = wires_grid_pos[wire_grid_pos_id]
			var wire = layer.wires[wire_grid_pos]
			var wire_pos = grid_pos_to_pos(wire_grid_pos)
			if( wire.type == TilesMisc.Type.LogicWire ):
				draw_logic_wire( wire.pin, wire_pos, wire.pout, layer.color)
			elif( wire.type == TilesMisc.Type.EnergyWire ):
				draw_energy_wire( wire.pin, wire_pos, wire.pout, layer.color )


func draw_logic_wire( pin, pcenter, pout, color):
	pcenter = pcenter + TilesMisc.size/2
	pin = pcenter + (grid_pos_to_pos(pin)+ TilesMisc.size/2 - pcenter) /2
	pout = pcenter + (grid_pos_to_pos(pout)+ TilesMisc.size/2 - pcenter) /2
	draw_line(pin, pcenter, color,2)
	draw_line(pcenter, pout, color,2)
	
func draw_energy_wire( pin, pcenter, pout, color):
	pcenter = pcenter + TilesMisc.size/2
	pin = pcenter + (grid_pos_to_pos(pin)+ TilesMisc.size/2 - pcenter) /2
	pout = pcenter + (grid_pos_to_pos(pout)+ TilesMisc.size/2 - pcenter) /2
	draw_line(pin, pcenter, color,5)
	draw_line(pin, pcenter, Color(255,255,255),1)
	draw_line(pcenter, pout, color,5)
	draw_line(pcenter, pout, Color(255,255,255),1)




func on_left_click( mouse_pos ):
	var mouse_real_pos = mouse_pos_to_real_pos( mouse_pos )
	var mouse_grid_pos = pos_to_grid_pos(mouse_real_pos)
	if( ship_editor.mouse_mode == ship_editor.MouseMode.TILE ):
		set_tile(mouse_grid_pos, ship_editor.selected_tile_type)
	elif( ship_editor.mouse_mode == ship_editor.MouseMode.ERASER ):
		var layer_id = get_layer_id_containing_wire( mouse_grid_pos )
		if( layer_id != -1 ):
			erase_wire(layer_id, mouse_grid_pos)
		else:
			erase_tile( mouse_grid_pos )
	elif( ship_editor.mouse_mode == ship_editor.MouseMode.WIRE ):
		wire_click( mouse_grid_pos, ship_editor.selected_tile_type )
		
	if( ship_editor.mouse_mode != ship_editor.MouseMode.WIRE ):
		reset_wire_mode()
		
	left_click_last_mouse_pos = mouse_pos
func on_left_click_motion( mouse_pos ):
	left_click_drag_mode = true
	var last_mouse_grid_pos = pos_to_grid_pos( left_click_last_mouse_pos )
	var new_mouse_grid_pos = pos_to_grid_pos( mouse_pos )

	if( last_mouse_grid_pos != new_mouse_grid_pos ):
		on_left_click( mouse_pos )
		
	left_click_last_mouse_pos = mouse_pos
func on_left_click_release( ):
	left_click_drag_mode = false

func get_layer_id_containing_wire( grid_pos ):
	if( grid_data.layers[selected_layer].wires.has(grid_pos) ):
		return selected_layer
	for layer_id in range(grid_data.layers.size()):
		if( grid_data.layers[layer_id].wires.has(grid_pos)):
			return layer_id
	return -1

func on_middle_click_motion( mouse_relative_pos ):
		camera.set_pos(camera.get_pos()-mouse_relative_pos*camera.get_zoom())
	
func on_wheel( button_index ):
	if( button_index == BUTTON_WHEEL_UP ):
		zoom_in()
	else:
		zoom_out()

func on_mouse_motion( mouse_pos ):
	var mouse_real_pos = mouse_pos_to_real_pos( mouse_pos )
	var mouse_grid_pos = pos_to_grid_pos(mouse_real_pos)
	cursor.set_pos(grid_pos_to_pos(mouse_grid_pos))


func mouse_pos_to_real_pos( mouse_pos ):
	return (camera.get_pos() - (OS.get_window_size()/2)*camera.get_zoom()) + mouse_pos*camera.get_zoom()
	
func pos_to_grid_pos( pos ):
	return (pos / Tiles.size).floor()

func grid_pos_to_pos( grid_pos ):
	return grid_pos*Tiles.size







# layer manager signals handling
func _on_layer_management_panel_container_default_layer_added( layer_id, layer_name, layer_color ):
	grid_data.layers.append( {"name": layer_name,"color": layer_color,"wires":{},"visible":true})
func _on_layer_management_panel_container_layer_added( layer_id, layer_name, layer_color ):
	doo()
	grid_data.layers.append( {"name": layer_name,"color": layer_color,"wires":{},"visible":true})
func _on_layer_management_panel_container_layer_deleted( layer_id ):
	if( grid_data.layers.size()>layer_id ):
		doo()
		grid_data.layers.remove(layer_id)
func _on_layer_management_panel_container_layer_name_changed( layer_id, layer_name ):
	doo()
	grid_data.layers[layer_id].name = layer_name
func _on_layer_management_panel_container_layer_color_changed( layer_id, layer_color ):
	doo()
	grid_data.layers[layer_id].color = layer_color
	update()
func _on_layer_management_panel_container_layer_selected( layer_id ):
	selected_layer = layer_id
	update()
func _on_layer_management_panel_container_layer_sight_disabled( layer_id ):
	grid_data.layers[layer_id].visible = false;
	update()
func _on_layer_management_panel_container_layer_sight_enabled( layer_id ):
	grid_data.layers[layer_id].visible = true;
	update()
