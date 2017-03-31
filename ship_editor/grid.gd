extends Node2D

onready var ship_editor = get_parent()
onready var camera = ship_editor.get_node("camera_2d")
onready var grid_layer = get_node("parallax_bg/parallax_layer")
onready var grid_texture = get_node("parallax_bg/parallax_layer/texture_frame")
onready var cursor = get_node("cursor")
onready var selected_tile_wire_1 = get_node("selected_tile_wire_1")
onready var selected_tile_wire_2 = get_node("selected_tile_wire_2")

var grid_texture_virtual_size = OS.get_window_size()

var wheel_pressed = false

var grid_data = {
	"tiles": {},
	"wires": {}
}
var undo_history = []
var redo_history = []
signal undo_history_empty()
signal undo_history_not_empty()
signal redo_history_empty()
signal redo_history_not_empty()



func _ready():
	set_process_unhandled_input(true)


func set_tile( grid_pos, tile_type ):
	doo()
	grid_data.tiles[grid_pos] = {
		"type": tile_type,
		"connections": [true,true,true,true]
	}
	update()
func erase_tile( grid_pos ):
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

	update_wire_mode_render()

func set_wire( p1, p2, p3, wire_type):
	if( grid_data.tiles.has(p2) ):
		doo()
		grid_data.wires[p2] = {
			"type": wire_type,
			"pin": p1,
			"pout": p3
		}
		update()
	else:
		reset_wire_mode()

func erase_wire( grid_pos ):
	doo()
	grid_data.wires.erase(grid_pos)
	update()

func reset_wire_mode():
	wire_click_first = null
	wire_click_second = null
	selected_tile_wire_1.hide()
	selected_tile_wire_2.hide()
	update_wire_mode_render()
	
func update_wire_mode_render():
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
	if( undo_history.empty() ):
		emit_signal("undo_history_empty")
	emit_signal("redo_history_not_empty")
	update()
func redo():
	undo_history.push_front(var2bytes(grid_data))
	grid_data= bytes2var( redo_history.pop_front() )
	if( redo_history.empty() ):
		emit_signal("redo_history_empty")
	emit_signal("undo_history_not_empty")
	update()

func get_grid_data():
	return var2bytes(grid_data)
func load_grid_data(grid_data):
	self.grid_data = bytes2var(grid_data)
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
				
	keys = grid_data.wires.keys()
	key_index_range = range(keys.size())
	for i in key_index_range:
		var key = keys[i]
		var wire = grid_data.wires[key]
		var pos = grid_pos_to_pos(key)
		if( wire.type == TilesMisc.Type.LogicWire ):
			draw_logic_wire( wire.pin, pos, wire.pout)
		elif( wire.type == TilesMisc.Type.EnergyWire ):
			draw_energy_wire( wire.pin, pos, wire.pout )
	

func draw_logic_wire( pin, pcenter, pout):
	pcenter = pcenter + TilesMisc.size/2
	pin = pcenter + (grid_pos_to_pos(pin)+ TilesMisc.size/2 - pcenter) /2
	pout = pcenter + (grid_pos_to_pos(pout)+ TilesMisc.size/2 - pcenter) /2
	draw_line(pin, pcenter, Color(0,0,0),2)
	draw_line(pcenter, pout, Color(0,0,0),2)
	
func draw_energy_wire( pin, pcenter, pout):
	pcenter = pcenter + TilesMisc.size/2
	pin = pcenter + (grid_pos_to_pos(pin)+ TilesMisc.size/2 - pcenter) /2
	pout = pcenter + (grid_pos_to_pos(pout)+ TilesMisc.size/2 - pcenter) /2
	draw_line(pin, pcenter, Color(0,0,0),6)
	draw_line(pin, pcenter, Color(255,255,255),2)
	draw_line(pcenter, pout, Color(0,0,0),6)
	draw_line(pcenter, pout, Color(255,255,255),2)




func on_left_click( mouse_pos ):
	var mouse_real_pos = mouse_pos_to_real_pos( mouse_pos )
	var mouse_grid_pos = pos_to_grid_pos(mouse_real_pos)
	if( ship_editor.mouse_mode == ship_editor.MouseMode.TILE ):
		set_tile(mouse_grid_pos, ship_editor.selected_tile_type)
	elif( ship_editor.mouse_mode == ship_editor.MouseMode.ERASER ):
		if( grid_data.wires.has(mouse_grid_pos) ):
			erase_wire( mouse_grid_pos )
		else:
			erase_tile( mouse_grid_pos )
	elif( ship_editor.mouse_mode == ship_editor.MouseMode.WIRE ):
		wire_click( mouse_grid_pos, ship_editor.selected_tile_type )
		
	if( ship_editor.mouse_mode != ship_editor.MouseMode.WIRE ):
		reset_wire_mode()

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


