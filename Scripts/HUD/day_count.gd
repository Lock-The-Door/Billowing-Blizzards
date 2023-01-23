extends Label
# Displays the day count on a label


onready var _game_manager := get_node("/root/Game") as GameManager


# Get and attach to data source
func _ready():
	var status = _game_manager.connect("level_started", self, "_update_text")
	assert(status == OK)
	
	# The initial text is set to 1, update it to 0 if on tutorial
	if not Globals.GameDataManager.game_data["Tutorial Completed"]:
		_update_text(0)


# Update text
func _update_text(new_level):
	text = str(new_level)
