extends HBoxContainer

onready var _gameManager = get_node("/root/Game")
onready var _player = get_node("/root/Game/Player")
const SHOP_ITEM = preload("res://Templates/Upgrades/Shop Item.tscn")
onready var _unselectedMessage = get_node("Unselected Message")

var shopData
var _slotItems = {}

func _ready():
	# Read the shop data
	var shopFile = File.new()
	shopFile.open("res://Resources/Shop.json", File.READ)
	shopData = parse_json(shopFile.get_as_text())
	shopFile.close()
	
	var upgradeSlotButtons = load("res://Resources/UpgradesButtonGroup.tres")
	upgradeSlotButtons.connect("pressed", self, "populateShop")

func populateShop(button):
	clearShop()
	
	remove_child(_unselectedMessage)
	
	var id = button.get_instance_id()
	var buttonItem = str(button.itemName)

	# Populate slot if it's empty
	if not (_slotItems.has(id) and _slotItems[id].has(buttonItem)):
		var filteredShopData = shopData[button.type].duplicate(true) # type
		for i in range(filteredShopData.size()-1, -1, -1):
			if filteredShopData[i]["level"] > _gameManager.level: # level
				filteredShopData.remove(i)
			elif not filteredShopData[i]["parent_items"].has(button.itemName): # upgrade validity (parent items is a list of items that can be used to purchase this item)
				filteredShopData.remove(i)

		# Shuffle and limit to 3 items
		filteredShopData.shuffle()
		filteredShopData.slice(0, 3)
		
		if not _slotItems.has(id):
			_slotItems[id] = {}
		_slotItems[id][buttonItem] = filteredShopData
		
	# Populate
	if _slotItems[id][buttonItem].size() == 0:
		var noUpgradeLabel = Label.new()
		noUpgradeLabel.set_text("No upgrades available")
		noUpgradeLabel.theme = load("res://Resources/ShopButtonTheme.tres")
		add_child(noUpgradeLabel)
	
	for item in _slotItems[id][buttonItem]:
		var shopItemInstance = SHOP_ITEM.instance()
		shopItemInstance.init(item)
		# disable items player can't afford
		if item.price > _player.getSnow():
			shopItemInstance.get_child(0).disabled = true
		add_child(shopItemInstance)

	# Remove item button
	get_node("../Header/Remove Item").visible = button.itemName != null

func clearShop(clearSlotData=false):
	for child in get_children():
		if child == _unselectedMessage:
			continue
		child.queue_free()
		
	if clearSlotData:
		_slotItems = {}
	
	if _unselectedMessage.get_parent() == null:
		add_child(_unselectedMessage)