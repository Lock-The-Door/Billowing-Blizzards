extends Node2D

const TRIGGER_READER = preload("./Trigger Reader.gd")
var TriggerReader

const WORLD_LENGTH = preload("res://Scripts/Constants.gd").WORLD_LENGTH

onready var commentRegex = RegEx.new()
onready var typeRegex = RegEx.new()

var _enemyTypes = {} # loaded enemy types go here

var _currentLevel = 0
var _enemyData = []

func _ready():
	commentRegex.compile("\\/\\/.*|\\/\\*[\\s\\S]*?\\*\\/")
	typeRegex.compile("\"type\": ?\"([\\s\\S]+?)\"")

	readLvlData("test")

# read the level data file, apply the headers and save the enemy data to the list
func readLvlData(lvl):
	var file = File.new()
	file.open("res://Resources/Level Data/" + lvl + ".bbld", File.READ)
	var fileText = file.get_as_text()
	file.close()
	# use regex to remove comments
	fileText = commentRegex.sub(fileText, "", true)
	var levelData = parse_json(fileText)

	# TODO: apply or use header data

	# Create a new instance of dependencies
	TriggerReader = TRIGGER_READER.new()

	_enemyData = levelData["enemies"]

	# Load required enemy templates
	var typeList = typeRegex.search_all(fileText)
	for type in typeList:
		type = type.strings[1]
		_enemyTypes[type] = load("res://Templates/Enemies/{0}.tscn".format([type]))

func _process(_delta):
	# check for an instruction in the level data queue and attempt to read it
	var successIndex = _readInstruction(0)

	# this way of handling spawning will limit us to one trigger per frame/update
	if successIndex != -1:
		_enemyData.remove(successIndex) # potential optimisation by removing last element first

func _readInstruction(index):
	if (index >= _enemyData.size() or TriggerReader == null):
		return -1 # missing data
	var nextInstruction = _enemyData[index]
	
	# read the trigger and see if the trigger has been met, handoff the trigger value reader to an appropriate function
	var isTriggered = TriggerReader.readTrigger(nextInstruction["trigger"])
	
	if isTriggered:
		# condition met, read the enemy data and spawn
		var enemyGroups = nextInstruction["data"]
		for enemyGroup in enemyGroups:
			_spawnEnemies(enemyGroup)
		return index

	# check if this spawn group should be run asynchronously (read ahead)
	if nextInstruction.get("async", false):
		return _readInstruction(index+1)

	# failed
	return -1

const EDGE_INTS = {
	"top": 0,
	"right": 1,
	"bottom": 2,
	"left": 3,
	"center": 4
}
func _spawnEnemies(enemyGroup):
	# this is the template that will be instantiated
	var enemyTemplate = _enemyTypes[enemyGroup["type"]]

	# find a spawn position
	var enemySpawn = enemyGroup["location"]
	# there are two ways to specify this, a direct vector world;0,0 or an edge world-random
	# try to parse a vector
	var spawnPos
	if enemySpawn.find(";") != -1:
		enemySpawn = enemySpawn.split(";")
		var axis = enemySpawn[1].split(",")
		spawnPos = Vector2(axis[0], axis[1])

		if enemySpawn[0] == "screen":
			# TODO: convert to world coordinates
			spawnPos += get_node("/root/Game/Camera2D").get_camera_position()
	else:
		enemySpawn = enemySpawn.split("-")

		# parse the edge
		var edgeString = enemySpawn[1]
		var edge = EDGE_INTS[edgeString]
		if edge == null: # random edge
			edge = randi() % 4

		var minXPos
		var maxXPos
		var minYPos
		var maxYPos
		if edgeString[0] == "world":
			var lengthFromCenter = WORLD_LENGTH/2.0
			minXPos = -lengthFromCenter
			minYPos = -lengthFromCenter
			maxXPos = lengthFromCenter
			maxYPos = lengthFromCenter
		else:
			# find the min to max values for the screen
			var lengthsFromCenter = get_viewport().size / 2
			var currentCameraPos = get_node("/root/Game/Camera2D").get_camera_position()
			minXPos = currentCameraPos.x - lengthsFromCenter.x
			minYPos = currentCameraPos.y - lengthsFromCenter.y
			maxXPos = currentCameraPos.x + lengthsFromCenter.x
			maxYPos = currentCameraPos.y + lengthsFromCenter.y
		
		match edge:
			0: # top
				spawnPos = Vector2(rand_range(minXPos, maxXPos), minYPos)
			1: # right
				spawnPos = Vector2(maxXPos, rand_range(minYPos, maxYPos))
			2: # bottom
				spawnPos = Vector2(rand_range(minXPos, maxXPos), maxYPos)
			3: # left
				spawnPos = Vector2(minXPos, rand_range(minYPos, maxYPos))
			4: # center
				spawnPos = Vector2((minXPos + maxXPos)/2, (minYPos + maxYPos)/2)

	# TODO: calculate radial positioning

	# TODO: targeting

	# TODO: overrides

	for _i in enemyGroup["count"]:
		var enemyInstance = enemyTemplate.instance()
		self.add_child(enemyInstance)
		enemyInstance.add_to_group("enemies")
		enemyInstance.set_position(spawnPos)