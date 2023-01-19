extends Sprite

const DEATH_PARTICLES = preload("res://Templates/Death Particles.tscn")

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
		_enemyRoot.call_deferred("activateTrigger", "enemy_killed")
		var dpInstance = DEATH_PARTICLES.instance()
		dpInstance.global_position = global_position
		get_node("/root/Game/Particles").add_child(dpInstance)
		self.queue_free()
