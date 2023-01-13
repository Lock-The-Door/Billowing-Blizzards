extends Node2D

onready var spawner = get_node("Enemies")

var _level = 0

func _ready():
    spawner.connect("level_complete", self, "next_level")
    spawner.readLvlData(_level)

func next_level():
    print("Level complete!")
    _level += 1

    # ensure level exists (hardcoded for now)
    if _level > 2:
        print("Game complete!")
        return

    spawner.readLvlData(_level)