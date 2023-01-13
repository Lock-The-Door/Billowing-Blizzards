extends Control

func _ready():
	clonePlayer()

func clonePlayer():
	var player = get_node("/root/Game/Player")
	var clone = player.duplicate()
	clone.set_script(null)
	add_child(clone)
	
	# Add ui for upgrade slots
	
