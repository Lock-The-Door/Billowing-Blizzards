extends Projectile
# A projectile that travels in a straight line


func _process(delta):
	# move
	var rotation = Vector2(1, 0).rotated(self.global_rotation)
	_intendedGlobalPosition += rotation * delta * _projectileSpeed
	global_position = _intendedGlobalPosition
