class_name DamageEffect
extends Tween
# A tween that changes the parent's color to create a damage effect


var _damage_color
var _normal_color

export (Color)var _damage_color_override

onready var _parent_node := get_parent() as Node2D


func _init():
	_damage_color = _damage_color_override if _damage_color_override == null\
			else Globals.DEFAULT_DAMAGE_COLOR
			
			
func _ready():
	_normal_color = _parent_node.modulate


func play_effect():
	var status = stop_all()
	assert(status)
	
	status = interpolate_property(_parent_node, "modulate", _damage_color, _normal_color,\
			0.5, TRANS_LINEAR)
	status = start() and status
	assert(status)
