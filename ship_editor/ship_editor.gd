extends Node2D

onready var camera = get_node('camera_2d')
onready var grid_input_manager = get_node('grid_input_manager')
onready var grid_data_manager = get_node("grid_data_manager")

onready var tile_list = get_node("canvas_layer/ui/tab_container/Tiles")
onready var misc_tile_list = get_node("canvas_layer/ui/tab_container/Misc")
onready var select_button = get_node("canvas_layer/ui/editor_command_panel_container/h_box_container/select_button")
onready var erase_button = get_node("canvas_layer/ui/editor_command_panel_container/h_box_container/erase_button")
onready var undo_button = get_node("canvas_layer/ui/editor_command_panel_container/h_box_container/undo_button")
onready var redo_button = get_node("canvas_layer/ui/editor_command_panel_container/h_box_container/redo_button")

onready var layer_manager = get_node("canvas_layer/ui/layer_manager")

onready var save_file_dialog = get_node("canvas_layer/ui/editor_command_panel_container/save_file_dialog")
onready var load_file_dialog = get_node("canvas_layer/ui/editor_command_panel_container/load_file_dialog")

const MouseMode = {
	"SELECTION": 0,
	"TILE": 1,
	"ERASER": 2,
	"MISC_TILE": 3,
	"WIRE": 4,
	"SET_AS_BACKGROUND": 5,
	"SET_AS_FOREGROUND": 6
}


var selected_tile_type = 0
var tile_direction = Directions.Up
var mouse_mode = MouseMode.SELECTION
var left_click_pressed = false
var wheel_pressed = false

var file_path = null
var modifications = false

func _ready():
	set_process_unhandled_input(true)
	

func _unhandled_input(ev):
	# left click press
	if( ev.type == InputEvent.MOUSE_BUTTON && ev.button_index == BUTTON_LEFT && ev.pressed):
		grid_input_manager.on_left_click(ev.pos)
	
	# left click press/release
	if( ev.type == InputEvent.MOUSE_BUTTON && ev.button_index == BUTTON_LEFT ):
		left_click_pressed = ev.pressed
		if( !ev.pressed ):
			grid_input_manager.on_left_click_release()
	# mouse motion while holding left click down
	if( ev.type == InputEvent.MOUSE_MOTION && left_click_pressed ):
		grid_input_manager.on_left_click_motion( ev.pos )
		
	# middle click press/release
	if( ev.type == InputEvent.MOUSE_BUTTON && ev.button_index == BUTTON_MIDDLE ):
		wheel_pressed = ev.pressed
	# mouse motion while holding middle click down
	if( ev.type == InputEvent.MOUSE_MOTION && wheel_pressed ):
		camera.on_middle_click_motion( ev.relative_pos )
		

	
	# wheel
	if( ev.type == InputEvent.MOUSE_BUTTON && 
	( ev.button_index == BUTTON_WHEEL_UP || ev.button_index == BUTTON_WHEEL_DOWN ) &&
	ev.pressed ):
		camera.on_wheel( ev.button_index )

	# mouse motion
	if( ev.type == InputEvent.MOUSE_MOTION ):
		grid_input_manager.on_mouse_motion( ev.pos )
		
	if( Input.is_action_pressed("Up") ):
		tile_direction = Directions.Up
	if( Input.is_action_pressed("Right") ):
		tile_direction = Directions.Right
	if( Input.is_action_pressed("Down") ):
		tile_direction = Directions.Down
	if( Input.is_action_pressed("Left") ):
		tile_direction = Directions.Left
		


func _on_Tiles_button_clicked( button_index ):
	selected_tile_type = button_index
	mouse_mode = MouseMode.TILE
	misc_tile_list.unselect_all()
	select_button.set_pressed(false)
	erase_button.set_pressed(false)

func _on_Tiles_item_selected( index ):
	selected_tile_type = index
	mouse_mode = MouseMode.TILE
	misc_tile_list.unselect_all()
	select_button.set_pressed(false)
	erase_button.set_pressed(false)


func _on_Misc_item_selected( index ):
	selected_tile_type = index
	mouse_mode = MouseMode.MISC_TILE
	if( TilesMisc.is_wire_mode( index ) ):
		mouse_mode = MouseMode.WIRE
	elif( index == TilesMisc.Type.SetAsBackground ):
		mouse_mode = MouseMode.SET_AS_BACKGROUND
	elif( index == TilesMisc.Type.SetAsForeground ):
		mouse_mode = MouseMode.SET_AS_FOREGROUND
	tile_list.unselect_all()
	select_button.set_pressed(false)
	erase_button.set_pressed(false)

func _on_select_button_pressed():
	mouse_mode = MouseMode.SELECTION
	tile_list.unselect_all()
	misc_tile_list.unselect_all()
	erase_button.set_pressed(false)

func _on_erase_button_pressed():
	mouse_mode = MouseMode.ERASER
	tile_list.unselect_all()
	misc_tile_list.unselect_all()
	select_button.set_pressed(false)

	
func _on_undo_button_pressed():
	grid_data_manager.undo()
func _on_redo_button_pressed():
	grid_data_manager.redo()

func _on_grid_data_manager_redo_history_empty():
	if( redo_button != null ):
		redo_button.set_disabled(true)
func _on_grid_data_manager_redo_history_not_empty():
	redo_button.set_disabled(false)
func _on_grid_data_manager_undo_history_empty():
	undo_button.set_disabled(true)
func _on_grid_data_manager_undo_history_not_empty():
	if( undo_button != null ):
		undo_button.set_disabled(false)



func _on_save_button_pressed():
	save_file_dialog.popup_centered()
func _on_file_dialog_file_selected( path ):
	grid_data_manager.save_grid_data(path)
	file_path = path
func _on_load_button_pressed():
	load_file_dialog.popup_centered()
func _on_load_file_dialog_file_selected( path ):
	grid_data_manager.load_grid_data(path)
	file_path = path



func _on_zoom_in_button_pressed():
	camera.zoom_in()
func _on_zoom_out_button_pressed():
	camera.zoom_out()
func _on_reset_zoom_button_pressed():
	camera.zoom_reset()




func _on_exit_button_pressed():
	get_tree().change_scene_to(global.Scenes.MAIN)

