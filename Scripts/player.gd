class_name Player
extends Node2D
# Controls everything related to the player
# Movement, health, snow, death, body positioning, etc.


signal health_changed(new_health)
signal max_health_changed(new_max_health)
signal snow_changed(new_snow)

const WORLD_SIZE = Globals.WORLD_SIZE

export (int)var max_bodies
export (int)var _body_overlap
export (int)var _speed
export (float)var _health_per_snow

var body_count = 0
var is_nonplayable = false

var _health
var _max_health = 0

var _snow = 0
var _snow_per_step

onready var _enemy_spawner = get_node("/root/Game/Enemies")
onready var _damage_effect := get_node("Damage Effect") as DamageEffect


func _ready():
	if is_nonplayable:
		return

	# add initial body
	var new_body = load("res://Templates/Upgrades/Snow Body.tscn").instance()
	add_child(new_body)
	body_count += 1
	new_body.init(body_count)

	# remove a stick during the tutorial
	var stick = load("res://Templates/Weapons/Stick.tscn")
	if Globals.GameDataManager.game_data["Tutorial Completed"]:
		var left_stick = stick.instance()
		new_body.add_item(left_stick, "left")
	var right_stick = stick.instance()
	new_body.add_item(right_stick, "right")

	resolve_body_parts()
	
	_health = _max_health


# These variables account for non-integer values when collecting snow
var _accumulated_health = 0.0
var _accumulated_snow = 0.0

func _process(delta):
	if is_nonplayable:
		get_node("Trail Particles").emitting = false
		return
		
	var start_pos = self.position

	# Movement
	# Up:
	if Input.is_physical_key_pressed(KEY_W) or Input.is_physical_key_pressed(KEY_UP):
		self.translate(Vector2(0, delta * -_speed))
	# Down:
	if Input.is_physical_key_pressed(KEY_S) or Input.is_physical_key_pressed(KEY_DOWN):
		self.translate(Vector2(0, delta * _speed))
	# Left:
	if Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT):
		self.translate(Vector2(delta * -_speed, 0))
	# Right:
	if Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT):
		self.translate(Vector2(delta * _speed, 0))
	
	# Clamp to world size of 1000 x 1000
	self.position.x = clamp(self.position.x, WORLD_SIZE.x / -2, WORLD_SIZE.x / 2)
	self.position.y = clamp(self.position.y, WORLD_SIZE.y / -2, WORLD_SIZE.y / 2)
	
	var player_moved = self.position != start_pos
	get_node("Trail Particles").emitting = player_moved
	
	# Snow collection and healing
	if player_moved:
		# Heal if not full health
		if _health < _max_health:
			_accumulated_health += _snow_per_step * _health_per_snow
			while _accumulated_health >= 1:
				_health += 1
				_enemy_spawner.activate_trigger("snow_collected") # technically you are still collecting snow
				_accumulated_health -= 1
			_health = min(_health, _max_health)
			
			emit_signal("health_changed", _health)
		else:
			_accumulated_snow += _snow_per_step
			while _accumulated_snow >= 1:
				add_snow(1)
				_enemy_spawner.activate_trigger("snow_collected")
				_accumulated_snow -= 1


var _is_dead = false

func damage(damage):
	_damage_effect.play_effect()
	add_health(-damage)
	if _health <= 0 and not _is_dead:
		_is_dead = true # prevents the creation of too many particles
		_health = 0
		
		# Player is dead
		var dp_instance = load("res://Templates/Effects/Death Particles.tscn").instance()
		dp_instance.global_position = self.global_position
		get_node("../Particles").add_child(dp_instance)
		self.visible = false
		
		# Prepare to transition to game over screen
		is_nonplayable = true
		Globals.LastPlayStats = {
			"days": get_parent().level,
			"kills": get_node("/root/GameGameplay HUD/Top Panel/Control/Kill Count/Label")._enemies_killed
		}
		get_node("/root/GameGame Over Transition").visible = true


func add_snow(delta_snow):
	_snow += delta_snow
	emit_signal("snow_changed", _snow)
	
func get_snow():
	return _snow


# return health data for initialzing HUD
func get_health():
	return _health
	
func add_health(delta_health):
	_health += delta_health
	emit_signal("health_changed", _health)
	

# Moves the body parts to the correct positions
func resolve_body_parts():
	var children = get_children()

	# Get the height of the bottom-most body part
	var bottom_height = 0
	for child in children:
		if child is Sprite or child is AnimatedSprite:
			bottom_height = child.get_texture().get_size().y * child.scale.y
			break

	# Move the body parts to the correct positions
	# Also calculate the max health
	var current_height = 0
	_max_health = 0
	_snow_per_step = 0
	for child in children:
		if child is Sprite or child is AnimatedSprite:
			var child_height = child.get_texture().get_size().y * child.scale.y
			child.position.y = -current_height - child_height / 2 + bottom_height / 2
			current_height += child_height - _body_overlap
			
		if child.is_in_group("Body"):
			_max_health += child.health
			_snow_per_step += child.snow_absorbtion
	emit_signal("max_health_changed", _max_health)

	# Move the particles to the bottom of the body
	get_node("Trail Particles").position.y = bottom_height/4
