extends Sprite

export (int)var _health
export (float)var _scaleFactor # how much bigger and more health each body gives
export (float)var _textureScale # how much bigger the texture is
export (String)var _itemConfig # The positioning and other properties of items on the body

var items = {}

func _ready():
	var file = File.new()
	file.open("res://Resources/Item Data/" + _itemConfig + ".json", File.READ)
	_itemConfig = parse_json(file.get_as_text())
	for location in _itemConfig:
		# convert the position to a vector2
		var pos = _itemConfig[location]["position"]
		_itemConfig[location]["position"] = Vector2(pos["x"], pos["y"])
	
	for location in _itemConfig:
		items[location] = null

func init(bodyNumber):
	# calculate the actual scale
	var scale = _scaleFactor * bodyNumber + 1

	# set the scale
	set_scale(Vector2(scale, scale) * _textureScale)

	# calculate the heath this body gives
	_health = _health * scale

func addItem(item, location):
	items[location] = item
	item.position = _itemConfig[location]["position"]
	item.flip_h = _itemConfig[location]["flipH"]
	item.flip_v = _itemConfig[location]["flipV"]
	if item.flip_h:
		item.offset.x *= -1
	if item.flip_v:
		item.offset.y *= -1
	add_child(item)
