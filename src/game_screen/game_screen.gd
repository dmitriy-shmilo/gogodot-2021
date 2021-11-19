extends Node2D


onready var _pause_container: ColorRect = $Gui/PauseContainer

func _ready() -> void:
	get_tree().change_scene("res://game_screen/levels/level0.tscn")


func _unhandled_input(event) -> void:
	if event.is_action("system_pause"):
		get_tree().paused = true
		_pause_container.visible = true
		


func _on_QuitButton_pressed() -> void:
	_pause_container.visible = false
	get_tree().paused = false
	get_tree().change_scene("res://title_screen/title_screen.tscn")


func _on_ContinueButton_pressed():
	_pause_container.visible = false
	get_tree().paused = false
