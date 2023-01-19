extends Resource

const FILE_NAME = ""

var GameData = {
	"Tutorial Completed": false
}

func save():
	var file = File.new()
	file.open(FILE_NAME, File.WRITE)
	file.store_string(to_json(GameData))
	file.close()

func load():
	var file = File.new()
	if file.file_exists(FILE_NAME):
		file.open(FILE_NAME, File.READ)
		var data = parse_json(file.get_as_text())
		file.close()
		if typeof(data) == TYPE_DICTIONARY:
			GameData = data
		else:
			printerr("Corrupted data!")
	else:
		printerr("No saved data!")
