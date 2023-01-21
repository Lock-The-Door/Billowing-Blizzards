extends Enemy
# Logic for ranged enemies


export(String) var _projectile_name
export(int) var _projectile_speed
export(int) var _projectile_lifespan

onready var _projectile = load("res://Templates/Projectiles/" + _projectile_name + ".tscn")

var _attack_timer = 0


func _process(delta):
	# get displacement from player
	var displacement = _player.position - self.position
	
	_attack_timer += delta
	# within attacking range?
	if displacement.length() < _attack_range:
		# fire at player
		if _attack_timer * _attack_speed >= 1:
			var projectile_instance = _projectile.instance()
			var angle = atan2(displacement.y, displacement.x)
			projectile_instance.init(angle, _projectile_speed, _projectile_lifespan, _attack_damage, true)
			add_child(projectile_instance)
			_attack_timer = 0
	else:
		# move closer to player
		var direction = displacement.normalized()
		self.position += direction * _speed * delta
