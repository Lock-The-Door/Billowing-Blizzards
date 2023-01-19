extends Node2D

const WORLD_SIZE = Globals.WORLD_SIZE
const BODY = preload("res://Templates/Upgrades/Snow Body.tscn")
const STICK = preload("res://Templates/Weapons/Stick.tscn")
const DEATH_PARTICLES = preload("res://Templates/Death Particles.tscn")

export (int)var _speed
export (float)var _healthPerSnow
export (int)var maxBodies

var _health
var _maxHealth = 0

var _snow = 0
var _snowPerStep

var bodyCount = 0
var isNonplayable = false

signal health_changed(newHealth)
signal max_health_changed(newMaxHealth)
signal snow_changed(newSnow)

# Called when the node enters the scene tree for the first time.
func _ready():
	if isNonplayable:
		return

	# add initial body
	var newBody = BODY.instance()
	add_child(newBody)
	bodyCount += 1
	newBody.init(bodyCount)

	var leftStick = STICK.instance()
	newBody.addItem(leftStick, "left")
	var rightStick = STICK.instance()
	newBody.addItem(rightStick, "right")

	resolveBodyParts()
	
	_health = _maxHealth

# These variables account for non-integer values
var _accumulatedHealth = 0.0
var _accumulatedSnow = 0.0
func _process(delta):
	if isNonplayable:
		get_node("Trail Particles").emitting = false
		return
		
	var startPos = position

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
	position.x = clamp(position.x, WORLD_SIZE.x / -2, WORLD_SIZE.x / 2)
	position.y = clamp(position.y, WORLD_SIZE.y / -2, WORLD_SIZE.y / 2)
	
	var playerMoved = position != startPos
	get_node("Trail Particles").emitting = playerMoved
	
	# Snow collection and healing
	if playerMoved:
		# Heal if not full health
		if _health < _maxHealth:
			_accumulatedHealth += _snowPerStep * _healthPerSnow
			while _accumulatedHealth >= 1:
				_health += 1
				_accumulatedHealth -= 1
			_health = min(_health, _maxHealth)
			
			emit_signal("health_changed", _health)
		else:
			_accumulatedSnow += _snowPerStep
			while _accumulatedSnow >= 1:
				addSnow(1)
				_accumulatedSnow -= 1

var _isDead = false
func damage(damage):
	addHealth(-damage)
	if _health <= 0 and not _isDead:
		_isDead = true # prevents the creation of too many particles
		_health = 0
		
		# Player is dead
		var dpInstance = DEATH_PARTICLES.instance()
		dpInstance.global_position = global_position
		get_node("../Particles").add_child(dpInstance)
		self.visible = false
		
		# Prepare to transition to game over screen
		isNonplayable = true
		Globals.LastPlayStats = {
			"days": get_parent().level,
			"kills": get_node("/root/Game/Gameplay HUD/Top Panel/Control/Kill Count/Label")._enemiesKilled
		}
		get_node("/root/Game/Game Over Transition").visible = true
	
func addSnow(deltaSnow):
	_snow += deltaSnow
	emit_signal("snow_changed", _snow)
func getSnow():
	return _snow

# Moves the body parts to the correct positions
func resolveBodyParts():
	var children = get_children()
	children.invert()

	# Get the height of the bottom-most body part
	var bottomHeight = 0
	for child in children:
		if child is Sprite or child is AnimatedSprite:
			bottomHeight = child.get_texture().get_size().y * child.scale.y
			break

	# Move the body parts to the correct positions
	# Also calculate the max health
	var currentHeight = 0
	_maxHealth = 0
	_snowPerStep = 0
	for child in children:
		if child is Sprite or child is AnimatedSprite:
			var childHeight = child.get_texture().get_size().y * child.scale.y
			child.position.y = -currentHeight - childHeight / 2 + bottomHeight / 2
			currentHeight += childHeight
			
		if child.is_in_group("Body"):
			_maxHealth += child.health
			_snowPerStep += child.snowAbsorbtion
	emit_signal("max_health_changed", _maxHealth)

	# Move the particles to the bottom of the body
	get_node("Trail Particles").position.y = bottomHeight/4

# return health data for initialzing HUD
func getHealth():
	return _health
func addHealth(deltaHealth):
	_health += deltaHealth
	emit_signal("health_changed", _health)
