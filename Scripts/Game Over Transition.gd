extends "res://Scripts/Center Ui.gd"

onready var tween = get_node("Tween")

func _ready():
	tween.interpolate_property(self, "color", Color.transparent, Color.black, 3)
	tween.connect("tween_all_completed", self, "_tweenCompleted")

func _draw():
	centerScale()
	tween.start()

func _tweenCompleted():
	var result = get_tree().change_scene("res://Scenes/Game Over.tscn")
	if result != OK:
		push_warning("Failed to switch scenes: " + result)
