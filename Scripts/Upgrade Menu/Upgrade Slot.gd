extends Button

export (String)var type
var item = null

const UBG = preload("res://Resources/UpgradesButtonGroup.tres")
func _ready():
	self.group = UBG
