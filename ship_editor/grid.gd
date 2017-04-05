extends Node2D

onready var ship_editor = get_parent()
onready var camera = get_node("../camera_2d")
onready var grid_layer = get_node("parallax_bg/parallax_layer")
onready var grid_texture = get_node("parallax_bg/parallax_layer/texture_frame")
onready var cursor = get_node("cursor")
onready var selected_tile_wire_1 = get_node("selected_tile_wire_1")
onready var selected_tile_wire_2 = get_node("selected_tile_wire_2")
onready var layer_manager = get_node("../canvas_layer/ui/layer_manager")
onready var grid_data_manager = get_node("../grid_data_manager")
var grid_texture_virtual_size = OS.get_window_size()

var left_click_last_mouse_pos
var left_click_drag_mode = false
var wheel_pressed = false





func _ready():
	set_process_unhandled_input(true)



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
			grid_data_manager.set_wire( wire_click_first, wire_click_second, grid_pos, wire_type )
			wire_click_first = wire_click_second
			wire_click_second = grid_pos
		else:
			reset = true
	if( reset ):
		wire_click_first = grid_pos
		wire_click_second = null
		
	grid_data_manager.wire_click()
	update_wire_mode_selected_tiles_cursor()
	


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
	var grid_data = grid_data_manager.get_grid_data()
	var tiles_grid_pos = grid_data.get_tiles().keys()
	var tiles_pos_iterator = range(tiles_grid_pos.size())
	for i in tiles_pos_iterator:
		var tile_grid_pos = tiles_grid_pos[i]
		var tile = grid_data.get_tile(tile_grid_pos)
		var pos = grid_pos_to_pos(tile_grid_pos)
		draw_texture( Tiles.Data[tile.type].tex, pos)
		for d in global.direction_iterator:
			if( tile.connections[d] ):
				draw_texture( Tiles.connection_textures[d], pos )
	
	var layers_id_iterator = range(grid_data.get_layers_count())
	for layer_id in layers_id_iterator:
		if( layer_id != grid_data.get_selected_layer_id() ):
			var layer = grid_data.get_layer(layer_id)
			if( layer.visible ):
				var wires_grid_pos = grid_data.get_wires(layer).keys()
				var wires_grid_pos_iterator = range(wires_grid_pos.size())
				for wire_grid_pos_id in wires_grid_pos_iterator:
					var wire_grid_pos = wires_grid_pos[wire_grid_pos_id]
					var wire = grid_data.get_wire(layer, wire_grid_pos)
					var wire_pos = grid_pos_to_pos(wire_grid_pos)
					if( wire.type == TilesMisc.Type.LogicWire ):
						draw_logic_wire( wire.pin, wire_pos, wire.pout, layer.color)
					elif( wire.type == TilesMisc.Type.EnergyWire ):
						draw_energy_wire( wire.pin, wire_pos, wire.pout, layer.color )
	
	var layer = grid_data.get_selected_layer()
	if( layer.visible ):
		var wires_grid_pos = grid_data.get_wires(layer).keys()
		var wires_grid_pos_iterator = range(wires_grid_pos.size())
		for wire_grid_pos_id in wires_grid_pos_iterator:
			var wire_grid_pos = wires_grid_pos[wire_grid_pos_id]
			var wire = grid_data.get_wire(layer, wire_grid_pos)
			var wire_pos = grid_pos_to_pos(wire_grid_pos)

			if( wire.type == TilesMisc.Type.LogicWire ):
				draw_logic_wire( wire.pin, wire_pos, wire.pout, layer.color )
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
		grid_data_manager.set_tile(mouse_grid_pos, ship_editor.selected_tile_type)
	elif( ship_editor.mouse_mode == ship_editor.MouseMode.ERASER ):
		var layer_id = grid_data_manager.get_layer_id_containing_wire( mouse_grid_pos )
		if( layer_id != -1 ):
			grid_data_manager.remove_wire(layer_id, mouse_grid_pos)
		else:
			grid_data_manager.remove_tile( mouse_grid_pos )
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

