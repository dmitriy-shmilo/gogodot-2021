extends Node2D

export(int) var current_level_index = 0

onready var _pause_container: ColorRect = $Gui/CanvasLayer/PauseContainer

var _levels = [
	preload("res://game_screen/levels/level0.tscn"),
]
var _current_level: Level = null

func _ready() -> void:
	_load_level(current_level_index)


func _unhandled_input(event) -> void:
	if event.is_action("system_pause"):
		get_tree().paused = true
		_pause_container.visible = true
		


func _load_level(index: int) -> void:
	if _current_level != null:
		remove_child(_current_level)
	
	_current_level = _levels[index].instance() as Level
	add_child(_current_level)


func _on_QuitButton_pressed() -> void:
	_pause_container.visible = false
	get_tree().paused = false
	get_tree().change_scene("res://title_screen/title_screen.tscn")


func _on_ContinueButton_pressed():
	_pause_container.visible = false
	get_tree().paused = false
