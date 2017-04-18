extends Node2D

onready var ship_editor = get_parent()

onready var camera = get_node("../camera_2d")
onready var grid_data_manager = get_node("../grid_data_manager")

var left_click_last_mouse_pos
var left_click_last_mouse_grid_pos
var left_click_drag_mode = false
var wheel_pressed = false

var wire_click_first = null
var wire_click_second = null
var wire_drag_mode = false

var connection_click_first = null
var connection_drag_mode = false

var cursor_pos = Vector2(0,0)

func _ready():
	pass



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
			grid_data_manager.set_wire( wire_click_first, wire_click_second, grid_pos, wire_type, wire_drag_mode)
			if( !wire_drag_mode && left_click_drag_mode ):
				wire_drag_mode = true
			wire_click_first = wire_click_second
			wire_click_second = grid_pos
		else:
			reset = true
			
	if( reset ):
		wire_click_first = grid_pos
		wire_click_second = null

func get_layer_id_containing_wire( grid_pos ):
	var grid_data = grid_data_manager.get_grid_data()
	var selected_layer = grid_data.get_selected_layer()
	if( grid_data.has_wire(selected_layer, grid_pos) ):
		return grid_data.get_selected_layer_id()
	for layer_id in range(grid_data.get_layers_count()):
		if( grid_data.has_wire(grid_data.get_layer(layer_id), grid_pos) ):
			return layer_id
	return -1


func on_left_click( mouse_pos ):
	var mouse_real_pos = mouse_pos_to_real_pos( mouse_pos )
	var mouse_grid_pos = pos_to_grid_pos(mouse_real_pos)
	if( ship_editor.mouse_mode == ship_editor.MouseMode.TILE ):
		grid_data_manager.set_tile(mouse_grid_pos, ship_editor.selected_tile_type, ship_editor.tile_direction, left_click_drag_mode)
	elif( ship_editor.mouse_mode == ship_editor.MouseMode.ERASER ):
		var layer_id = get_layer_id_containing_wire( mouse_grid_pos )
		if( layer_id != -1 ):
			grid_data_manager.remove_wire(layer_id, mouse_grid_pos, left_click_drag_mode)
		else:
			grid_data_manager.remove_tile( mouse_grid_pos, left_click_drag_mode)
	elif( ship_editor.mouse_mode == ship_editor.MouseMode.WIRE ):
		wire_click( mouse_grid_pos, ship_editor.selected_tile_type )
	elif( ship_editor.mouse_mode == ship_editor.MouseMode.SET_AS_BACKGROUND ):
		grid_data_manager.set_tile_as_background(mouse_grid_pos, left_click_drag_mode)
	elif( ship_editor.mouse_mode == ship_editor.MouseMode.SET_AS_FOREGROUND ):
		grid_data_manager.set_tile_as_foreground(mouse_grid_pos, left_click_drag_mode)
	elif( ship_editor.mouse_mode == ship_editor.MouseMode.CONNECT ):
		if( connection_click_first != null && connection_click_first.distance_to(mouse_grid_pos) == 1 ):
			grid_data_manager.connect_tiles(connection_click_first, mouse_grid_pos, connection_drag_mode)
			if( !connection_drag_mode && left_click_drag_mode ):
				connection_drag_mode = true
		connection_click_first = mouse_grid_pos
	elif( ship_editor.mouse_mode == ship_editor.MouseMode.DISCONNECT ):
		if( connection_click_first != null && connection_click_first.distance_to(mouse_grid_pos) == 1 ):
			grid_data_manager.disconnect_tiles(connection_click_first, mouse_grid_pos, connection_drag_mode)
			if( !connection_drag_mode && left_click_drag_mode ):
				connection_drag_mode = true
		connection_click_first = mouse_grid_pos
		
	if( ship_editor.mouse_mode != ship_editor.MouseMode.WIRE ):
		wire_click_first = null
		wire_click_second = null
		
	if( ship_editor.mouse_mode != ship_editor.MouseMode.CONNECT && ship_editor.mouse_mode != ship_editor.MouseMode.DISCONNECT ):
		connection_click_first = null
		
	left_click_last_mouse_pos = mouse_pos
	left_click_last_mouse_grid_pos = mouse_grid_pos
func on_left_click_motion( mouse_pos ):
	left_click_drag_mode = true
	var new_mouse_grid_pos = pos_to_grid_pos( mouse_pos_to_real_pos(mouse_pos) )

	var delta =  new_mouse_grid_pos-left_click_last_mouse_grid_pos
	var distance = abs(delta.x) + abs(delta.y)
	
	if( distance > 1 ):
		var divided_mouse_pos = (mouse_pos - left_click_last_mouse_pos)/distance
		for i in range(distance):
			on_left_click_motion(left_click_last_mouse_pos + divided_mouse_pos )
	elif (distance == 1 ):
#	if( left_click_last_mouse_grid_pos != new_mouse_grid_pos ):
		on_left_click( mouse_pos )

		left_click_last_mouse_pos = mouse_pos
		left_click_last_mouse_grid_pos = new_mouse_grid_pos
	else:
		left_click_last_mouse_pos = mouse_pos
		left_click_last_mouse_grid_pos = new_mouse_grid_pos
		
func on_left_click_release( ):
	left_click_drag_mode = false
	wire_drag_mode = false
	connection_drag_mode = false



func on_mouse_motion( mouse_pos ):
	var mouse_real_pos = mouse_pos_to_real_pos( mouse_pos )
	var mouse_grid_pos = pos_to_grid_pos(mouse_real_pos)
#	cursor.set_pos(grid_pos_to_pos(mouse_grid_pos))
	cursor_pos = grid_pos_to_pos(mouse_grid_pos)


func mouse_pos_to_real_pos( mouse_pos ):
	return (camera.get_pos() - (OS.get_window_size()/2)*camera.get_zoom()) + mouse_pos*camera.get_zoom()
	
func pos_to_grid_pos( pos ):
	return (pos / Tiles.size).floor()

func grid_pos_to_pos( grid_pos ):
	return grid_pos*Tiles.size