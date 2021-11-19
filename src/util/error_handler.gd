extends Node


func handle(err) -> void:
	if err == OK:
		return
	printerr(err)
	# TODO: create an error reporting screen
	get_tree().quit()
	
