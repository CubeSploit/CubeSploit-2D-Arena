extends Node2D

onready var ship_editor = get_parent()
onready var grid_data_manager = get_node("../grid_data_manager")
onready var grid_input_manager = get_node("../grid_input_manager")

onready var cursor = get_node("cursor")
onready var cursor_selected_tile_type = get_node("cursor/cursor_selected_tile_type")
onready var selected_tile_wire_1 = get_node("selected_tile_wire_1")
onready var selected_tile_wire_2 = get_node("selected_tile_wire_2")

onready var tile_tilemap = get_node("tile_tilemap")
onready var connection_tilemap = get_node("connection_tilemap")

onready var grid_layer = get_node("parallax_bg/parallax_layer")
onready var grid_texture = get_node("parallax_bg/parallax_layer/texture_frame")

var grid_texture_virtual_size = OS.get_window_size()


var need_update = false
var need_tile_update = false
var need_wire_update = false
var tiles_to_update = []



func _ready():
	set_process_unhandled_input(true)
	set_process(true)
	tile_tilemap.set_tileset(Tiles.get_tile_tileset())
	connection_tilemap.set_tileset(Tiles.get_connection_tileset())

func _process(delta):
	if( need_update ):
		update_tiles()
		update()
		need_update = false
		
	if( need_tile_update ):
		update_tiles_from_list()
		need_tile_update = false
		
	if( need_wire_update ):
		update()
		need_wire_update = false
	
	cursor.set_pos( grid_input_manager.cursor_pos )
	if( ship_editor.mouse_mode == ship_editor.MouseMode.TILE ):
		cursor_selected_tile_type.show()
		cursor_selected_tile_type.set_texture(Tiles.Data[ship_editor.selected_tile_type].tex)
	else:
		cursor_selected_tile_type.hide()
		
	
	if( grid_input_manager.wire_click_first != null ):
		selected_tile_wire_1.show()
		selected_tile_wire_1.set_pos( grid_input_manager.wire_click_first )
	else:
		selected_tile_wire_1.hide()
		
	if( grid_input_manager.wire_click_second != null ):
		selected_tile_wire_2.show()
		selected_tile_wire_2.set_pos( grid_input_manager.wire_click_second )
	else:
		selected_tile_wire_2.hide()







func update_tiles_from_list():
	var grid_data = grid_data_manager.get_grid_data()
	while( !tiles_to_update.empty() ):
		var tile_grid_pos = tiles_to_update.pop_front()
		tile_tilemap.set_cellv(tile_grid_pos, -1)
		connection_tilemap.set_cellv(tile_grid_pos, -1)
		if( grid_data.has_tile(tile_grid_pos) ):
			var tile = grid_data.get_tile(tile_grid_pos)
			tile_tilemap.set_cellv(tile_grid_pos, tile.type)
			connection_tilemap.set_cellv(tile_grid_pos, Tiles.get_connection_id(tile.connections))

func update_tiles():
	var grid_data = grid_data_manager.get_grid_data()
	var tiles_grid_pos = grid_data.get_tiles().keys()
	var tiles_pos_iterator = range(tiles_grid_pos.size())
	tile_tilemap.clear()
	connection_tilemap.clear()
	for i in tiles_pos_iterator:
		var tile_grid_pos = tiles_grid_pos[i]
		var tile = grid_data.get_tile(tile_grid_pos)
		var pos = grid_pos_to_pos(tile_grid_pos)
		tile_tilemap.set_cellv( tile_grid_pos, tile.type)
		connection_tilemap.set_cellv(tile_grid_pos, Tiles.get_connection_id(tile.connections))
	

func _draw():
	draw_wires()
	
func draw_wires():
	var grid_data = grid_data_manager.get_grid_data()
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







func grid_pos_to_pos( grid_pos ):
	return grid_pos*Tiles.size



func _on_grid_data_manager_grid_data_changed():
	need_update = true
func _on_grid_data_manager_tile_changed( tile_to_update ):
	need_tile_update = true
	tiles_to_update.append(tile_to_update)
func _on_grid_data_manager_wire_changed( wire_to_update ):
	need_wire_update = true
func _on_grid_data_manager_layer_changed( layer_to_update ):
	need_wire_update = true
