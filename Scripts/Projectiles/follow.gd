extends Projectile
# A projectile that follows the player


export (int)var projectile_angle_speed = self.projectile_speed / 100


func _process(delta):
	# Get direction to player
	var displacement = _player.global_position - global_position
	var angle = atan2(displacement.y, displacement.x)

	# Calculate where to rotate to
	var angle_difference = angle - self.global_rotation
	var delta_rotation = projectile_angle_speed * delta
	if abs(angle_difference) < delta_rotation:
		delta_rotation = angle_difference
	if angle_difference < 0:
		delta_rotation *= -1

	# rotate and move
	self.global_rotation += delta_rotation
	var rotation = Vector2(1, 0).rotated(self.global_rotation)
	_intended_global_position += rotation * delta * _projectile_speed
	self.global_position = _intended_global_position
