class_name Shield
extends AnimatedSprite
# A base class that represents all shields in the game


export (bool)var is_percent_shield = false
export (int)var shield_amount
export (int)var shield_cooldown
export(int) var snow_cost

var _parent_entity

var _absorb_timer = 0


func _ready():
	# get the entity parent and copy their team group
	var parent = get_parent()
	while parent != null:
		if parent.is_in_group("player"):
			_parent_entity = parent
			add_to_group("player")
			break
		elif parent.is_in_group("enemy"):
			_parent_entity = parent
			add_to_group("enemy")
			break
		parent = parent.get_parent()
		
	# convert percent to decimal for percent shields
	# since shields are specified as an integer
	if is_percent_shield:
		shield_amount /= 100.0
		shield_amount = 1 - shield_amount
		
		
func _process(delta):
	_absorb_timer += delta
	
	# check if ready to go back to idle
	if animation == "absorb" and frames.get_frame_count("absorb") == self.frame:
		set_animation("idle")


# Intercept damage to entity
func damage(damage):
	# ensure ready to absorb
	if _absorb_timer < shield_cooldown:
		return
	
	var adjusted_damage = damage
	if is_percent_shield:
		adjusted_damage *= shield_amount
	else:
		adjusted_damage -= shield_amount
		
	# damage the entity by the adjusted amount
	_parent_entity.damage(adjusted_damage)
	
	# play animation
	set_animation("absorb")
	self.frame = 0 # shield frames should never loop
