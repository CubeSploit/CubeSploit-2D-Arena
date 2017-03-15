extends Node2D

onready var grid = get_node('grid')

var wheel_pressed = false

func _ready():
	set_process_input(true)
	
func _input(ev):
	if( ev.type == InputEvent.MOUSE_BUTTON && ev.button_index == BUTTON_MIDDLE ):
		wheel_pressed = ev.pressed
	
	if( ev.type == InputEvent.MOUSE_MOTION && wheel_pressed ):
		pass
#		grid.set_pos(grid.get_pos()+ev.relative_pos)
#		get_viewport().set_canvas_transform(get_viewport().get_canvas_transform().translated(ev.relative_pos))