class_name ItemSetter
extends Button
# This class is used to set the item in the slot


const UBG = preload("res://Resources/UpgradesButtonGroup.tres")

var _item = null

onready var _real_player = get_node("/root/Game/Player")
onready var _shop_populator = get_node("%Items")
onready var _player_view = get_node("/root/Game/Daily Upgrade/ColorRect/VBoxContainer/Body/Player Background/Player View")


func init(item_data):
	_item = item_data
	
	var status = connect("pressed", self, "_set_item")
	assert(status == OK)
	
func _set_item():
	# get the current slot
	var selected_slot = UBG.get_pressed_button()
	
	var item_resource = null
	if _item != null:
		_real_player.add_snow(-_item.price)
		item_resource = load(_item.resource)
	
	match selected_slot.type:
		"body":
			var clone_player = _player_view.get_node("Player")
			
			# instantiate the body type, set it up, and resolve
			var clone_body = item_resource.instance()
			clone_player.body_count += 1
			clone_body.init(clone_player.body_count)
			clone_player.add_child(clone_body)
			clone_player.resolve_body_parts()
			
			var real_body = item_resource.instance()
			_real_player.body_count += 1
			real_body.init(_real_player.body_count)
			_real_player.add_child(real_body)
			_real_player.resolve_body_parts()
			_real_player.add_health(real_body.health)
			
			# add new slots
			_player_view.add_slots()
			
			# body maxout
			if _real_player.body_count >= _real_player.max_bodies:
				selected_slot.queue_free()
				_shop_populator.clear_shop()
				return # end early to prevent repopulation
		"arm":
			# get the body of the slot
			var selected_slotBody = selected_slot.item_body
			# get the actual player's body
			var player_body = _real_player.get_child(selected_slotBody.get_index())
			
			# item instance
			var item_instance = null
			if _item != null:
				item_instance = item_resource.instance()
				
			# set the item in the slot
			selected_slot.set_item(item_instance)

			# set the item in the player bodies
			selected_slotBody.addItem(item_instance, selected_slot.item_location)
			if _item != null:
				item_instance = item_resource.instance()
			player_body.addItem(item_instance, selected_slot.item_location)
			
	# refresh shop
	_shop_populator.populate_shop(selected_slot)
