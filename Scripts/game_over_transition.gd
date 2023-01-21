class_name GameOverTransition
extends CenterUi


onready var tween := get_node("Tween") as Tween


func _ready():
	tween.interpolate_property(self, "color", Color.transparent, Color.black, 3)
	tween.connect("tween_all_completed", self, "_tween_completed")


func _draw():
	center_scale()
	tween.start()


func _tween_completed():
	var status = get_tree().change_scene("res://Scenes/Game Over.tscn")
	assert(status == OK)
