extends Button

onready var _shopPopulator = get_node("/root/Game/Daily Upgrade/VBoxContainer/Body/Shop/VBoxContainer/Items")

export (String)var type
var item = null
var itemName = null

const UBG = preload("res://Resources/UpgradesButtonGroup.tres")
func _ready():
	self.group = UBG

func setItem(newItem):
	item = newItem

	if item == null:
		self.text = "+"
		self.icon = null
		return

	# fetch the icon
	var items = _shopPopulator.shopData[type]
	itemName = item.name
	if "@" in itemName:
		itemName = itemName.split("@")[1]
	for i in items:
		if i.name == itemName:
			self.icon = load(i["image"])
			break

	self.text = ""
