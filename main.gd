extends Node2D

func _ready():
	pass

func _on_ship_editor_button_pressed():
	get_tree().change_scene_to(global.Scenes.SHIP_EDITOR)

func _on_exit_pressed():
	get_tree().quit()


