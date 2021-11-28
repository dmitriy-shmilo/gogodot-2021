extends Node

const SAVE_FILE = "user://save.json"

var highest_score = 0
var current_score = 0

func save_data() -> void:
	var file = File.new()
	var err = file.open(SAVE_FILE, File.WRITE)
	ErrorHandler.handle(err)
	file.store_string(to_json(_get_data()))
	file.close()


func load_data() -> void:
	var file := File.new()

	if not file.file_exists(SAVE_FILE):
		save_data()
		return

	var open_err = file.open(SAVE_FILE, File.READ)
	ErrorHandler.handle(open_err)

	var data := JSON.parse(file.get_as_text())
	
	if data.error != OK:
		ErrorHandler.handle(data.error)
		save_data()
		return

	_set_from_data(data.result)


func _get_data() -> Dictionary:

	return {
		"highest_score" : highest_score
	}


func _set_from_data(data: Dictionary) -> void:
	highest_score = data["highest_score"]
