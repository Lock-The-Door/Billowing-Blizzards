extends Button

onready var _shopPopulator = get_node("/root/Game/Daily Upgrade/VBoxContainer/Body/Shop Background/Shop/Items")

export (String)var type
var item = null
var itemName = null
var itemBody
var itemLocation

const UBG = preload("res://Resources/UpgradesButtonGroup.tres")
func _ready():
	self.group = UBG

func setItem(newItem):
	item = newItem

	if item == null:
		itemName = null
		self.text = "+"
		self.icon = null
		return

	# fetch the icon
	var items = _shopPopulator.shopData[type]
	itemName = item.name
	# strip trailing numbers
	while itemName[-1].is_valid_integer():
		itemName = itemName.substr(0, itemName.length() - 1)
	# try to get the user defined name is available
	if "@" in itemName:
		itemName = itemName.split("@")[1]
	for i in items:
		if i.name == itemName:
			self.icon = load(i["image"])
			break

	self.text = ""
