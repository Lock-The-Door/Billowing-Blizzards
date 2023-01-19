extends Node2D

const WORLD_SIZE = preload("res://Scripts/Constants.gd").WORLD_SIZE
const BODY = preload("res://Templates/Upgrades/Snow Body.tscn")
const STICK = preload("res://Templates/Weapons/Stick.tscn")

export (int)var _speed

var _health
var _maxHealth = 0

var _bodyCount = 0
var isNonplayable = false

signal health_changed
signal max_health_changed

# Called when the node enters the scene tree for the first time.
func _ready():
	if isNonplayable:
		return

	# add initial body
	var newBody = BODY.instance()
	add_child(newBody)
	_bodyCount += 1
	newBody.init(_bodyCount)

	var leftStick = STICK.instance()
	newBody.addItem(leftStick, "left")
	var rightStick = STICK.instance()
	newBody.addItem(rightStick, "right")

	resolveBodyParts()
	
	_health = _maxHealth

# Called every frame. 'delta' is the elapsed time since the previous frame.
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
	
	get_node("Trail Particles").emitting = position != startPos

func damage(damage):
	_health -= damage
	if _health <= 0:
		_health = 0
		# TODO: Die
	
	emit_signal("health_changed", _health)

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
	for child in children:
		if child is Sprite or child is AnimatedSprite:
			var childHeight = child.get_texture().get_size().y * child.scale.y
			child.position.y = -currentHeight - childHeight / 2 + bottomHeight / 2
			currentHeight += childHeight
			
		if child.is_in_group("Body"):
			_maxHealth += child.health
	emit_signal("max_health_changed", _maxHealth)

	# Move the particles to the bottom of the body
	get_node("Trail Particles").position.y = bottomHeight/4

# return health data for initialzing HUD
func getHealth():
	print(_health)
	return [_health, _maxHealth]
