extends Node2D

func _process(_delta):
	# center the player on the screen
	position = get_node("/root/Game/Player").position

	# call all ui to recenter
	for child in get_parent().get_children():
		if (load("res://Scripts/Center Ui.gd") as Script).instance_has(child):
			child.centerScale()