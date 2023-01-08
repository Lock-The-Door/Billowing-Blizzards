extends Node2D

const WORLD_LENGTH = preload("res://Scripts/Constants.gd").WORLD_LENGTH

onready var _player = get_node("/root/Game/Player")
onready var _collisionNode = get_node("Area2D")

var _projectileSpeed
var _projectileLifespan
var _projectileDamage
var _isEnemyProjectile

func init(angle, speed, lifespan, damage, isEnemyProjectile = false):
	_projectileSpeed = speed
	self.rotation = angle
	_projectileLifespan = lifespan
	_projectileDamage = damage
	_isEnemyProjectile = isEnemyProjectile

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# movement handled by child class

	# lifespan
	if (_projectileLifespan != -1):
		_projectileLifespan -= delta
		if _projectileLifespan <= 0:
			self.queue_free()
			return
	# check if within the world bounds
	var absPos = global_position.abs()
	if (absPos.x > WORLD_LENGTH or absPos.y > WORLD_LENGTH):
		self.queue_free()
		return
		
	# collision
	var colliding = _collisionNode.get_overlapping_areas()
	# traverse parents until we find a node containing the player/enemy group
	for area in colliding:
		var parent = area.get_parent()
		while parent != null:
			if parent.is_in_group("player") and _isEnemyProjectile:
				parent.damage(_projectileDamage)
				self.queue_free()
				return
			elif parent.is_in_group("enemy") and not _isEnemyProjectile:
				parent.damage(_projectileDamage)
				self.queue_free()
				return
			parent = parent.get_parent()
