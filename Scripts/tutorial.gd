class_name Tutorial
extends CenterUi
# A script that manages the entire tutorial


var trigger_reader # Borrow trigger reader from enemy spawning

var _instructions
var _current_instruction = 0
var _tutorial_ending = false

onready var _intruction_label := get_node("Instruction Label") as Label
onready var _player := get_node("/root/Game/Player") as Player


func _ready():
	if Globals.GameDataManager.game_data["Tutorial Completed"]:
		queue_free()
	else:
		self.visible = true
	
	# connections
	var status = get_node("Skip").connect("pressed", self, "_skip_tutorial")
	assert(status == OK)

	# load the trigger reader
	trigger_reader = load("res://Scripts/Enemy Spawning/trigger_reader.gd")\
			.new(_player) as TriggerReader

	# read the tutorial file
	var file = File.new()
	file.open("res://Resources/Tutorial.json", File.READ)
	_instructions = parse_json(file.get_as_text())
	file.close()


func _process(_delta):
	center_scale()
	
	# read the instruction and display it
	var instruction = _instructions[_current_instruction]
	_intruction_label.text = instruction["label_text"]
	var pos_string_split = instruction["label_position"].split(",")
	_intruction_label.rect_position = Vector2(pos_string_split[0], pos_string_split[1]) - _intruction_label.rect_size / 2
	_intruction_label.rect_size.x = int(instruction["label_width"])
	_intruction_label.rect_size.y = 0 # auto size

	# check if the instruction is complete
	if _instructions[_current_instruction].get("uid", null) == null:
		_instructions[_current_instruction]["uid"] = trigger_reader.get_uid()
	var complete
	# trigger_reader based instructions
	if _instructions[_current_instruction].has("trigger"):
		complete = trigger_reader.read_trigger(_instructions[_current_instruction]["trigger"], _instructions[_current_instruction]["uid"])
	else: # custom tutorial specific instructions
		complete = _check_condition(_instructions[_current_instruction]["condition"])
	if complete:
		print("Instruction complete")
		_current_instruction += 1
		if _current_instruction >= _instructions.size():
			_complete_tutorial()


func _check_condition(condition):
	var condition_values = condition.split(";")
	match condition_values[0]:
		"hud_explainer":
			var hud = get_node("../Gameplay HUD")
			var explainer = get_node_or_null("HUD Explainer") # initial hidden explainer
			if explainer != null:
				_player.is_nonplayable = true
				# show the explainer
				remove_child(explainer)
				explainer.visible = true
				hud.add_child(explainer)
			explainer = hud.get_node_or_null("HUD Explainer") # explainer that is now visible
			# check if the explainer is gone
			var explainer_closed = explainer == null or explainer.is_queued_for_deletion()
			if explainer_closed:
				_player.is_nonplayable = false
			return explainer_closed
		"health":
			var target_health = condition_values[1].to_int()
			return _player.get_health() >= target_health
		"slot":
			var target_item = condition_values[1]
			var target_count = condition_values[2].to_int()

			if condition_values[3] == "lock":
				# disable continue button
				get_node("/root/GameDaily Upgrade/ColorRect/VBoxContainer/Header/Continue")\
						.disabled = true

			var item_count = 0
			for child in _player.get_children():
				if child.is_in_group("Body"):
					for item in child.get_children():
						var item_name = item.name
						if item_name.find("@") != -1:
							item_name = item_name.split("@")[1]
						if item_name == target_item:
							item_count += 1

			var condition_passed = item_count >= target_count
			if condition_passed:
				# enable continue button
				get_node("/root/GameDaily Upgrade/ColorRect/VBoxContainer/Header/Continue")\
						.disabled = false
			return condition_passed
		"close_shop":
			var shop = get_node_or_null("/root/GameDaily Upgrade")
			return not shop.visible
		"end_tutorial":
			# change the skip button to a continue button
			get_node("Skip").text = "Continue"
			_tutorial_ending = true


func _complete_tutorial():
	# ensure all tutorial ui locks are removed
	_player.is_nonplayable = false
	get_node("/root/GameDaily Upgrade/ColorRect/VBoxContainer/Header/Continue")\
			.disabled = false

	queue_free()
	Globals.GameDataManager.game_data["Tutorial Completed"] = true
	Globals.GameDataManager.save()
	print("Tutorial complete")


func _skip_tutorial():
	_complete_tutorial()

	# reload the game without the tutorial if skipping
	if not _tutorial_ending:
		var status = get_tree().reload_current_scene()
		assert(status == OK)


func activate_trigger(triggerName):
	match triggerName:
		"enemy_killed":
			trigger_reader.enemy_killed()
		"snow_collected":
			trigger_reader.snow_collected()
