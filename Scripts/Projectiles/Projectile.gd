extends Node2D

const WORLD_LENGTH = preload("res://Scripts/Globals.gd").WORLD_LENGTH

onready var _player = get_node("/root/Game/Player")
onready var _collisionNode = get_node("Area2D")

var _projectileSpeed
var _projectileLifespan
var _projectileDamage
var _isEnemyProjectile

var _intendedGlobalPosition

func _ready():
	self.add_to_group("projectile")
	_intendedGlobalPosition = global_position

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
	# check if within the world bounds and offscreen
	var screenSize = get_viewport_rect().size / 2
	var absPos = global_position.abs()
	if absPos.x > WORLD_LENGTH + screenSize.x or absPos.y > WORLD_LENGTH + screenSize.y:
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
			elif parent.is_in_group("projectile"):
				# ignore collisions with other projectiles
				break
			parent = parent.get_parent()
