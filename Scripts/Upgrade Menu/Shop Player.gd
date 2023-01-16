extends Control

func _ready():
	get_node("/root/Game/Enemies").connect("level_completed", self, "_clonePlayer")

func _clonePlayer():
	# Remove existing player if needed
	_removePlayer()
	
	var player = get_node("/root/Game/Player")
	var clone = player.duplicate()
	clone.isNonplayable = true
	for child in clone.get_children():
		_removeScript(child)
	_removeCollision(clone)
	
	add_child(clone)
	
	# Add ui for upgrade slots
	
func _removePlayer():
	var player = get_node_or_null("Player")
	if not player:
		return
		
	player.queue_free()
	
func _removeCollision(node):
	for child in node.get_children():
		if child is CollisionShape2D:
			child.queue_free()
		else:
			_removeCollision(child)
func _removeScript(node):
	for child in node.get_children():
		child.set_script(null)
		_removeScript(child)
