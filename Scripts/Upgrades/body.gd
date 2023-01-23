class_name Body
extends Sprite


export (int)var health
export (float)var snow_absorbtion # bonus snow per step (scales with scale)
export (float)var _scale_factor # how much bigger and more health each body gives
export (String)var item_config # The positioning and other properties of items on the body

var items = {}


func _ready():
	if item_config is Dictionary:
		return
	
	var file = File.new()
	file.open("res://Resources/Item Data/" + item_config + ".bbid", File.READ)
	item_config = parse_json(file.get_as_text())
	file.close()
	for location in item_config:
		# convert the position to a vector2
		var pos = item_config[location]["position"]
		item_config[location]["position"] = Vector2(pos["x"], pos["y"])
		
		items[location] = null


func init(body_number):
	# calculate the actual scale
	var scale = calculate_scale(body_number)

	# set the scale
	set_scale(Vector2(scale, scale))

	# child tree positioning for correct overlapping
	get_parent().move_child(self, 1)

	# calculate the heath this body gives
	health = health * scale

	# calculate snow absorbtion
	snow_absorbtion *= scale
	

func calculate_scale(body_number):
	return _scale_factor * body_number + 1


func add_item(item, location):
	# remove previous item
	if items[location] != null:
		items[location].queue_free()
	
	items[location] = item
	
	if item == null:
		return
	
	item.position = item_config[location]["position"] * self.scale
	item.flip_h = item_config[location]["flipH"]
	item.flip_v = item_config[location]["flipV"]
	if item.flip_h:
		item.offset.x *= -1
	if item.flip_v:
		item.offset.y *= -1
	add_child(item)
