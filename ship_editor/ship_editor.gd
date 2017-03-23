extends Node2D

onready var camera = get_node('camera_2d')
onready var grid = get_node("grid")

onready var tile_list = get_node("canvas_layer/ui/tile_list")
onready var select_button = get_node("canvas_layer/ui/editor_command_panel_container/h_box_container/select_button")
onready var erase_button = get_node("canvas_layer/ui/editor_command_panel_container/h_box_container/erase_button")
onready var undo_button = get_node("canvas_layer/ui/editor_command_panel_container/h_box_container/undo_button")
onready var redo_button = get_node("canvas_layer/ui/editor_command_panel_container/h_box_container/redo_button")

const MouseMode = {
	"SELECTION": 0,
	"TILE": 1,
	"ERASER": 2
}

var selected_tile_type = 0
var mouse_mode = MouseMode.SELECTION
var wheel_pressed = false

var file_name = null
var modifications = false

func _ready():
	set_process_unhandled_input(true)
	

func _unhandled_input(ev):
	# left click
	if( ev.type == InputEvent.MOUSE_BUTTON && ev.button_index == BUTTON_LEFT && ev.pressed):
		grid.on_left_click(ev.pos)
	
	# middle click
	if( ev.type == InputEvent.MOUSE_BUTTON && ev.button_index == BUTTON_MIDDLE ):
		wheel_pressed = ev.pressed
	
	# mouse motion while holding middle click down
	if( ev.type == InputEvent.MOUSE_MOTION && wheel_pressed ):
		grid.on_middle_click_motion( ev.relative_pos )
	
	# wheel
	if( ev.type == InputEvent.MOUSE_BUTTON && 
	( ev.button_index == BUTTON_WHEEL_UP || ev.button_index == BUTTON_WHEEL_DOWN ) &&
	ev.pressed ):
		grid.on_wheel( ev.button_index )

	# mouse motion
	if( ev.type == InputEvent.MOUSE_MOTION ):
		grid.on_mouse_motion( ev.pos )


func _on_tile_list_tile_type_selected( tile_type ):
	selected_tile_type = tile_type
	mouse_mode = MouseMode.TILE
	select_button.set_pressed(false)
	erase_button.set_pressed(false)

func _on_select_button_pressed():
	mouse_mode = MouseMode.SELECTION
	tile_list.set_all_pressed(false)
	erase_button.set_pressed(false)

func _on_erase_button_pressed():
	mouse_mode = MouseMode.ERASER
	tile_list.set_all_pressed(false)
	select_button.set_pressed(false)

	
func _on_undo_button_pressed():
	grid.undo()
func _on_redo_button_pressed():
	grid.redo()

func _on_grid_undo_history_empty():
	undo_button.set_disabled(true)
func _on_grid_undo_history_not_empty():
	undo_button.set_disabled(false)
func _on_grid_redo_history_empty():
	redo_button.set_disabled(true)
func _on_grid_redo_history_not_empty():
	redo_button.set_disabled(false)




func _on_save_button_pressed():
	pass # replace with function body
func _on_load_button_pressed():
	pass # replace with function body



func _on_zoom_in_button_pressed():
	grid.zoom_in()
func _on_zoom_out_button_pressed():
	grid.zoom_out()
func _on_reset_zoom_button_pressed():
	grid.zoom_reset()




func _on_exit_button_pressed():
	get_tree().change_scene_to(global.Scenes.MAIN)



