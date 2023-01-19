extends "res://Scripts/Center Ui.gd"

var TriggerReader # Borrow trigger reader from enemy spawning
onready var _instructionLabel = get_node("Instruction Label")

var _instructions
var _currentInstruction = 0
var _instructionUids = []

func _ready():
	if Globals.GameDataManager.GameData["Tutorial Completed"]:
		queue_free()
	
	# connections
	var status = get_node("Skip").connect("pressed", self, "_skipTutorial")
	assert(status == OK)

	# load the trigger reader
	TriggerReader = load("res://Scripts/Enemy Spawning/Trigger Reader.gd").new()

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

	# check if the instruction is complete
	if _instructions[_currentInstruction].get("uid", null) == null:
		_instructions[_currentInstruction]["uid"] = TriggerReader.getUID()
	var complete 
	# triggerreader based instructions
	if _instructions[_currentInstruction].has("trigger"):
		complete = TriggerReader.readTrigger(_instructions[_currentInstruction]["trigger"], _instructions[_currentInstruction]["uid"])
	else: # custom tutorial specific instructions
		complete = false
		pass
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


func _completeTutorial():
	queue_free()
	Globals.GameDataManager.GameData["Tutorial Completed"] = true
	#Globals.GameDataManager.save()
func _skipTutorial():
	_completeTutorial()

	# reload the game without the tutorial
	var status = get_tree().reload_current_scene()
	assert(status == OK)
