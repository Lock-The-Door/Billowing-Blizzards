class_name EnemySpawner
extends Node2D
# Manages the setup and spawning of enemies
# Reads level data files, setup everything according to the headers, 
# and spawn enemies when triggered


signal level_completed
signal enemy_killed

const TriggerReader = preload("./trigger_reader.gd")
const WORLD_LENGTH = preload("res://Scripts/globals.gd").WORLD_LENGTH

var trigger_reader

var _is_idle = true
var _enemy_types = {} # loaded enemy types go here
var _bonus_reward_data = ""
var _enemy_data = []

onready var _player := get_node("/root/Game/Player") as Player

onready var _comment_regex = RegEx.new()
onready var _type_regex = RegEx.new()


func _ready():
	# Compile regexs
	_comment_regex.compile("\\/\\/.*|\\/\\*[\\s\\S]*?\\*\\/")
	_type_regex.compile("\"type\": ?\"([\\s\\S]+?)\"")


# read the level data file, apply the headers and save the enemy data to the list
func read_lvl_data(lvl):
	_is_idle = false

	var file = File.new()
	var file_path = "res://Resources/Level Data/" + str(lvl) + ".bbld"
	if Directory.new().file_exists(file_path):
		var status = file.open("res://Resources/Level Data/" + str(lvl) + ".bbld", File.READ)
		assert(status == OK)
	else:
		# No level data found, try to load the newest dynamic level
		var level_found = false
		var dynamic_lvl = lvl
		while not level_found:
			file_path = "res://Resources/Level Data/" + str(dynamic_lvl) + ".bbid"
			if Directory.new().file_exists(file_path):
				var status = file.open(file_path, File.READ)
				assert(status == OK)
				level_found = true
			else:
				dynamic_lvl -= 1

			assert(lvl > 0, "No static nor dynamic level data found for level: " + str(lvl)) # no level data found
	
	var file_text = file.get_as_text()
	# use regex to remove comments
	file_text = _comment_regex.sub(file_text, "", true)
	var level_data = parse_json(file_text)

	# compile if necessary
	if file.get_path().ends_with(".bbid"):
		level_data = InfiniteDataCompiler.new(lvl).compile(level_data)
		
	
	file.close()

	# TODO: apply or use header data
	_bonus_reward_data = level_data["header"].get("bonus", null)

	# Create a new instance of dependencies
	trigger_reader = TriggerReader.new(_player)

	_enemy_data = level_data["enemies"]

	# Load required enemy templates
	var typeList = _type_regex.search_all(file_text)
	for type in typeList:
		type = type.strings[1]
		_enemy_types[type] = load("res://Templates/Enemies/{0}.tscn".format([type]))


func _process(_delta):
	# check for an instruction in the level data queue and attempt to read it
	var success_index = _read_instruction(0)

	# this way of handling spawning will limit us to one trigger per frame/update
	if success_index != -1:
		_enemy_data.remove(success_index) # potential optimisation by removing last element first

	# check for level completion
	if _enemy_data.size() == 0 and self.get_child_count() == 0 and not _is_idle:
		_is_idle = true
		# give the bonus stuff
		if _bonus_reward_data != null:
			_reward_player(_bonus_reward_data)
		emit_signal("level_completed")


func _reward_player(bonus_string):
	for bonus in bonus_string.split(";"):
		var bonus_data = bonus.split("=")
		var bonus_type = bonus_data[0]
		var bonus_value = int(bonus_data[1])

		match bonus_type:
			"health":
				_player.add_health(bonus_value)
			"snow":
				_player.add_snow(bonus_value)


func _read_instruction(index):
	if (index >= _enemy_data.size() or trigger_reader == null):
		return -1 # missing data
	var next_instruction = _enemy_data[index]

	# assign or fetch a uid for this instruction
	if next_instruction.get("uid", null) == null:
		next_instruction["uid"] = trigger_reader.get_uid()
	
	# read the trigger and see if the trigger has been met, handoff the trigger value reader to an appropriate function
	var is_triggered = trigger_reader.read_trigger(next_instruction["trigger"], next_instruction["uid"])
	
	if is_triggered:
		# condition met, read the enemy data and spawn
		var enemy_groups = next_instruction["data"]
		for enemy_group in enemy_groups:
			_spawn_enemies(enemy_group)
		return index

	# check if this spawn group should be run asynchronously (read ahead)
	if next_instruction.get("async", false):
		return _read_instruction(index+1)

	# failed
	return -1


