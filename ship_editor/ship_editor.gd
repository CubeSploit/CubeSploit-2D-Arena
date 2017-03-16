extends Node2D

onready var camera = get_node('camera_2d')
onready var grid_layer = get_node("grid/parallax_bg/parallax_layer")
onready var grid_texture = get_node("grid/parallax_bg/parallax_layer/texture_frame")


var wheel_pressed = false



func _ready():
	set_process_input(true)
	
	
func _input(ev):
	if( ev.type == InputEvent.MOUSE_BUTTON && ev.button_index == BUTTON_MIDDLE ):
		wheel_pressed = ev.pressed
	
	if( ev.type == InputEvent.MOUSE_MOTION && wheel_pressed ):
		camera.set_pos(camera.get_pos()-ev.relative_pos)
		
	if( ev.type == InputEvent.MOUSE_BUTTON && ev.button_index == BUTTON_WHEEL_UP && ev.pressed ):
		camera.set_zoom( camera.get_zoom()-Vector2(0.05,0.05) )

#		grid_layer.set_mirroring(grid_layer.get_mirroring()/0.95)
		grid_texture.set_size(OS.get_window_size())
	if( ev.type == InputEvent.MOUSE_BUTTON && ev.button_index == BUTTON_WHEEL_DOWN && ev.pressed ):
		camera.set_zoom( camera.get_zoom()+Vector2(0.05,0.05) )
#		grid_layer.set_mirroring(grid_layer.get_mirroring()*0.95)
#		grid_texture.set_size(grid_texture.get_size()/0.95)





