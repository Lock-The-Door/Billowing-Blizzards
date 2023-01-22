class_name UpgradeSlot
extends Button
# Manages the upgrade slot image and stores other metadata
# The slot will contain data like which body and position this slot represents


const UBG = preload("res://Resources/Upgrades Button Group.tres")

export (String)var type
var item = null
var item_name = null
var item_body
var item_location

onready var _shop_populator := get_node("/root/Game/%Items") as ShopPopulator

func _ready():
	self.group = UBG

func set_item(new_item):
	item = new_item

	if item == null:
		item_name = null
		self.text = "+"
		self.icon = null
		return

	# fetch the icon
	var items = _shop_populator.shop_data[type]
	item_name = item.name
	# strip trailing numbers
	while item_name[-1].is_valid_integer():
		item_name = item_name.substr(0, item_name.length() - 1)
	# try to get the user defined name is available
	if "@" in item_name:
		item_name = item_name.split("@")[1]
	for i in items:
		if i.name == item_name:
			self.icon = load(i["image"])
			break
	
	self.text = ""
