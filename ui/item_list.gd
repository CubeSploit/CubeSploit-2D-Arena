extends ItemList

export(String) var list_node_path
export(String) var list_name

func _ready():
	set_max_columns(1)
	set_select_mode(ItemList.SELECT_SINGLE)
	
	var list = get_node(list_node_path)[list_name]
	
	var list_id_iterator = range( list.size() )
	for id in list_id_iterator:
		
		var texture = ImageTexture.new()
		texture.create_from_image( list[id].tex.get_data() )
		texture.set_size_override(Vector2(40,40))
		
		add_item(list[id].name, texture)

func unselect_all( ):
	var idx_array = get_selected_items()
	var idx_array_iterator = range(idx_array.size())
	for idx in idx_array_iterator:
		unselect(idx_array[idx])