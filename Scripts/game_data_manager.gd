class_name GameDataManager
extends Resource


const FILE_NAME = "user://save.bbgd"

var game_data = {
	"Tutorial Completed": false
}


func save():
	var file = File.new()
	file.open(FILE_NAME, File.WRITE)
	file.store_string(to_json(game_data))
	file.close()


func load():
	var file = File.new()
	if file.file_exists(FILE_NAME):
		file.open(FILE_NAME, File.READ)
		var data = parse_json(file.get_as_text())
		file.close()
		if typeof(data) == TYPE_DICTIONARY:
			game_data = data
		else:
			push_warning("Corrupted data!")
	else:
		push_warning("No saved data!")
