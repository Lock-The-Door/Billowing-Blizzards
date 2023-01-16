extends HBoxContainer

onready var _gameManager = get_node("/root/Game")
const SHOP_ITEM = preload("res://Templates/Upgrades/Shop Item.tscn")

var _shopData
var _slotItems = {}

func _ready():
	# Read the shop data
	var shopFile = File.new()
	shopFile.open("res://Resources/Shop.json", File.READ)
	_shopData = parse_json(shopFile.get_as_text())
	shopFile.close()
	
	var upgradeSlotButtons = load("res://Resources/UpgradesButtonGroup.tres")
	upgradeSlotButtons.connect("pressed", self, "_onUpgradeSlotButtonPressed")

func _onUpgradeSlotButtonPressed(button):
	var id = button.get_instance_id()
	var buttonItem = str(button.item)
	
	# Clear shop
	for child in get_children():
		child.queue_free()

	# Populate slot if it's empty
	if not (_slotItems.has(id) and _slotItems[id].has(button.type)):
		var filteredShopData = _shopData[button.type].duplicate(true) # type
		for i in range(filteredShopData.size() - 1, 0, -1):
			if filteredShopData[i]["level"] > _gameManager.level: # level
				filteredShopData.remove(i)

		# Shuffle and limit to 3 items
		filteredShopData.shuffle()
		filteredShopData.slice(0, 3)
		
		if not _slotItems.has(id):
			_slotItems[id] = {}
		_slotItems[id][buttonItem] = filteredShopData
		
	# Populate
	for item in _slotItems[id][buttonItem]:
		var shopItemInstance = SHOP_ITEM.instance()
		shopItemInstance.init(item)
		add_child(shopItemInstance)
