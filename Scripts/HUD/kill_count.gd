extends Label
# Displays the player's kill count on a label


var _enemies_killed = 0


# Get and attach to data source
func _ready():
	var enemy_spawner := get_node("/root/Game/Enemies") as EnemySpawner
	var status = enemy_spawner.connect("enemy_killed", self, "_update_text")
	assert(status == OK)


# Update text
func _update_text():
	_enemies_killed += 1
	text = str(_enemies_killed)
