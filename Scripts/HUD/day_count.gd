extends Label
# Displays the day count on a label


onready var _game_manager := get_node("/root/Game") as GameManager


# Get and attach to data source
func _ready():
	var enemy_spawner = get_node("/root/Game/Enemies") as EnemySpawner
	var status = enemy_spawner.connect("level_completed", self, "_update_text")
	assert(status == OK)
	
	# The initial text is set to 1, update it to 0 if on tutorial
	if not Globals.GameDataManager.game_data["Tutorial Completed"]:
		_update_text()


# Update text
func _update_text():
	text = str(_game_manager.level)
