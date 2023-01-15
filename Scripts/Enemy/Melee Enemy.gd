extends "res://Scripts/Enemy/Enemy.gd"

var _attackTimer = 0

func _process(delta):
	# get displacement from player
	var displacement = _player.position - self.position
	
	_attackTimer += delta
	# within attacking range?
	if displacement.length() < _attackRange:
		# try to damage the player
		if _attackTimer * _attackSpeed >= 1:
			_player.damage(_attackDamage)
			_attackTimer = 0
	else:
		# move closer to player
		var direction = displacement.normalized()
		position += direction * _speed * delta
