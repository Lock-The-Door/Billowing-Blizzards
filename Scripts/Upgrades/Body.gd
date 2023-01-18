extends Sprite

export (int)var _health
export (float)var _scaleFactor # how much bigger and more health each body gives
export (float)var _textureScale # how much bigger the texture is
export (String)var itemConfig # The positioning and other properties of items on the body

var items = {}

func _ready():
	if itemConfig is Dictionary:
		return
	
	var file = File.new()
	file.open("res://Resources/Item Data/" + itemConfig + ".json", File.READ)
	itemConfig = parse_json(file.get_as_text())
	file.close()
	for location in itemConfig:
		# convert the position to a vector2
		var pos = itemConfig[location]["position"]
		itemConfig[location]["position"] = Vector2(pos["x"], pos["y"])
		
		items[location] = null

func init(bodyNumber):
	# calculate the actual scale
	var scale = _scaleFactor * bodyNumber + 1

	# set the scale
	set_scale(Vector2(scale, scale) * _textureScale)

	# calculate the heath this body gives
	_health = _health * scale

func addItem(item, location):
	# remove previous item
	if items[location] != null:
		items[location].queue_free()
	
	items[location] = item
	
	if item == null:
		return
	
	item.position = itemConfig[location]["position"]
	item.flip_h = itemConfig[location]["flipH"]
	item.flip_v = itemConfig[location]["flipV"]
	if item.flip_h:
		item.offset.x *= -1
	if item.flip_v:
		item.offset.y *= -1
	add_child(item)
