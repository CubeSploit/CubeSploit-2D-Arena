extends Control

onready var layer_container = get_node("panel_container/scroll_container/v_box_container")

func _ready():
	var layers = layer_container.get_children()
	for id in range(layers.size()):
		layers[id].connect("selected",self,"on_layer_select", [id])
	

func on_layer_select(layer_id):
	var layers = layer_container.get_children()
	for id in range(layers.size()):
		if( id != layer_id ):
			layers[id].unselect()
