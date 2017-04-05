extends Camera2D

onready var grid = get_node("../grid")

func on_middle_click_motion( mouse_relative_pos ):
	set_pos(get_pos()-mouse_relative_pos*get_zoom())


func on_wheel( button_index ):
	if( button_index == BUTTON_WHEEL_UP ):
		zoom_in()
	else:
		zoom_out()

func zoom_in():
	zoom("in")
func zoom_out():
	zoom("out")
func zoom_reset():
	zoom("reset")
func zoom(zoom_where):
	var new_size
	var new_zoom
	
	if( zoom_where == "reset" ):
		new_size = OS.get_window_size()
		new_zoom = Vector2(1,1)
		self.set_pos(Vector2(0,0))
	else:
		var tiles_screen_dim = OS.get_window_size()/Tiles.size/10
		var added_size = Tiles.size * tiles_screen_dim
		if( zoom_where == "in" ):
			added_size *= -1
		new_size = grid.grid_texture_virtual_size+added_size
		new_zoom = new_size/OS.get_window_size()

	if( new_zoom.x < 0.3 || new_zoom.y < 0.3):
		return
	
	self.set_zoom( new_zoom )
	grid.grid_layer.set_motion_scale(new_zoom)
	# texture size should be changed only on zoom superior to 1, else it is buggy
	# dunno why...
	if( new_zoom.x >= 1 || new_zoom.y >= 1 ):
		grid.grid_texture.set_size(new_size)
	grid.grid_texture_virtual_size = new_size
