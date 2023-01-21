extends Label
# Updates the day number in the shop


onready var _game_manager := get_node("/root/Game") as GameManager


func _ready():
	var enemy_spawner := _game_manager.get_node("Enemies") as EnemySpawner
	var status = enemy_spawner.connect("level_completed", self, "_update_title")
	assert(status == OK)


func _update_title():
	self.text = "Night " + str(_game_manager.level)
