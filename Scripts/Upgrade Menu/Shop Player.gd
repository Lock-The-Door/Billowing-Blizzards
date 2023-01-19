extends Control

const UPGRADE_SLOT = preload("res://Templates/Upgrades/Upgrade Slot.tscn")
onready var _player = get_node("/root/Game/Player")
onready var _shopPopulator = get_node("/root/Game/Daily Upgrade/ColorRect/VBoxContainer/Body/Shop Background/Shop/Items")

func _ready():
	var status = get_node("/root/Game/Enemies").connect("level_completed", self, "clonePlayer")
	if status != OK:
		print("not connected")

var _clone = null
func clonePlayer():
	# Remove existing player if needed
	_removePlayer()
	
	_clone = _player.duplicate()
	_clone.isNonplayable = true
	_clone.bodyCount = _player.bodyCount
	_removeCollision(_clone)
	
	_clone.position = Vector2(0, 0)
	
	add_child(_clone)
	
	addSlots()
	
	# Clear the shop (the slot buttons are new)
	_shopPopulator.clearShop(true)
	
# upgrade slot ui
func addSlots():
	# Remove existing buttons
	for child in get_children():
		if child is Button and child.type != "body":
			child.queue_free()
	
	# Add ui for upgrade slots
	for body in _clone.get_children():
		if body.is_in_group("Body"):
			# get reference to original body
			var originalBody = _player.get_child(body.get_index())
			
			# body config
			var bodySlots = body.itemConfig
			for location in originalBody.items: # recreate item list
				var originalItem = originalBody.items[location]
				if originalItem == null:
					body.items[location] = null
					continue
				var clonedChild = body.get_child(originalItem.get_index())
				body.items[location] = clonedChild

			for location in bodySlots:
				var slot = UPGRADE_SLOT.instance()
				slot.type = "arm"
				slot.itemBody = body
				slot.itemLocation = location
				add_child(slot)
				slot.rect_position = bodySlots[location]["position"]*4 - Vector2(50, 50) + body.position/4
				slot.setItem(body.items[location])
	
func _removePlayer():
	if _clone == null:
		return
		
	_clone.queue_free()
	
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
