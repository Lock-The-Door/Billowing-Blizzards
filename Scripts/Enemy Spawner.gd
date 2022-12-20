extends Node2D

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

	if timePassed > 1:
		timePassed = 0
		spawnEnemy()

func spawnEnemy():
	var enemy = enemyTemplate.instance()
	get_node("/root/Game/Enemies").add_child(enemy)
	enemy.position = Vector2(500, 500)
