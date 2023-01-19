extends CPUParticles2D

func _ready():
	self.emitting = true

func _process(_delta):
	if not self.emitting:
		self.queue_free()
