extends Control

func _draw():
	# center on screen
	var center = get_node("/root/Game/Camera2D").position
	
	rect_position = center - rect_size / 2
