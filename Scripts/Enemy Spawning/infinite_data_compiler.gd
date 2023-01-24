class_name InfiniteDataCompiler
# Compiles dynamic level data in infinite level data files


var _level


func _init(level):
	_level = level


func compile(dynamic_level_data):
	var compiled_data
	if dynamic_level_data is Dictionary:
		compiled_data = {}
		for key in dynamic_level_data:
			compiled_data[key] = compile(dynamic_level_data[key])
	elif dynamic_level_data is Array:
		compiled_data = []
		for element in dynamic_level_data:
			compiled_data.append(compile(element))
	elif dynamic_level_data is String:
		if dynamic_level_data.find(";") != -1:
			compiled_data = []
			for element in dynamic_level_data.split(";"):
				compiled_data.append(compile(element))
			compiled_data = ";".join(compiled_data)
		elif dynamic_level_data.find("=") != -1:
			compiled_data = dynamic_level_data.split("=")
			compiled_data = compiled_data[0] + "=" + str(compile(compiled_data[1]))
			print(compiled_data)
		else:
			var expression = Expression.new()
			var status = expression.parse(dynamic_level_data, ['level'])
			assert(status == OK, "Error parsing expression: " + dynamic_level_data)
			compiled_data = expression.execute([_level], self)
			if expression.has_execute_failed():
				compiled_data = dynamic_level_data

	return compiled_data


func random_timestamp(start, end):
	# Returns a random timestamp between start and end
	var start_timestamp = Time.get_unix_time_from_datetime_string(start)
	var end_timestamp = Time.get_unix_time_from_datetime_string(end)

	var random_timestamp = randi() % (end_timestamp - start_timestamp) + start_timestamp
	return Time.get_datetime_string_from_unix_time(random_timestamp)
