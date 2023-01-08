extends Node2D

const WORLD_LENGTH = preload("res://Scripts/Constants.gd").WORLD_LENGTH
var enemyTemplate = preload("res://Templates/Enemy.tscn")

func _ready():
	pass

var timePassed = 0

func _process(delta):
	# temporary way to spawn enemies
	timePassed += delta

	if timePassed > 10:
		timePassed = 0
		spawnEnemy()

func spawnEnemy():
	var enemy = enemyTemplate.instance()
	enemy.init("Test Ranged Enemy")
	get_node("/root/Game/Enemies").add_child(enemy)
	# Select a random edge to spawn the enemy on
	var edge = randi() % 4
	# Select a random position on that edge
	var pos = randi() % WORLD_LENGTH - WORLD_LENGTH/2.0

	if edge == 0:
		enemy.position = Vector2(pos, -WORLD_LENGTH)
	elif edge == 1:
		enemy.position = Vector2(WORLD_LENGTH, pos)
	elif edge == 2:
		enemy.position = Vector2(pos, WORLD_LENGTH)
	elif edge == 3:
		enemy.position = Vector2(-WORLD_LENGTH, pos)
