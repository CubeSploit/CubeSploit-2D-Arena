extends Control

export(String) var list_node_path
export(String) var list_name

signal button_clicked(button_index)

onready var v_box_container = get_node("scroll_container/v_box_container")

var buttons = []

func set_all_pressed( pressed ):
	for i in range(buttons.size()):
		buttons[i].set_pressed(pressed)

func _ready():
	var list = get_node(list_node_path)[list_name]
	
	var list_id_iterator = range( list.size() )
	for id in list_id_iterator:
		v_box_container.add_child( HSeparator.new() )
		
		var texture_label_button = Button.new()
		buttons.append(texture_label_button)
		
		var texture = ImageTexture.new()
		texture.create_from_image( list[id].tex.get_data() )
		texture.set_size_override(Vector2(40,40))
		
		texture_label_button.set_button_icon( texture )
		texture_label_button.set_text( list[id].name )
		texture_label_button.set_clip_text(true)
#		texture_label_button.set_size(Vector2(100,40))
		texture_label_button.set_custom_minimum_size(Vector2(70,40))
		texture_label_button.set_toggle_mode(true)
		texture_label_button.connect("pressed",self,"on_tile_click",[id])
		
		v_box_container.add_child(texture_label_button)
		
		
	v_box_container.add_child( HSeparator.new() )

func on_tile_click(  button_index ):
	for i in range(buttons.size()):
		if( i != button_index ):
			buttons[i].set_pressed(false)
	emit_signal("button_clicked", button_index)