extends AnimatedSprite

export(int) var attackDamage
export(int) var attackRange
export(int) var attackCone
export(int) var attackSpeed
export(String) var projectileName
export(int) var projectileSpeed
export(int) var projectileLifespan
export(Vector2) var projectileSpawnOffset
export(float) var projectileScale

var _isEnemy
var _isDisabled = false
var _projectile
var _angleOffset = rotation_degrees

var _attackTimer = 0

func _ready():
	# automatically detect if on player or enemy
	var parent = get_parent()
	while parent != null:
		if parent.is_in_group("player"):
			_isEnemy = false
			_isDisabled = parent.isNonplayable
			break
		elif parent.is_in_group("enemy"):
			_isEnemy = true
			break
		parent = parent.get_parent()

	if projectileName != "":
		_projectile = load("res://Templates/Projectiles/" + projectileName + ".tscn")
		if flip_h:
			projectileSpawnOffset.x *= -1
			_angleOffset += 180

func _process(delta):
	if _isDisabled:
		return

	_attackTimer += delta

	# find the closest target within the attacking cone
	var closestTarget = null
	var closestDistance = attackRange
	var closestAngle = null
	var targets = get_tree().get_nodes_in_group("player" if _isEnemy else "enemy")
	for target in targets:
		# attack cone
		var displacement = target.global_position - self.global_position
		var angle = atan2(displacement.y, displacement.x)

		if abs(rad2deg(angle) - _angleOffset) > attackCone / 2 and abs(rad2deg(angle) + _angleOffset) > attackCone / 2:
			continue

		var distance = displacement.length()
		if distance < closestDistance:
			closestTarget = target
			closestDistance = distance
			closestAngle = angle

	# attack the closest target
	if closestTarget != null:
		if _attackTimer * attackSpeed >= 1:
			_attackTimer = 0
			
			set_animation("attack")
			if not frames.get_animation_loop("attack"):
				frame = 0
			
			if _projectile == null:
				# melee attack
				closestTarget.damage(attackDamage)
			else:
				var projectileInstance = _projectile.instance()
				projectileInstance.position = projectileSpawnOffset
				projectileInstance.scale = Vector2(projectileScale/scale.x, projectileScale/scale.y)
				projectileInstance.init(closestAngle, projectileSpeed, projectileLifespan, attackDamage, _isEnemy)
				self.add_child(projectileInstance)
	else:
		if frames.get_animation_loop("attack"):
			set_animation("idle")
		elif frame == frames.get_frame_count("attack") - 1:
			set_animation("idle")
