extends Control

func _ready():
	var status = get_viewport().connect("size_changed", self, "centerScale")
	assert(status == OK)
	status = get_node("/root/Game/Camera2D").connect("camera_moved", self, "centerScale")

func centerScale():
	if not visible:
		return
	
	# center on screen
	var center = get_node("/root/Game/Camera2D").position
	rect_position = center - rect_size / 2

	# resize ro screen
	var viewportSize = get_viewport_rect().size
	rect_size = viewportSize
