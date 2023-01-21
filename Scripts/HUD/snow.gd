extends Label
# Displays the player's snow on a label


# Get and attach to data source
func _ready():
	var player := get_node("/root/Game/Player") as Player
	var status = player.connect("snow_changed", self, "_update_text")
	assert(status == OK)


# Update text
func _update_text(new_snow):
	text = str(new_snow)
