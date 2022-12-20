extends Sprite

export var EnemyType = ""

func _ready():
	self.set_texture(load("res://Assets/Enemies/" + EnemyType + ".png"))

func _process(delta):
	# move towards player
	var player = get_node("/root/Game/Player")
	var direction = player.position - self.position
	direction = direction.normalized()
	self.position += direction * 100 * delta
