extends Sprite

# enemy properties
export(int) var _health
export(int) var _speed
export(int) var _attackDamage
export(int) var _attackRange
export(int) var _attackSpeed

# other stuff
onready var _player = get_node("/root/Game/Player")

func damage(damage):
	_health -= damage
	
	# dying
	if (_health <= 0):
		self.queue_free()
