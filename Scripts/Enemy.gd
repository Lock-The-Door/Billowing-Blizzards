extends Sprite

# enemy properties
export(int) var _health
export(int) var _speed
export(int) var _attackDamage
export(int) var _attackRange
export(int) var _attackSpeed

# other stuff
onready var _player = get_node("/root/Game/Player")
onready var _enemyRoot = get_node("/root/Game/Enemies")

func damage(damage):
	_health -= damage
	
	# dying
	if (_health <= 0):
		_enemyRoot.call_deferred("enemyKilledTrigger")
		self.queue_free()
