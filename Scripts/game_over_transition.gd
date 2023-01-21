class_name GameOverTransition
extends CenterUi


onready var tween := get_node("Tween") as Tween


func _ready():
	var status = tween.interpolate_property(self, "color", Color.transparent, Color.black, 3)
	assert(status)
	status = tween.connect("tween_all_completed", self, "_tween_completed")
	assert(status == OK)


func _draw():
	center_scale()
	assert(tween.start())


func _tween_completed():
	var status = get_tree().change_scene("res://Scenes/Game Over.tscn")
	assert(status == OK)
