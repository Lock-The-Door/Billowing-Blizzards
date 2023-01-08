extends Sprite

# enemy properties
export(int) var _health
export(int) var _speed
export(int) var _attackDamage
export(int) var _attackRange
export(int) var _attackSpeed
export(String) var _projectileName
export(int) var _projectileSpeed
export(int) var _projectileLifespan

# other stuff
onready var _player = get_node("/root/Game/Player")
var _attackTimer = 0
onready var _projectile = load("res://Templates/Projectiles/" + _projectileName + ".tscn")

func _process(delta):
	# get displacement from player
	var displacement = _player.position - get_parent().position
	
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
		get_parent().position += direction * _speed * delta
