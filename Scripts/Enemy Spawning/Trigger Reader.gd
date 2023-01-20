var _player
var _triggerUids = []

func _init(player):
	startTime = Time.get_unix_time_from_system()
	_player = player

func getUID():
	# use random number
	var uid = randi()
	if _triggerUids.has(uid):
		return getUID()

	_triggerUids.append(uid)
	return uid

func readTrigger(data, triggerId):
	# match possible triggers
	var splitTrigger = data.split('=')
	var triggerKey = splitTrigger[0]
	var triggerValue = splitTrigger[1] if splitTrigger.size() > 1 else null

	var shouldTrigger = false
	match triggerKey:
		"timestamp":
			shouldTrigger = _timestampReader(triggerValue)
		"health":
			shouldTrigger = _healthReader(triggerValue)
		"enemy_killed":
			shouldTrigger = _enemyKilledReader(triggerId, triggerValue)
		"snow_collected":
			shouldTrigger = _snowCollectedReader(triggerId, triggerValue)

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

func _healthReader(targetHealth): # A trigger based on the player's health
	targetHealth = int(targetHealth)
	return _player.getHealth() >= targetHealth

var _enemyKilledData = {}
func enemy_killed():
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
	else:
		targetKillCount = int(targetKillCount)

	var shouldTrigger = enemiesKilled >= targetKillCount

	if shouldTrigger:
		# cleanup
		_enemyKilledData.erase(triggerId)

	return shouldTrigger

var _snowCollectedData = {}
func snow_collected():
	# increment all triggers
	for triggerId in _snowCollectedData:
		_snowCollectedData[triggerId] += 1
func _snowCollectedReader(triggerId, targetSnowCount):
	# get saved trigger data
	var snowCollected = _snowCollectedData.get(triggerId, null)

	# if no data, create a key for data
	if snowCollected == null:
		_snowCollectedData[triggerId] = 0
		return false

	# default value
	if targetSnowCount == null:
		targetSnowCount = 1
	else:
		targetSnowCount = int(targetSnowCount)

	var shouldTrigger = snowCollected >= targetSnowCount

	if shouldTrigger:
		# cleanup
		_snowCollectedData.erase(triggerId)

	return shouldTrigger