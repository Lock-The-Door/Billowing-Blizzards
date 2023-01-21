class_name TriggerReader
# Reads trigger strings and keeps track of trigger variables


var start_time # this will be set by the enemy spawner every level

var _player
var _trigger_uids = []

var _enemy_killed_data = {}
var _snow_collection_data = {}


func _init(player):
	start_time = Time.get_unix_time_from_system()
	_player = player


func get_uid():
	# use random number
	var uid = randi()
	if _trigger_uids.has(uid):
		return get_uid()

	_trigger_uids.append(uid)
	return uid


func read_trigger(data, trigger_id):
	# match possible triggers
	var split_trigger = data.split('=')
	var trigger_key = split_trigger[0]
	var trigger_value = split_trigger[1] if split_trigger.size() > 1 else null

	var should_trigger = false
	match trigger_key:
		"timestamp":
			should_trigger = _timestamp_reader(trigger_value)
		"health":
			should_trigger = _health_reader(trigger_value)
		"enemy_killed":
			should_trigger = _enemy_killed_reader(trigger_id, trigger_value)
		"snow_collected":
			should_trigger = _snow_collected_reader(trigger_id, trigger_value)

	if should_trigger:
		# free uid
		_trigger_uids.erase(trigger_id)

	return should_trigger


func enemy_killed():
	# increment all triggers
	for trigger_id in _enemy_killed_data:
		_enemy_killed_data[trigger_id] += 1


func snow_collected():
	# increment all triggers
	for trigger_id in _snow_collection_data:
		_snow_collection_data[trigger_id] += 1


func _timestamp_reader(timestamp_string): # A trigger based on the time elapsed in a level
	var currentTime = Time.get_unix_time_from_system()
	var timeElapsed = currentTime - start_time
	var timestampDuration = Time.get_unix_time_from_datetime_string(timestamp_string)

	return timeElapsed >= timestampDuration


func _health_reader(target_health): # A trigger based on the player's health
	target_health = int(target_health)
	return _player.get_health() >= target_health


func _enemy_killed_reader(trigger_id, target_kill_count):
	# get saved trigger data
	var enemies_killed = _enemy_killed_data.get(trigger_id, null)

	# if no data, create a key for data
	if enemies_killed == null:
		_enemy_killed_data[trigger_id] = 0
		return false

	# default value
	if target_kill_count == null:
		target_kill_count = 1
	else:
		target_kill_count = int(target_kill_count)

	var should_trigger = enemies_killed >= target_kill_count

	if should_trigger:
		# cleanup
		_enemy_killed_data.erase(trigger_id)

	return should_trigger


func _snow_collected_reader(trigger_id, target_snow_count):
	# get saved trigger data
	var snow_collected = _snow_collection_data.get(trigger_id, null)

	# if no data, create a key for data
	if snow_collected == null:
		_snow_collection_data[trigger_id] = 0
		return false

	# default value
	if target_snow_count == null:
		target_snow_count = 1
	else:
		target_snow_count = int(target_snow_count)

	var should_trigger = snow_collected >= target_snow_count

	if should_trigger:
		# cleanup
		_snow_collection_data.erase(trigger_id)

	return should_trigger
