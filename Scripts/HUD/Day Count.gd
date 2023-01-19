extends Label

onready var _gameManager = get_node("/root/Game")

# Get and attach to data source
func _ready():
	get_node("/root/Game/Enemies").connect("level_completed", self, "_updateText")
	if not Globals.GameDataManager.GameData["Tutorial Completed"]:
		_updateText()
	
# Update text
func _updateText():
	text = str(_gameManager.level)
