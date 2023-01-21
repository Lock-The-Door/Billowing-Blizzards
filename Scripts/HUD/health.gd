extends ProgressBar
# Displays the health on a progress bar


# Get and attach to data source
func _ready():
	var player := get_node("/root/Game/Player") as Player
	var status = player.connect("max_health_changed", self, "_update_max_value")
	assert(status == OK)
	status = player.connect("health_changed", self, "_update_value")
	assert(status == OK)
	
	# fetch inital values since signals won't be recieved on ready
	var health = player.getHealth()
	_update_max_value(health)
	_update_value(health)


# Update value
func _update_value(newHealth):
	value = newHealth


func _update_max_value(newMaxHealth):
	max_value = newMaxHealth
