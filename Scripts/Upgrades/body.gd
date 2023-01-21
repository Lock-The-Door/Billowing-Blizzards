class_name Body
extends Sprite


export (int)var health
export (float)var snow_absorbtion # bonus snow per step (scales with scale)
export (float)var _scale_factor # how much bigger and more health each body gives
export (float)var _texture_scale # how much bigger the texture is
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
	var scale = _scale_factor * body_number + 1

	# set the scale
	set_scale(Vector2(scale, scale) * _texture_scale)

	# calculate the heath this body gives
	health = health * scale

	# calculate snow absorbtion
	snow_absorbtion *= scale


func add_item(item, location):
	# remove previous item
	if items[location] != null:
		items[location].queue_free()
	
	items[location] = item
	
	if item == null:
		return
	
	item.position = item_config[location]["position"]
	item.flip_h = item_config[location]["flipH"]
	item.flip_v = item_config[location]["flipV"]
	if item.flip_h:
		item.offset.x *= -1
	if item.flip_v:
		item.offset.y *= -1
	add_child(item)
