extends Node2D

var enemyNode

func init(enemyType):
	enemyNode = load("res://Templates/Enemies/" + enemyType + ".tscn").instance()
	self.add_child(enemyNode)

func damage(damage):
	enemyNode.health -= damage
