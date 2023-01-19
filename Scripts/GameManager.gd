extends Node2D

onready var spawner = get_node("Enemies")
onready var upgradeMenu = get_node("Daily Upgrade")

var level = 0
export (int)var _levelCount

func _ready():
	randomize()
	spawner.connect("level_completed", self, "_levelCompleted")
	spawner.readLvlData("test")

func _levelCompleted():
	print("Level complete!")

	get_node("Player").isNonplayable = true
	
	upgradeMenu.visible = true

func nextLevel():
	level += 1

	if level >= _levelCount:
		print("Game complete!")
		return
	
	var success = spawner.readLvlData(level)
	get_node("Player").isNonplayable = false

	if not success:
		print("Level data corrupted or not found!")
