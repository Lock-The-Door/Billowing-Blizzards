extends Sprite

export (int)var _health
export (float)var _scaleFactor # how much bigger and more health each body gives
export (float)var _textureScale # how much bigger the texture is

func init(bodyNumber):
	# calculate the actual scale
	var scale = _scaleFactor * bodyNumber + 1

	# set the scale
	set_scale(Vector2(scale, scale) * _textureScale)

	# calculate the heath this body gives
	_health = _health * scale
