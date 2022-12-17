extends Node2D


func _process(delta):
	# center the player on the screen
	position = get_node("/root/Game/Player").position
