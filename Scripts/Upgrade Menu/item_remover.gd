class_name ItemRemover
extends ItemSetter
# Removes the item from a slot by initializing the ItemSetter with null


func _ready():
	init(null)
