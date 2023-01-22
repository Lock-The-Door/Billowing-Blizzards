class_name PlayerHunter
extends Enemy
# Follows the player as its movement pattern


func _process(delta):
	# get displacement from player
	var displacement = _player.position - self.position
	
	# within attacking range?
	if abs(displacement.length()) >= _attack_range:
		# move closer to player
		var direction = displacement.normalized()
		self.position += direction * _speed * delta
