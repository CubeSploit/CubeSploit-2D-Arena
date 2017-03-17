extends Node2D

onready var camera = get_node('camera_2d')
onready var grid_layer = get_node("grid/parallax_bg/parallax_layer")
onready var grid_texture = get_node("grid/parallax_bg/parallax_layer/texture_frame")
onready var cursor = get_node("cursor")

var wheel_pressed = false


func _ready():
	cursor.set_offset(Tiles.size/2)
	set_process_input(true)
	
	
func _input(ev):
	if( ev.type == InputEvent.MOUSE_BUTTON && ev.button_index == BUTTON_MIDDLE ):
		wheel_pressed = ev.pressed
	
	if( ev.type == InputEvent.MOUSE_MOTION && wheel_pressed ):
		camera.set_pos(camera.get_pos()-ev.relative_pos*camera.get_zoom())
	
	if( ev.type == InputEvent.MOUSE_BUTTON && 
	( ev.button_index == BUTTON_WHEEL_UP || ev.button_index == BUTTON_WHEEL_DOWN ) &&
	ev.pressed ):
		var tiles_screen_dim = OS.get_window_size()/Tiles.size/10
		var added_size = Tiles.size * tiles_screen_dim
		if( ev.button_index == BUTTON_WHEEL_UP ):
			added_size *= -1
		var new_size = grid_texture.get_size()+added_size
		var new_zoom = new_size/OS.get_window_size()

		camera.set_zoom( new_zoom )
		grid_texture.set_size(new_size)
		grid_layer.set_motion_scale(new_zoom)

	if( ev.type == InputEvent.MOUSE_MOTION ):
		var cursor_raw_pos = (camera.get_pos() - (OS.get_window_size()/2)*camera.get_zoom()) + ev.pos*camera.get_zoom()
		var cursor_grid_pos = (cursor_raw_pos / Tiles.size).floor()
		cursor.set_pos(cursor_grid_pos*Tiles.size)