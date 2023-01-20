extends Node2D

signal camera_moved

func _process(_delta):
	# center the player on the screen
	position = get_node("/root/Game/Player").position

	# call all ui to recenter
	emit_signal("camera_moved")
