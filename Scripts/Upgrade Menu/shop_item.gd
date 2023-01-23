class_name ShopItem
extends AspectRatioContainer
# A shop item is a container that holds an item's image, name, and price.
# This script will set these values from the item data.


func init(item_data, player):
	get_node("Button/Container/Text/Name").text = item_data.name
	self.hint_tooltip = item_data.description
	get_node("Button/Container/Text/Price").text = str(item_data.price) + " snow"
	get_node("Button/Container/Image").texture = load(item_data.image)

	var purchase_button := get_node("Button") as ItemSetter
	purchase_button.init(item_data)
	var properties_container = get_node("Button/Container/Text/Properties") as ItemProperties
	properties_container.init(item_data.resource, player)
