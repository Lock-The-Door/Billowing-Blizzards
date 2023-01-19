extends Label

var _enemiesKilled = 0

# Get and attach to data source
func _ready():
	get_node("/root/Game/Enemies").connect("enemy_killed", self, "_updateText")
	
# Update text
func _updateText():
	_enemiesKilled += 1
	text = str(_enemiesKilled)
