extends Projectile
# A projectile that travels in a straight line


func _process(delta):
	# move
	var rotation = Vector2(1, 0).rotated(self.global_rotation)
	_intended_global_position += rotation * delta * _projectile_speed
	global_position = _intended_global_position
