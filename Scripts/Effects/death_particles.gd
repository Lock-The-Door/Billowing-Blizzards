class_name DeathParticles
extends CPUParticles2D
# A script that starts and destroys the particles on deaths


func _ready():
	self.emitting = true


func _process(_delta):
	if not self.emitting:
		self.queue_free()
