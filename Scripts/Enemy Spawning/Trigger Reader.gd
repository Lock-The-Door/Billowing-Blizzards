func _init():
	startTime = Time.get_unix_time_from_system()

func readTrigger(data):
	# match possible triggers
	var splitTrigger = data.split('=')
	var triggerKey = splitTrigger[0]
	var triggerValue = splitTrigger[1]

	match triggerKey:
		"timestamp":
			return _timestampReader(triggerValue)

var startTime # this will be set by the enemy spawner every level
func _timestampReader(timestampString): # A trigger based on the time elapsed in a level
	var currentTime = Time.get_unix_time_from_system()
	var timeElapsed = currentTime - startTime
	var timestampDuration = Time.get_unix_time_from_datetime_string(timestampString)

	return timeElapsed >= timestampDuration
