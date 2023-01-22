class_name Projectile
extends Node2D
# Base class for projectiles, manages projectile variables collision and lifespan


const WORLD_LENGTH = preload("res://Scripts/globals.gd").WORLD_LENGTH

onready var _player := get_node("/root/Game/Player") as Player
onready var _collision_node := get_node("Area2D") as Area2D

var _projectile_speed
var _projectile_lifespan
var _projectile_damage
var _is_enemy_projectile

var _intended_global_position


func _ready():
	add_to_group("projectile")
	self.z_index = 1
	_intended_global_position = global_position


func init(angle, speed, lifespan, damage, is_enemy_projectile = false):
	_projectile_speed = speed
	self.rotation = angle
	_projectile_lifespan = lifespan
	_projectile_damage = damage
	_is_enemy_projectile = is_enemy_projectile


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# movement handled by child class

	# lifespan
	if (_projectile_lifespan != -1):
		_projectile_lifespan -= delta
		if _projectile_lifespan <= 0:
			queue_free()
			return
	# check if within the world bounds and offscreen
	var screen_size = get_viewport_rect().size / 2
	var abs_pos = global_position.abs()
	if abs_pos.x > WORLD_LENGTH + screen_size.x or abs_pos.y > WORLD_LENGTH + screen_size.y:
		queue_free()
		return
		
	# collision
	var colliding = _collision_node.get_overlapping_areas()
	# traverse parents until we find a node containing the player/enemy group
	for area in colliding:
		var parent = area.get_parent()
		while parent != null:
			if parent.is_in_group("player") and _is_enemy_projectile:
				parent.damage(_projectile_damage)
				queue_free()
				return
			elif parent.is_in_group("enemy") and not _is_enemy_projectile:
				parent.damage(_projectile_damage)
				queue_free()
				return
			elif parent.is_in_group("projectile"):
				# ignore collisions with other projectiles
				break
			parent = parent.get_parent()
