extends ProgressBar

# Get and attach to data source
func _ready():
	var player = get_node("/root/Game/Player")
	player.connect("max_health_changed", self, "_updateMaxValue")
	player.connect("health_changed", self, "_updateValue")
	
	# fetch inital values since signals won't be recieved on ready
	var health = player.getHealth()
	_updateMaxValue(health)
	_updateValue(health)
	
# Update value
func _updateValue(newHealth):
	value = newHealth
func _updateMaxValue(newMaxHealth):
	max_value = newMaxHealth
