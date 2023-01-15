extends Label

onready var _gameManager = get_node("root/Game")

func _ready():
	_gameManager.get_node("Enemies").connect("level_completed", self, "_updateTitle")
	
func _updateTitle():
		self.text = "Night " + _gameManager.level
