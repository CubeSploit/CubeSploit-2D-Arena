extends Control

onready var button = get_node("button")
onready var line_edit = get_node("line_edit")
onready var color_picker_button = get_node("color_picker_button")
onready var disable_sight_button = get_node("disable_sight_button")
onready var enable_sight_button = get_node("enable_sight_button")


var selected = false

signal selected()
signal name_changed(name)
signal color_changed(color)
signal disabled_sight()
signal enabled_sight()

var name = "Default"
var color = Color(255,255,255)
var sight = true

func _ready():
	button.set_text(name)
	color_picker_button.set_color(color)
	color_picker_button.get_picker().connect("hide", self,"_on_color_picker_hide")
	set_sight(sight)
	

func set_name(name):
	self.name = name
	if( button ):
		button.set_text(name)
func set_color(color):
	self.color = color
	if( color_picker_button ):
		color_picker_button.set_color(color)
func set_sight(sight):
	self.sight = sight
	if( disable_sight_button == null || enable_sight_button == null ):
		return
	if( !sight ):
		disable_sight_button.hide()
		enable_sight_button.show()
	else:
		disable_sight_button.show()
		enable_sight_button.hide()


func _on_button_pressed():
	if( selected == true ):
		line_edit.set_text(button.get_text())
		line_edit.show()
		line_edit.grab_focus()
	else:
		selected = true
		button.set_toggle_mode(true)
		button.set_pressed(true)
		emit_signal("selected")

func unselect():
	selected = false
	button.set_pressed(false)
	button.set_toggle_mode(false)
	line_edit.hide()
func select():
	_on_button_pressed()
func default_select():
	selected = true
	button.set_toggle_mode(true)
	button.set_pressed(true)


func _on_line_edit_text_entered( text ):
	line_edit.hide()
	button.set_text(text)
	name = text
	emit_signal("name_changed", name)

func _on_color_picker_hide( ):
	color = color_picker_button.get_color()
	emit_signal("color_changed", color)


func _on_line_edit_focus_exit():
	line_edit.hide()
	button.set_text(line_edit.get_text())
	name = line_edit.get_text()



func _on_disable_sight_button_pressed():
	set_sight(false)
	emit_signal("disabled_sight")
func _on_enable_sight_button_pressed():
	set_sight(true)
	emit_signal("enabled_sight")
