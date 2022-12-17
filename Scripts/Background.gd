extends TextureRect

const WORLD_SIZE = preload("res://Scripts/Constants.gd").WORLD_SIZE

func _ready():
	self.set_size(WORLD_SIZE*2)
	self.set_position(WORLD_SIZE / -2)
