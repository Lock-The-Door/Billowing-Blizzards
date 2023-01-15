extends AspectRatioContainer

func init(name, price, description, image):
	get_node("Button/Container/Text/Name").text = name
	get_node("Button/Container/Text/Price").text = price
	get_node("Button/Container/Image").texture = image
