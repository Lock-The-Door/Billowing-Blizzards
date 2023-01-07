extends Node2D

onready var _player = get_node("/root/Game/Player")

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
	# move
	var rotation = Vector2(1, 0).rotated(self.rotation)
	self.position += rotation * delta * _projectileSpeed

	# lifespan
	_projectileLifespan -= delta
	if _projectileLifespan <= 0:
		self.queue_free()
		return

	# TODO collision
