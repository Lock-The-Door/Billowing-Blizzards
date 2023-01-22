class_name Enemy
extends Sprite


const DEATH_PARTICLES = preload("res://Templates/Effects/Death Particles.tscn")
const DAMAGE_EFFECT = preload("res://Templates/Effects/Damage Effect.tscn")


# enemy properties
export(int) var _health
export(int) var _speed
export(int) var _attack_damage
export(int) var _attack_range
export(int) var _attack_speed

# other stuff
onready var _player := get_node("/root/Game/Player") as Player
onready var _enemy_root := get_node("/root/Game/Enemies") as EnemySpawner

onready var _dmg_effect_instance := DAMAGE_EFFECT.instance() as DamageEffect


func _ready():
	add_child(_dmg_effect_instance)


func damage(damage):
	_dmg_effect_instance.play_effect()
	_health -= damage
	
	# dying
	if (_health <= 0):
		_enemy_root.activate_trigger("enemy_killed")
		var dp_instance = DEATH_PARTICLES.instance()
		dp_instance.global_position = global_position
		get_node("/root/Game/Particles").add_child(dp_instance)
		queue_free()
