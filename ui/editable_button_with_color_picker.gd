extends Control

onready var button = get_node("button")
var selected = false

signal selected()

func _ready():
	pass



func _on_button_pressed():
	if( selected == true ):
		pass
	selected = true
	button.set_toggle_mode(true)
	button.set_pressed(true)
	emit_signal("selected")

func unselect():
	selected = false
	button.set_pressed(false)
	button.set_toggle_mode(false)
