extends Button
# Closes the shop and tells the game manager to load the next level


onready var _game_manager := get_node("/root/Game") as GameManager
onready var _upgrade_menu := get_node("/root/Game/UI/Daily Upgrade") as Control


func _pressed():
	_upgrade_menu.visible = false
	
	_game_manager.next_level()
