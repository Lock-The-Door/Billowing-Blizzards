extends Sprite

# enemy properties
export(int) var _health
export(int) var _speed
export(int) var _attackDamage
export(int) var _attackRange
export(int) var _attackSpeed

# other stuff
onready var _player = get_node("/root/Game/Player")
var _attackTimer = 0

func _process(delta):
	# get displacement from player
	var displacement = _player.position - get_parent().position
	
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
		get_parent().position += direction * _speed * delta
