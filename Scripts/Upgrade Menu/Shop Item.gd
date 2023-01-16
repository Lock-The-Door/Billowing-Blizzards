extends AspectRatioContainer

func init(itemData):
	get_node("Button/Container/Text/Name").text = itemData.name
	get_node("Button/Container/Text/Price").text = str(itemData.price) + " snow"
	get_node("Button/Container/Image").texture = load(itemData.image)
