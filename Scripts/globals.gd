extends Node2D
# Constants and variables used across scenes and scripts


const WORLD_LENGTH = 5000
const WORLD_SIZE = Vector2(WORLD_LENGTH, WORLD_LENGTH)

const DEFAULT_DAMAGE_COLOR = Color.deepskyblue

var GameDataManager
var LastPlayStats = null


func _ready():
	get_tree().set_auto_accept_quit(false) # Don't quit automatically

	GameDataManager = load("res://Scripts/Game/_data_manager.gd").new()
	GameDataManager.load() # Load data


func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		GameDataManager.save() # Save data before quitting
		get_tree().quit() # Exit