const EDGE_INTS = {
	"top": 0,
	"right": 1,
	"bottom": 2,
	"left": 3,
	"center": 4
}
func _spawn_enemies(enemy_group):
	# this is the template that will be instantiated
	var enemy_template = _enemy_types[enemy_group["type"]]

	# find a spawn position
	var enemy_spawn = enemy_group["location"]
	# there are two ways to specify this, a direct vector world;0,0 or an edge world-random
	# try to parse a vector
	var spawn_pos
	if enemy_spawn.find(";") != -1:
		enemy_spawn = enemy_spawn.split(";")
		var axis = enemy_spawn[1].split(",")
		spawn_pos = Vector2(axis[0], axis[1])

		if enemy_spawn[0] == "screen":
			# TODO: convert to world coordinates
			spawn_pos += get_node("/root/Game/Camera2D").get_camera_position()
	else:
		enemy_spawn = enemy_spawn.split("-")

		# parse the edge
		var edge_string = enemy_spawn[1]
		var edge = EDGE_INTS.get(edge_string, randi() % 4)

		var min_x_pos
		var max_x_pos
		var min_y_pos
		var max_y_pos
		if edge_string[0] == "world":
			var length_from_center = WORLD_LENGTH/2.0
			min_x_pos = -length_from_center
			min_y_pos = -length_from_center
			max_x_pos = length_from_center
			max_y_pos = length_from_center
		else:
			# find the min to max values for the screen
			var lengths_from_center = get_viewport().size / 2
			var current_camera_pos = get_node("/root/Game/Camera2D").get_camera_position()
			min_x_pos = current_camera_pos.x - lengths_from_center.x
			min_y_pos = current_camera_pos.y - lengths_from_center.y
			max_x_pos = current_camera_pos.x + lengths_from_center.x
			max_y_pos = current_camera_pos.y + lengths_from_center.y
		
		match edge:
			0: # top
				spawn_pos = Vector2(rand_range(min_x_pos, max_x_pos), min_y_pos)
			1: # right
				spawn_pos = Vector2(max_x_pos, rand_range(min_y_pos, max_y_pos))
			2: # bottom
				spawn_pos = Vector2(rand_range(min_x_pos, max_x_pos), max_y_pos)
			3: # left
				spawn_pos = Vector2(min_x_pos, rand_range(min_y_pos, max_y_pos))
			4: # center
				spawn_pos = Vector2((min_x_pos + max_x_pos)/2, (min_y_pos + max_y_pos)/2)

	var enemy_count = int(enemy_group["count"])

	# calculate radial positioning
	var seperation_angle = deg2rad(360 / enemy_count)
	var seperation_radius = enemy_group.get("radius", null)
	if seperation_radius == null:
		seperation_radius = (enemy_count - 1) * 100 # default to (count-1) * 100
	var spawn_positions = []
	for i in enemy_count:
		var angle = i * seperation_angle
		var x = spawn_pos.x + seperation_radius * cos(angle)
		var y = spawn_pos.y + seperation_radius * sin(angle)
		spawn_positions.append(Vector2(x, y))

	# TODO: targeting

	# TODO: overrides

	for i in enemy_count:
		var enemy_instance = enemy_template.instance()
		enemy_instance.add_to_group("enemy")
		enemy_instance.set_position(spawn_positions[i])
		add_child(enemy_instance)


# Recieve trigger calls and pass them to the trigger reader
# Also activate signals for other trigger observers like HUD elements
func activate_trigger(trigger_name):
	if has_signal(trigger_name):
		emit_signal(trigger_name)

	# pass to tutorial trigger reader if necessary
	if not Globals.GameDataManager.game_data["Tutorial Completed"]:
		get_node("/root/Game/Tutorial").activate_trigger(trigger_name)
	
	if trigger_reader == null:
		return

	match trigger_name:
		"enemy_killed":
			trigger_reader.enemy_killed()
		"snow_collected":
			trigger_reader.snow_collected()
