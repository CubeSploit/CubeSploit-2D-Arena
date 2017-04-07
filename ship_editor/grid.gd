extends Node2D

onready var ship_editor = get_parent()
onready var camera = get_node("../camera_2d")
onready var grid_data_manager = get_node("../grid_data_manager")

onready var cursor = get_node("cursor")
onready var selected_tile_wire_1 = get_node("selected_tile_wire_1")
onready var selected_tile_wire_2 = get_node("selected_tile_wire_2")

onready var tile_tilemap = get_node("tile_tilemap")
onready var connection_tilemap = get_node("connection_tilemap")

onready var grid_layer = get_node("parallax_bg/parallax_layer")
onready var grid_texture = get_node("parallax_bg/parallax_layer/texture_frame")

var grid_texture_virtual_size = OS.get_window_size()

var left_click_last_mouse_pos
var left_click_last_mouse_grid_pos
var left_click_drag_mode = false
var wheel_pressed = false

var need_update = false
var tiles_to_update = []



func _ready():
	set_process_unhandled_input(true)
	set_process(true)
	tile_tilemap.set_tileset(Tiles.get_tile_tileset())
	connection_tilemap.set_tileset(Tiles.get_connection_tileset())

func _process(delta):
	if( !tiles_to_update.empty() ):
		var grid_data = grid_data_manager.get_grid_data()
		while( !tiles_to_update.empty() ):
			var tile_grid_pos = tiles_to_update.pop_front()
			tile_tilemap.set_cellv(tile_grid_pos, -1)
			connection_tilemap.set_cellv(tile_grid_pos, -1)
			if( grid_data.has_tile(tile_grid_pos) ):
				var tile = grid_data.get_tile(tile_grid_pos)
				tile_tilemap.set_cellv(tile_grid_pos, tile.type)
				connection_tilemap.set_cellv(tile_grid_pos, Tiles.get_connection_id(tile.connections))
	
	if( need_update ):
		update()
		need_update = false



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




	
func _draw():
	var grid_data = grid_data_manager.get_grid_data()
	var tiles_grid_pos = grid_data.get_tiles().keys()
	var tiles_pos_iterator = range(tiles_grid_pos.size())
	tile_tilemap.clear()
	connection_tilemap.clear()
	for i in tiles_pos_iterator:
		var tile_grid_pos = tiles_grid_pos[i]
		var tile = grid_data.get_tile(tile_grid_pos)
		var pos = grid_pos_to_pos(tile_grid_pos)
#		draw_texture( Tiles.Data[tile.type].tex, pos)
#		for d in global.direction_iterator:
#			if( tile.connections[d] ):
#				draw_texture( Tiles.connection_textures[d], pos )
		tile_tilemap.set_cellv( tile_grid_pos, tile.type)
		connection_tilemap.set_cellv(tile_grid_pos, Tiles.get_connection_id(tile.connections))
	
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
#	draw_line(pin, pcenter, color,2)
#	draw_line(pcenter, pout, color,2)
	var extents = pcenter-pin
	var offset = Vector2(0,0)
	offset.x = 0 if extents.x != 0 else 1
	offset.y = 0 if extents.y != 0 else 1
	extents.x = extents.x if extents.x != 0 else 2
	extents.y = extents.y if extents.y != 0 else 2
	draw_rect( Rect2(pin-offset, extents), color)
	
	extents = pcenter-pout
	offset = Vector2(0,0)
	offset.x = 0 if extents.x != 0 else 1
	offset.y = 0 if extents.y != 0 else 1
	extents.x = extents.x if extents.x != 0 else 2
	extents.y = extents.y if extents.y != 0 else 2
	draw_rect( Rect2(pout-offset, extents), color)
	
func draw_energy_wire( pin, pcenter, pout, color):
	pcenter = pcenter + TilesMisc.size/2
	pin = pcenter + (grid_pos_to_pos(pin)+ TilesMisc.size/2 - pcenter) /2
	pout = pcenter + (grid_pos_to_pos(pout)+ TilesMisc.size/2 - pcenter) /2
#	draw_line(pin, pcenter, color,5)
	var extents = pcenter-pin
	var offset = Vector2(0,0)
	offset.x = 0 if extents.x != 0 else 3
	offset.y = 0 if extents.y != 0 else 3
	extents.x = extents.x if extents.x != 0 else 6
	extents.y = extents.y if extents.y != 0 else 6
	draw_rect( Rect2(pin-offset, extents), color)
	
#	draw_line(pin, pcenter, Color(255,255,255),1)
	extents = pcenter-pin
	offset = Vector2(0,0)
	offset.x = 0 if extents.x != 0 else 1
	offset.y = 0 if extents.y != 0 else 1
	extents.x = extents.x if extents.x != 0 else 2
	extents.y = extents.y if extents.y != 0 else 2
	draw_rect( Rect2(pin-offset, extents), Color(255,255,255))
	
	
#	draw_line(pcenter, pout, color,5)
	var extents = pcenter-pout
	var offset = Vector2(0,0)
	offset.x = 0 if extents.x != 0 else 3
	offset.y = 0 if extents.y != 0 else 3
	extents.x = extents.x if extents.x != 0 else 6
	extents.y = extents.y if extents.y != 0 else 6
	draw_rect( Rect2(pout-offset, extents), color)
	
#	draw_line(pcenter, pout, Color(255,255,255),1)
	extents = pcenter-pout
	offset = Vector2(0,0)
	offset.x = 0 if extents.x != 0 else 1
	offset.y = 0 if extents.y != 0 else 1
	extents.x = extents.x if extents.x != 0 else 2
	extents.y = extents.y if extents.y != 0 else 2
	draw_rect( Rect2(pout-offset, extents), Color(255,255,255))




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



func _on_grid_data_manager_grid_data_changed():
	need_update = true
func _on_grid_data_manager_tile_changed( tile_to_update ):
	tiles_to_update.append(tile_to_update)
