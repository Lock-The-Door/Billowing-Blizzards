extends "res://Scripts/Enemy/Enemy.gd"

export(String) var _projectileName
export(int) var _projectileSpeed
export(int) var _projectileLifespan

onready var _projectile = load("res://Templates/Projectiles/" + _projectileName + ".tscn")

var _attackTimer = 0

func _process(delta):
	# get displacement from player
	var displacement = _player.position - self.position
	
	_attackTimer += delta
	# within attacking range?
	if displacement.length() < _attackRange:
		# fire at player
		if _attackTimer * _attackSpeed >= 1:
			var projectileInstance = _projectile.instance()
			var angle = atan2(displacement.y, displacement.x)
			projectileInstance.init(angle, _projectileSpeed, _projectileLifespan, _attackDamage, true)
			self.add_child(projectileInstance)
			_attackTimer = 0
	else:
		# move closer to player
		var direction = displacement.normalized()
		self.position += direction * _speed * delta
