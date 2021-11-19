extends Node2D


onready var _pause_container: ColorRect = $Gui/PauseContainer

func _ready():
	pass


func _unhandled_input(event):
	if event.is_action("system_pause"):
		get_tree().paused = true
		_pause_container.visible = true
		


func _on_QuitButton_pressed():
	_pause_container.visible = false
	get_tree().paused = false
	get_tree().change_scene("res://title_screen/title_screen.tscn")


func _on_ContinueButton_pressed():
	_pause_container.visible = false
	get_tree().paused = false
