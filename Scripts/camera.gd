class_name PlayerCamera
extends Node2D
# Centers the player on the screen


signal camera_moved

onready var _player := get_node("/root/Game/Player") as Player


func _process(_delta):
	# center the player on the screen
	position = _player.position

	# call all ui to recenter
	emit_signal("camera_moved")
