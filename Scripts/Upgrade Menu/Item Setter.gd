extends Button

const UBG = preload("res://Resources/UpgradesButtonGroup.tres")
onready var _realPlayer = get_node("/root/Game/Player")
onready var _shopPopulator = get_node("/root/Game/Daily Upgrade/ColorRect/VBoxContainer/Body/Shop Background/Shop/Items")
onready var _playerView = get_node("/root/Game/Daily Upgrade/ColorRect/VBoxContainer/Body/Player Background/Player View")
var _item = null

func init(itemData):
	_item = itemData
	
	var status = connect("pressed", self, "_setItem")
	if status != OK:
		print("not connected")
	
func _setItem():
	# get the current slot
	var selectedSlot = UBG.get_pressed_button()
	
	var itemResource = null
	if _item != null:
		_realPlayer.addSnow(-_item.price)
		itemResource = load(_item.resource)
	
	match selectedSlot.type:
		"body":
			var clonePlayer = _playerView.get_node("Player")
			
			# instantiate the body type, set it up, and resolve
			var cloneBody = itemResource.instance()
			clonePlayer.bodyCount += 1
			cloneBody.init(clonePlayer.bodyCount)
			clonePlayer.add_child(cloneBody)
			clonePlayer.resolveBodyParts()
			
			var realBody = itemResource.instance()
			_realPlayer.bodyCount += 1
			realBody.init(_realPlayer.bodyCount)
			_realPlayer.add_child(realBody)
			_realPlayer.resolveBodyParts()
			_realPlayer.addHealth(realBody.health)
			
			# add new slots
			_playerView.addSlots()
			
			# body maxout
			if _realPlayer.bodyCount >= _realPlayer.maxBodies:
				selectedSlot.queue_free()
				_shopPopulator.clearShop()
				return # end early to prevent repopulation
		"arm":
			# get the body of the slot
			var selectedSlotBody = selectedSlot.itemBody
			# get the actual player's body
			var playerBody = _realPlayer.get_child(selectedSlotBody.get_index())
			
			# item instance
			var itemInstance = null
			if _item != null:
				itemInstance = itemResource.instance()
				
			# set the item in the slot
			selectedSlot.setItem(itemInstance)

			# set the item in the player bodies
			selectedSlotBody.addItem(itemInstance, selectedSlot.itemLocation)
			if _item != null:
				itemInstance = itemResource.instance()
			playerBody.addItem(itemInstance, selectedSlot.itemLocation)
			
	# refresh shop
	_shopPopulator.populateShop(selectedSlot)
