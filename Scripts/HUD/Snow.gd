extends Label

# Get and attach to data source
func _ready():
	get_node("/root/Game/Player").connect("snow_changed", self, "_updateText")
	
# Update text
func _updateText(newSnow):
	text = str(newSnow)
