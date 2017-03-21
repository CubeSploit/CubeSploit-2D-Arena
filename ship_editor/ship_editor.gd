extends Node2D

onready var camera = get_node('camera_2d')
onready var grid_layer = get_node("grid/parallax_bg/parallax_layer")
onready var grid_texture = get_node("grid/parallax_bg/parallax_layer/texture_frame")
onready var cursor = get_node("cursor")
var grid_texture_virtual_size = OS.get_window_size()

onready var tilemap = get_node("tilemap")
var selected_tile_type = 0

var wheel_pressed = false

var tiles = {}

func _ready():
	cursor.set_offset(Tiles.size/2)
	set_process_unhandled_input(true)


	
func _unhandled_input(ev):
	# left click
	if( ev.type == InputEvent.MOUSE_BUTTON && ev.button_index == BUTTON_LEFT && ev.pressed):
		on_grid_left_click(ev.pos)
	
	# middle click
	if( ev.type == InputEvent.MOUSE_BUTTON && ev.button_index == BUTTON_MIDDLE ):
		wheel_pressed = ev.pressed
	
	# mouse motion while holding middle click down
	if( ev.type == InputEvent.MOUSE_MOTION && wheel_pressed ):
		on_grid_middle_click_motion( ev.relative_pos )
	
	# wheel
	if( ev.type == InputEvent.MOUSE_BUTTON && 
	( ev.button_index == BUTTON_WHEEL_UP || ev.button_index == BUTTON_WHEEL_DOWN ) &&
	ev.pressed ):
		on_grid_wheel( ev.button_index )

	# mouse motion
	if( ev.type == InputEvent.MOUSE_MOTION ):
		on_grid_mouse_motion( ev.pos )


func _draw():
	var keys = tiles.keys()
	var key_index_range = range(keys.size())
	for i in key_index_range:
		var key = keys[i]
		var tile = tiles[key]
		var pos = grid_pos_to_pos(key)
		for d in global.direction_iterator:
			if( tile.connections[0] ):
				draw_texture( Tiles.connection_textures[d], pos )

func on_grid_left_click( cursor_pos ):
	var cursor_real_pos = cursor_pos_to_real_pos( cursor_pos )
	var cursor_grid_pos = pos_to_grid_pos(cursor_real_pos)
	tilemap.set_cell(cursor_grid_pos.x, cursor_grid_pos.y, selected_tile_type)
	tiles[cursor_grid_pos] = {
		"type": selected_tile_type,
		"connections": [true,true,true,true]
	}
	update()
	
func on_grid_middle_click_motion( cursor_relative_pos ):
		camera.set_pos(camera.get_pos()-cursor_relative_pos*camera.get_zoom())
	
func on_grid_wheel( button_index ):
		var tiles_screen_dim = OS.get_window_size()/Tiles.size/10
		var added_size = Tiles.size * tiles_screen_dim
		if( button_index == BUTTON_WHEEL_UP ):
			added_size *= -1
		var new_size = grid_texture_virtual_size+added_size
		var new_zoom = new_size/OS.get_window_size()

		if( new_zoom.x < 0.3 || new_zoom.y < 0.3):
			return
			
		camera.set_zoom( new_zoom )
		grid_layer.set_motion_scale(new_zoom)
		# texture size should be changed only on zoom superior to 1, else it is buggy
		# dunno why...
		if( new_zoom.x >= 1 || new_zoom.y >= 1 ):
			grid_texture.set_size(new_size)
		grid_texture_virtual_size = new_size

func on_grid_mouse_motion( mouse_pos ):
	var cursor_real_pos = cursor_pos_to_real_pos( mouse_pos )
	var cursor_grid_pos = pos_to_grid_pos(cursor_real_pos)
	cursor.set_pos(grid_pos_to_pos(cursor_grid_pos))

func cursor_pos_to_real_pos( cursor_pos ):
	return (camera.get_pos() - (OS.get_window_size()/2)*camera.get_zoom()) + cursor_pos*camera.get_zoom()
	
func pos_to_grid_pos( pos ):
	return (pos / Tiles.size).floor()

func grid_pos_to_pos( grid_pos):
	return grid_pos*Tiles.size

func _on_tile_list_tile_type_selected( tile_type ):
	selected_tile_type = tile_type
