extends "res://Scripts/Projectiles/Projectile.gd"

func _process(delta):
	# move
	var rotation = Vector2(1, 0).rotated(self.global_rotation)
	self._intendedGlobalPosition += rotation * delta * _projectileSpeed
	global_position = _intendedGlobalPosition
