extends Node2D

onready var camera = get_node('camera_2d')
onready var grid = get_node("grid")

onready var tile_list = get_node("canvas_layer/ui/tab_container/Tiles")
onready var misc_command_list = get_node("canvas_layer/ui/tab_container/Misc")
onready var select_button = get_node("canvas_layer/ui/editor_command_panel_container/h_box_container/select_button")
onready var erase_button = get_node("canvas_layer/ui/editor_command_panel_container/h_box_container/erase_button")
onready var undo_button = get_node("canvas_layer/ui/editor_command_panel_container/h_box_container/undo_button")
onready var redo_button = get_node("canvas_layer/ui/editor_command_panel_container/h_box_container/redo_button")

onready var save_file_dialog = get_node("canvas_layer/ui/save_file_dialog")
onready var load_file_dialog = get_node("canvas_layer/ui/load_file_dialog")

const MouseMode = {
	"SELECTION": 0,
	"TILE": 1,
	"ERASER": 2
}

const MiscButtonList = [
	
]

var selected_tile_type = 0
var mouse_mode = MouseMode.SELECTION
var wheel_pressed = false

var file_path = null
var modifications = false

func _ready():
	misc_command_list.list_node_path = get_path()
	misc_command_list.list_name = "MiscButtonList"
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


func _on_Tiles_button_clicked( button_index ):
	selected_tile_type = button_index
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
	save_file_dialog.popup_centered()
func _on_file_dialog_file_selected( path ):
	var content = grid.get_grid_data()
	var file = File.new()
	file.open(path, file.WRITE)
	file.store_string(content)
	file.close()
	file_path = path
func _on_load_button_pressed():
	load_file_dialog.popup_centered()
func _on_load_file_dialog_file_selected( path ):
	var file = File.new()
	file.open(path, file.READ)
	var content = file.get_as_text()
	file.close()
	grid.load_grid_data(content)
	file_path = path



func _on_zoom_in_button_pressed():
	grid.zoom_in()
func _on_zoom_out_button_pressed():
	grid.zoom_out()
func _on_reset_zoom_button_pressed():
	grid.zoom_reset()




func _on_exit_button_pressed():
	get_tree().change_scene_to(global.Scenes.MAIN)





