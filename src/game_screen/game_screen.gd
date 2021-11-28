extends Node2D

export(int) var current_level_index = 0

onready var _pause_container: ColorRect = $"Gui/CanvasLayer/PauseContainer"
onready var _camera_body: KinematicBody2D = $"Camera"
onready var _gui: Gui = $"Gui"

var _levels = [
	preload("res://game_screen/levels/level0.tscn"),
]
var _current_level: Level = null

func _ready() -> void:
	_load_level(current_level_index)


func _unhandled_input(event) -> void:
	if event.is_action_pressed("system_pause"):
		get_tree().paused = true
		_pause_container.visible = true
		return


func _load_level(index: int) -> void:
	if _current_level != null:
		_current_level.teardown()
		remove_child(_current_level)

	_current_level = _levels[index].instance() as Level
	add_child(_current_level)

	_camera_body.position = _current_level.get_start_position()
	var _err = _current_level.connect("energy_changed", self, "_level_energy_changed")
	_err = _current_level.connect("score_changed", self, "_level_score_changed")
	_err = _current_level.connect("health_changed", self, "_level_health_changed")
	_current_level.setup()


func _level_energy_changed(_level, current_energy, total_energy):
	_gui.set_energy(current_energy, total_energy)


func _level_score_changed(_level, amount, total):
	_gui.set_score(total, amount)


func _level_health_changed(_level, amount, total):
	_gui.set_health(total, amount)


func _on_QuitButton_pressed() -> void:
	_pause_container.visible = false
	get_tree().paused = false
	var _err = get_tree().change_scene("res://title_screen/title_screen.tscn")


func _on_ContinueButton_pressed():
	_pause_container.visible = false
	get_tree().paused = false
