extends Node2D
# Constants and variables used across scenes and scripts


const WORLD_LENGTH = 2000
const WORLD_SIZE = Vector2(WORLD_LENGTH, WORLD_LENGTH)

var GameDataManager
var LastPlayStats = null


func _ready():
	GameDataManager = load("res://Scripts/game_data_manager.gd").new()
