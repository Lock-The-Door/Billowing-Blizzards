class_name ShopPlayer
extends Control
# This is a clone of the player that is used to display in the shop


const UPGRADE_SLOT = preload("res://Templates/Upgrades/Upgrade Slot.tscn")

onready var _player = get_node("/root/Game/Player")
onready var _shop_populator = get_node("%Items")


func _ready():
	var status = get_node("/root/Game/Enemies").connect("level_completed", self, "clone_player")
	assert(status == OK)


var _clone = null
func clone_player():
	# Remove existing player if needed
	_remove_player()
	
	_clone = _player.duplicate() as Player
	_clone.is_nonplayable = true
	_clone.modulate = Color.white
	_clone.body_count = _player.body_count
	_remove_collision(_clone)
	
	_clone.position = Vector2(0, 0)
	
	add_child(_clone)
	
	add_slots()
	
	# Clear the shop (the slot buttons are new)
	_shop_populator.clear_shop(true)


# upgrade slot ui
func add_slots():
	# Remove existing buttons
	for child in get_children():
		if child is Button and child.type != "body":
			child.queue_free()
	
	# Add ui for upgrade slots
	for body in _clone.get_children():
		if body.is_in_group("Body"):
			# get reference to original body
			var original_body = _player.get_child(body.get_index())
			
			# body config
			var body_slots = body.item_config
			for location in original_body.items: # recreate item list
				var original_item = original_body.items[location]
				if original_item == null:
					body.items[location] = null
					continue
				var cloned_child = body.get_child(original_item.get_index())
				body.items[location] = cloned_child

			for location in body_slots:
				var slot = UPGRADE_SLOT.instance()
				slot.type = "arm"
				slot.item_body = body
				slot.item_location = location
				add_child(slot)
				slot.rect_position = body_slots[location]["position"]*4 - Vector2(50, 50) + body.position/4
				slot.set_item(body.items[location])


func _remove_player():
	if _clone == null:
		return
		
	_clone.queue_free()


func _remove_collision(node):
	for child in node.get_children():
		if child is CollisionShape2D:
			child.queue_free()
		else:
			_remove_collision(child)



func _remove_script(node):
	for child in node.get_children():
		child.set_script(null)
		_remove_script(child)
