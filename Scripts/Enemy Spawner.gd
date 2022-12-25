extends Node2D

const WORLD_LENGTH = preload("res://Scripts/Constants.gd").WORLD_LENGTH
var enemyTemplate = preload("res://Templates/Enemy.tscn")

var level = 0

func _ready():
	pass

var timePassed = 0

func _process(delta):
	# temporary way to increase level
	if Input.is_physical_key_pressed(KEY_SPACE):
		level += 1
		
	# temporary way to spawn enemies
	timePassed += delta

	if level != 0 and timePassed > 10/level:
		timePassed = 0
		spawnEnemy()

func spawnEnemy():
	var enemy = enemyTemplate.instance()
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
