var _triggerUids = {}

func _init():
	startTime = Time.get_unix_time_from_system()

func getUID():
	# use random number
	var uid = randi()
	if _triggerUids.has(uid):
		return getUID()

func readTrigger(data, triggerId):
	# match possible triggers
	var splitTrigger = data.split('=')
	var triggerKey = splitTrigger[0]
	var triggerValue = splitTrigger[1] if splitTrigger.size() > 1 else null

	var shouldTrigger = false
	match triggerKey:
		"timestamp":
			shouldTrigger = _timestampReader(triggerValue)
		"enemyKilled":
			shouldTrigger = _enemyKilledReader(triggerId, triggerValue)

	if shouldTrigger:
		# free uid
		_triggerUids.erase(triggerId)

	return shouldTrigger

var startTime # this will be set by the enemy spawner every level
func _timestampReader(timestampString): # A trigger based on the time elapsed in a level
	var currentTime = Time.get_unix_time_from_system()
	var timeElapsed = currentTime - startTime
	var timestampDuration = Time.get_unix_time_from_datetime_string(timestampString)

	return timeElapsed >= timestampDuration

var _enemyKilledData = {}
func enemyKilled():
	# increment all triggers
	for triggerId in _enemyKilledData:
		_enemyKilledData[triggerId] += 1
func _enemyKilledReader(triggerId, targetKillCount):
	# get saved trigger data
	var enemiesKilled = _enemyKilledData.get(triggerId, null)

	# if no data, create a key for data
	if enemiesKilled == null:
		_enemyKilledData[triggerId] = 0
		return false

	# default value
	if targetKillCount == null:
		targetKillCount = 1

	var shouldTrigger = enemiesKilled >= targetKillCount

	if shouldTrigger:
		# cleanup
		_enemyKilledData.erase(triggerId)

	return shouldTrigger
