extends Enemy
# Logic for melee enemies


var _attack_timer = 0


func _process(delta):
	# get displacement from player
	var displacement = _player.position - self.position
	
	_attack_timer += delta
	# within attacking range?
	if displacement.length() < _attack_range:
		# try to damage the player
		if _attack_timer * _attack_speed >= 1:
			_player.damage(_attack_damage)
			_attack_timer = 0
	else:
		# move closer to player
		var direction = displacement.normalized()
		self.position += direction * _speed * delta
