extends Button

onready var _gameManager = get_node("/root/Game")
onready var _upgradeMenu = get_node("/root/Game/Daily Upgrade")

func _pressed():
	_upgradeMenu.visible = false
	
	_gameManager.nextLevel()
