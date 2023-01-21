class_name CenterUi
extends Control
# Centers the ui and scale it accordingly


onready var _camera := get_node("/root/Game/Camera2D") as PlayerCamera


func _ready():
	var status = get_viewport().connect("size_changed", self, "center_scale")
	assert(status == OK)
	status = _camera.connect("camera_moved", self, "center_scale")
	assert(status == OK)


func center_scale():
	if not visible:
		return
	
	# center on screen
	var center = _camera.position
	rect_position = center - rect_size / 2

	# resize ro screen
	var viewportSize = get_viewport_rect().size
	rect_size = viewportSize
