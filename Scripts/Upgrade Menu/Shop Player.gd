extends Control

const UPGRADE_SLOT = preload("res://Templates/Upgrades/Upgrade Slot.tscn")

func _ready():
	get_node("/root/Game/Enemies").connect("level_completed", self, "_clonePlayer")

func _clonePlayer():
	# Remove existing player if needed
	_removePlayer()
	
	var player = get_node("/root/Game/Player")
	var clone = player.duplicate()
	clone.isNonplayable = true
	_removeCollision(clone)
	
	add_child(clone)
	
	# Add ui for upgrade slots
	for body in clone.get_children():
		if body.is_in_group("Body"):
			# get reference to original body
			var originalBody = player.get_child(body.get_index())
			var bodySlots = body.itemConfig
			body.items = originalBody.items

			for location in bodySlots:
				var slot = UPGRADE_SLOT.instance()
				slot.type = "arm"
				add_child(slot)
				slot.rect_position = bodySlots[location]["position"]*4 - Vector2(50, 50) + body.position/4
				slot.setItem(body.items[location])
	
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
