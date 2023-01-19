extends Button

const UBG = preload("res://Resources/UpgradesButtonGroup.tres")
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

	match selectedSlot.type:
		"body":
			pass
		"arm":
			# get the body of the slot
			var selectedSlotBody = selectedSlot.itemBody
			# get the actual player's body
			var playerBody = get_node("/root/Game/Player").get_child(selectedSlotBody.get_index())
			
			# item instance
			var itemInstance = null
			if _item != null:
				itemInstance = load(_item.resource).instance()
				
			# set the item in the slot
			selectedSlot.setItem(itemInstance)

			# set the item in the player bodies
			selectedSlotBody.addItem(itemInstance, selectedSlot.itemLocation)
			if _item != null:
				itemInstance = load(_item.resource).instance()
			playerBody.addItem(itemInstance, selectedSlot.itemLocation)
			
			# refresh shop
			_shopPopulator.populateShop(selectedSlot)
			# reclone player
			#_playerView.clonePlayer()
