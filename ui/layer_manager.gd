extends Control

onready var layer_container = get_node("panel_container/scroll_container/v_box_container")
var layer_button_scene = preload("res://ui/editable_button_with_color_picker.tscn")

var layers = []
var selected_layer
signal layer_selected(layer_id)
signal layer_added(layer_id, layer_name, layer_color)
signal default_layer_added(layer_id, layer_name, layer_color)
signal layer_deleted(layer_id)
signal layer_name_changed(layer_id, layer_name)
signal layer_color_changed(layer_id, layer_color)

func _ready():
	var layer = add_layer("Default", null)
	layer.select()
	emit_signal("layer_added", 0, layer.name, layer.color)

func load_layers( layers ):
	while( self.layers.size() != 0 ):
		delete_layer(0)
	for i in range(layers.size()):
		add_layer(layers[i].name, layers[i].color)

func add_layer(name = null, color = null):
	var layer = layer_button_scene.instance()
	var id = layers.size()
	name = name if name != null else ("layer"+str(id))
	color = color if color != null else Color(255,255,255)
	
	layers.append(layer)
	
	selected_layer = id
	
	layer.set_name( name )
	layer.set_color( color )
	layer.connect("selected",self,"on_layer_select", [layer])
	layer.connect("name_changed",self,"on_layer_name_change", [layer])
	layer.connect("color_changed",self,"on_layer_color_change", [layer])
	
	layer_container.add_child(layer)
	
	return layer
	

func on_layer_select(layer):
	var layer_id = layers.find(layer)
	for id in range(layers.size()):
		if( id != layer_id ):
			layers[id].unselect()
	selected_layer = layer_id
	emit_signal("layer_selected", layer_id)
			
func on_layer_name_change(name, layer):
	var layer_id = layers.find(layer)
	emit_signal("layer_name_changed", layer_id, name)

func on_layer_color_change(color, layer):
	var layer_id = layers.find(layer)
	emit_signal("layer_color_changed", layer_id, color)


func _on_new_layer_button_pressed():
	var layer = add_layer()
	layer.select()
	emit_signal("layer_added", 0, layer.name, layer.color)

func _on_delete_layer_button_pressed():
	if( layers.size() != 1 ):
		emit_signal("layer_deleted", selected_layer)
		delete_layer(selected_layer)

func delete_layer(layer_id):
	layer_container.remove_child(layers[layer_id])
	layers.remove(layer_id)
	if( layers.size() > 0 ):
		layers[0].select()
		
