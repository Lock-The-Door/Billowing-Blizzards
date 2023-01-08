extends "res://Scripts/Projectile.gd"

func _process(delta):
	# move
	var rotation = Vector2(1, 0).rotated(self.rotation)
	self.position += rotation * delta * _projectileSpeed
