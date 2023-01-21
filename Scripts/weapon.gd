class_name Weapon
extends AnimatedSprite
# A base class for all weapons in the game (currently only the player uses them)


export(int) var attack_damage
export(int) var attack_range
export(int) var attack_cone
export(int) var attack_speed
export(int) var snow_cost
export(String) var projectile_name
export(int) var projectile_speed
export(int) var projectile_lifespan
export(Vector2) var projectile_spawn_offset
export(float) var projectile_scale

var _is_enemy
var _is_disabled = false
var _projectile
var _angle_offset = rotation_degrees

var _attack_timer = 0

onready var _player := get_node("/root/Game/Player") as Player


func _ready():
	# automatically detect if on player or enemy
	var parent = get_parent()
	while parent != null:
		if parent.is_in_group("player"):
			_is_enemy = false
			_is_disabled = parent.is_nonplayable
			break
		elif parent.is_in_group("enemy"):
			_is_enemy = true
			break
		parent = parent.get_parent()

	if projectile_name != "":
		_projectile = load("res://Templates/Projectiles/" + projectile_name + ".tscn")
		if flip_h:
			projectile_spawn_offset.x *= -1
			_angle_offset += 180


func _process(delta):
	if not _is_enemy:
		_is_disabled = _player.is_nonplayable
	if _is_disabled:
		return

	_attack_timer += delta

	# find the closest target within the attacking cone
	var closest_target = null
	var closest_distance = attack_range
	var closest_angle = null
	var targets = get_tree().get_nodes_in_group("player" if _is_enemy else "enemy")
	for target in targets:
		# attack cone
		var displacement = target.global_position - self.global_position
		var angle = atan2(displacement.y, displacement.x)

		if rad2deg(angle) < _angle_offset - attack_cone/2 or rad2deg(angle) > _angle_offset + attack_cone/2:
			print(str(angle) + " out of cone")
			continue

		var distance = displacement.length()
		if distance < closest_distance:
			closest_target = target
			closest_distance = distance
			closest_angle = angle

	# ammo check for player
	var sufficient_ammo = true
	if not _is_enemy and _player.get_snow() < snow_cost:
		print(_player.get_snow())
		sufficient_ammo = false

	# attack the closest target
	if closest_target != null and sufficient_ammo:
		# consume snow if on player
		if not _is_enemy:
			_player.add_snow(-snow_cost)
		
		if _attack_timer * attack_speed >= 1:
			_attack_timer = 0
			
			set_animation("attack")
			if not frames.get_animation_loop("attack"):
				frame = 0
			
			if _projectile == null:
				# melee attack
				closest_target.damage(attack_damage)
			else:
				var projectile_instance = _projectile.instance()
				projectile_instance.position = projectile_spawn_offset
				projectile_instance.scale = Vector2(projectile_scale/scale.x, projectile_scale/scale.y)
				projectile_instance.init(closest_angle, projectile_speed, projectile_lifespan, attack_damage, _is_enemy)
				add_child(projectile_instance)
	else:
		if frames.get_animation_loop("attack"):
			set_animation("idle")
		elif frame == frames.get_frame_count("attack") - 1:
			set_animation("idle")
