extends AnimatedSprite

export(int) var attackDamage
export(int) var attackRange
export(int) var attackSpeed
export(String) var projectileName
export(int) var projectileSpeed
export(int) var projectileLifespan
export(Vector2) var projectileSpawnOffset

var _isEnemy
var _isDisabled = false
var _projectile

var _attackTimer = 0

func _ready():
	# automatically detect if on player or enemy
	var parent = get_parent()
	while parent != null:
		if parent.is_in_group("player"):
			_isEnemy = false
			_isDisabled = parent.isNonplayable
			return
		elif parent.is_in_group("enemy"):
			_isEnemy = true
		parent = parent.get_parent()

	if projectileName != "":
		_projectile = load("res://Templates/Projectiles/" + projectileName + ".tscn")

func _process(delta):
	if _isDisabled:
		return

	_attackTimer += delta

	# find the closest target
	var closestTarget = null
	var closestDistance = attackRange
	var targets = get_tree().get_nodes_in_group("player" if _isEnemy else "enemy")
	for target in targets:
		var distance = target.position.distance_to(position)
		if distance < closestDistance:
			closestTarget = target
			closestDistance = distance

	# attack the closest target
	if closestTarget != null:
		if _attackTimer * attackSpeed >= 1:
			_attackTimer = 0
			
			print("attack")
			
			if _projectile == null:
				# melee attack
				closestTarget.damage(attackDamage)
			else:
				var displacement = closestTarget.position - self.position

				var projectileInstance = _projectile.instance()
				var angle = atan2(displacement.y, displacement.x)
				projectileInstance.init(angle, projectileSpeed, projectileLifespan, attackDamage, _isEnemy)
				projectileInstance.position = projectileSpawnOffset
				self.add_child(projectileInstance)
