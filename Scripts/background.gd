extends TextureRect
# Changes the background size accordingly
# Uses the world size and screen size to determine a correct size


const WORLD_SIZE = preload("res://Scripts/globals.gd").WORLD_SIZE


func _ready():
	resize()
	var connection_result = get_tree().get_root().connect("size_changed", self, "resize")
	assert(connection_result == OK)
	
	
func resize():
	# get window size
	var window_size = get_viewport_rect().size
	# set size of the texture
	set_size(WORLD_SIZE + window_size)
	# set position of the texture
	set_position(-get_rect().size / 2)
