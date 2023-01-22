class_name ShopPopulator
extends HBoxContainer
# Populates the shop with shop items
# It will randomly select 3 possible upgrades the player can buy for a 
# particular slot


const SHOP_ITEM = preload("res://Templates/Upgrades/Shop Item.tscn")

var shop_data
var _slot_items = {}

onready var _game_manager := get_node("/root/Game") as GameManager
onready var _player := get_node("/root/Game/Player") as Player
onready var _unselected_message := get_node("Unselected Message") as Label


func _ready():
	# Read the shop data
	var shop_file = File.new()
	shop_file.open("res://Resources/Shop.json", File.READ)
	shop_data = parse_json(shop_file.get_as_text())
	shop_file.close()
	
	var upgrade_slot_buttons = load("res://Resources/Upgrades Button Group.tres")
	var status = upgrade_slot_buttons.connect("pressed", self, "populate_shop")
	assert(status == OK)

func populate_shop(button):
	clear_shop()
	
	remove_child(_unselected_message)
	
	var id = button.get_instance_id()
	var button_item = str(button.item_name)

	# Populate slot if it's empty
	if not (_slot_items.has(id) and _slot_items[id].has(button_item)):
		var filteredshop_data = shop_data[button.type].duplicate(true) # type
		for i in range(filteredshop_data.size()-1, -1, -1):
			if filteredshop_data[i]["level"] > _game_manager.level: # level
				filteredshop_data.remove(i)
			elif not filteredshop_data[i]["parent_items"].has(button.item_name):
				# upgrade validity
				# parent items is a list of items that can be used to purchase this item
				filteredshop_data.remove(i)

		# Shuffle and limit to 3 items
		filteredshop_data.shuffle()
		filteredshop_data.slice(0, 3)
		
		if not _slot_items.has(id):
			_slot_items[id] = {}
		_slot_items[id][button_item] = filteredshop_data
		
	# Populate
	if _slot_items[id][button_item].size() == 0:
		var no_upgrade_label = Label.new()
		no_upgrade_label.set_text("No upgrades available")
		no_upgrade_label.theme = load("res://Resources/Primary Theme.tres")
		add_child(no_upgrade_label)
	
	for item in _slot_items[id][button_item]:
		var shop_item_instance = SHOP_ITEM.instance()
		shop_item_instance.init(item)
		# disable items player can't afford
		if item.price > _player.get_snow():
			shop_item_instance.get_child(0).disabled = true
		add_child(shop_item_instance)

	# Remove item button
	get_node("../Header/Remove Item").visible = button.item_name != null

func clear_shop(clear_slot_data=false):
	for child in get_children():
		if child == _unselected_message:
			continue
		child.queue_free()
		
	if clear_slot_data:
		_slot_items = {}
	
	if _unselected_message.get_parent() == null:
		add_child(_unselected_message)
