extends "res://Scripts/Center Ui.gd"

var TriggerReader # Borrow trigger reader from enemy spawning
onready var _instructionLabel = get_node("Instruction Label")
onready var _gameManager = get_node("/root/Game")
onready var _player = get_node("/root/Game/Player")

var _instructions
var _currentInstruction = 0
var _instructionUids = []
var _tutorialEnding = false

func _ready():
	if Globals.GameDataManager.GameData["Tutorial Completed"]:
		queue_free()
	
	# connections
	var status = get_node("Skip").connect("pressed", self, "_skipTutorial")
	assert(status == OK)

	# load the trigger reader
	TriggerReader = load("res://Scripts/Enemy Spawning/Trigger Reader.gd").new(_player)

	# read the tutorial file
	var file = File.new()
	file.open("res://Resources/Tutorial.json", File.READ)
	_instructions = parse_json(file.get_as_text())

func _process(_delta):
	centerScale()
	
	# read the instruction and display it
	var instruction = _instructions[_currentInstruction]
	_instructionLabel.text = instruction["label_text"]
	var posStringSplit = instruction["label_position"].split(",")
	_instructionLabel.rect_position = Vector2(posStringSplit[0], posStringSplit[1]) - _instructionLabel.rect_size / 2
	_instructionLabel.rect_size.x = int(instruction["label_width"])
	_instructionLabel.rect_size.y = 0 # auto size

	# check if the instruction is complete
	if _instructions[_currentInstruction].get("uid", null) == null:
		_instructions[_currentInstruction]["uid"] = TriggerReader.getUID()
	var complete
	# triggerreader based instructions
	if _instructions[_currentInstruction].has("trigger"):
		complete = TriggerReader.readTrigger(_instructions[_currentInstruction]["trigger"], _instructions[_currentInstruction]["uid"])
	else: # custom tutorial specific instructions
		complete = _checkCondition(_instructions[_currentInstruction]["condition"])
	if complete:
		print("Instruction complete")
		_currentInstruction += 1
		if _currentInstruction >= _instructions.size():
			_completeTutorial()

func activateTrigger(triggerName):
	match triggerName:
		"enemy_killed":
			TriggerReader.enemy_killed()
		"snow_collected":
			TriggerReader.snow_collected()

func _checkCondition(condition):
	var conditionValues = condition.split(";")
	match conditionValues[0]:
		"hud_explainer":
			var hud = get_node("../Gameplay HUD")
			var explainer = get_node_or_null("HUD Explainer") # initial hidden explainer
			if explainer != null:
				_player.isNonplayable = true
				# show the explainer
				remove_child(explainer)
				explainer.visible = true
				hud.add_child(explainer)
			explainer = hud.get_node_or_null("HUD Explainer") # explainer that is now visible
			var explainerClosed = explainer == null or explainer.is_queued_for_deletion() # check if the explainer is gone
			if explainerClosed:
				_player.isNonplayable = false
			return explainerClosed
		"health":
			var targetHealth = conditionValues[1].to_int()
			return _player.getHealth() >= targetHealth
		"slot":
			var targetItem = conditionValues[1]
			var targetCount = conditionValues[2].to_int()

			if conditionValues[3] == "lock":
				# disable continue button
				get_node("/root/Game/Daily Upgrade/ColorRect/VBoxContainer/Header/Continue").disabled = true

			var itemCount = 0
			for child in _player.get_children():
				if child.is_in_group("Body"):
					for item in child.get_children():
						var itemName = item.name
						if itemName.find("@") != -1:
							itemName = itemName.split("@")[1]
						if itemName == targetItem:
							itemCount += 1

			var conditionPassed = itemCount >= targetCount
			if conditionPassed:
				# enable continue button
				get_node("/root/Game/Daily Upgrade/ColorRect/VBoxContainer/Header/Continue").disabled = false
			return conditionPassed
		"close_shop":
			var shop = get_node_or_null("/root/Game/Daily Upgrade")
			return not shop.visible
		"end_tutorial":
			# change the skip button to a continue button
			get_node("Skip").text = "Continue"
			_tutorialEnding = true

func _completeTutorial():
	# ensure all tutorial ui locks are removed
	_player.isNonplayable = false
	get_node("/root/Game/Daily Upgrade/ColorRect/VBoxContainer/Header/Continue").disabled = false

	queue_free()
	Globals.GameDataManager.GameData["Tutorial Completed"] = true
	#Globals.GameDataManager.save()
	print("Tutorial complete")

func _skipTutorial():
	_completeTutorial()

	# reload the game without the tutorial if skipping
	if not _tutorialEnding:
		var status = get_tree().reload_current_scene()
		assert(status == OK)
