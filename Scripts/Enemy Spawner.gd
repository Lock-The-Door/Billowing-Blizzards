extends Node2D

const WORLD_LENGTH = preload("res://Scripts/Constants.gd").WORLD_LENGTH
const MELEE_ENEMY = preload("res://Templates/Enemies/Test Enemy.tscn")
const RANGED_ENEMY = preload("res://Templates/Enemies/Test Ranged Enemy.tscn")

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
	# randomly choose an enemy type
	var enemyType = randi() % 2
	var enemy
	if enemyType == 0:
		enemy = MELEE_ENEMY.instance()
	else:
		enemy = RANGED_ENEMY.instance()
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
