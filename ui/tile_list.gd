extends Control

onready var v_box_container = get_node("scroll_container/v_box_container")

func _ready():
	var tile_id_iterator = range( Tiles.count )
	for tile_id in tile_id_iterator:
		v_box_container.add_child( HSeparator.new() )
		
		var texture_label_button = ToolButton.new()
		
		var texture = ImageTexture.new()
		texture.create_from_image( Tiles.Data[tile_id].tex.get_data() )
		texture.set_size_override(Vector2(40,40))
		
		texture_label_button.set_button_icon( texture )
		texture_label_button.set_text( Tiles.Data[tile_id].name )
		texture_label_button.set_clip_text(true)
		texture_label_button.set_size(Vector2(100,40))
		texture_label_button.connect("pressed",self,"on_tile_click",[tile_id])
		
		v_box_container.add_child(texture_label_button)
		
		
	v_box_container.add_child( HSeparator.new() )


func on_tile_click(  tile_id ):
	print("Tile pressed ", tile_id)