class_name ItemProperties
extends HBoxContainer
# Displays the item's properties on the shop item
# Displays snow usage, attack damage, health etc.


func init(resource_path, player):
	var item = load(resource_path).instance()
	
	var snow = null
	var damage = null
	var protection = null
	var health = null
	var cooldown = null
	
	# Find out the type of item to display the correct information
	if item is Body:
		# calculate the health based on the player body count
		var scale = item.calculate_scale(player.body_count + 1)

		# calculate the heath this body gives
		health = item.health * scale
	elif item is Weapon:
		snow = item.snow_cost
		damage = item.attack_damage
		cooldown = item.attack_speed
	elif item is Shield:
		snow = item.snow_cost
		protection = item.shield_amount
		if item.is_percent_shield:
			protection = str(protection) + "%"
		cooldown = item.shield_cooldown


	# Populate properties with values and unhide them
	if snow != null:
		var snow_node = get_node("Snow")
		snow_node.get_node("Label").text = str(snow)
		snow_node.visible = true
	if damage != null:
		var damage_node = get_node("Damage")
		damage_node.get_node("Label").text = str(damage)
		damage_node.visible = true
	if protection != null:
		var protection_node = get_node("Protection")
		protection_node.get_node("Label").text = str(protection)
		protection_node.visible = true
	if health != null:
		var health_node = get_node("Health")
		health_node.get_node("Label").text = str(health)
		health_node.visible = true
	if cooldown != null:
		var cooldown_node = get_node("Cooldown")
		cooldown_node.get_node("Label").text = str(cooldown) + "/s"
		cooldown_node.visible = true
