extends Node2D

func _ready():
	pass

func _on_ship_editor_button_pressed():
	get_tree().change_scene("res://ship_editor.tscn")

func _on_exit_pressed():
	get_tree().quit()


