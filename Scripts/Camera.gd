extends Node2D


func _process(_delta):
	# center the player on the screen
	position = get_node("/root/Game/Player").position
