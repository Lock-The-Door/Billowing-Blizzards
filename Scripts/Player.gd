extends Sprite

var worldSize = Vector2(2000, 2000)
var speed = 500

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Movement
	# Up:
	if Input.is_physical_key_pressed(KEY_W) or Input.is_physical_key_pressed(KEY_UP):
		print("Move Up")
		self.translate(Vector2(0, delta * -speed))
	# Down:
	if Input.is_physical_key_pressed(KEY_S) or Input.is_physical_key_pressed(KEY_DOWN):
		print("Move Down")
		self.translate(Vector2(0, delta * speed))
	# Left:
	if Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT):
		print("Move Left")
		self.translate(Vector2(delta * -speed, 0))
	# Right:
	if Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT):
		print("Move Right")
		self.translate(Vector2(delta * speed, 0))

	
	# Clamp to world size of 1000 x 1000
	position.x = clamp(position.x, worldSize.x / -2, worldSize.x / 2)
	position.y = clamp(position.y, worldSize.y / -2, worldSize.y / 2)