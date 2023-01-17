extends Node2D

onready var spawner = get_node("Enemies")
onready var upgradeMenu = get_node("Daily Upgrade")

var level = 0

func _ready():
	randomize()
	spawner.connect("level_completed", self, "_levelCompleted")
	spawner.readLvlData(0)

func _levelCompleted():
	print("Level complete!")

	get_node("Player").isNonplayable = true
	
	upgradeMenu.visible = true

func nextLevel():
	level += 1
	spawner.readLvlData(level)
	get_node("Player").isNonplayable = false
