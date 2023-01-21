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
	var health = player.get_health()
	_update_max_value(health)
	_update_value(health)


# Update value
func _update_value(new_health):
	value = new_health


func _update_max_value(new_max_health):
	max_value = new_max_health
