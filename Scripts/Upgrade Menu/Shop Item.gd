extends AspectRatioContainer

func init(itemData):
	get_node("Button/Container/Text/Name").text = itemData.name
	get_node("Button/Container/Text/Price").text = str(itemData.price) + " snow"
	var image = Image.new()
	image.load(itemData.image)
	get_node("Button/Container/Image").texture.create_from_image(image)
