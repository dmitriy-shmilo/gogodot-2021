extends Node2D

const SOUNDTRACK_STREAMS = [
	preload("res://assets/music1.mp3"),
	preload("res://assets/music2.mp3"),
	preload("res://assets/music3.mp3")
]
const PAUSE_VOLUME_MOD = -15.0

export(int) var current_level_index = 0

onready var _pause_container: ColorRect = $"Gui/CanvasLayer/PauseContainer"
onready var _camera_body: KinematicBody2D = $"Camera"
onready var _gui: Gui = $"Gui"
onready var _soundtrack_player: AudioStreamPlayer = $"SoundtrackPlayer"
onready var _transition_player: AnimationPlayer = $"TransitionPlayer"

var _current_soundtrack = 0
var _levels = [
	preload("res://game_screen/levels/level0.tscn"),
]
var _current_level: Level = null

func _ready() -> void:
	MenuMusic.stop()
	_transition_player.play("fade_in")
	_load_level(current_level_index)
	_soundtrack_player.stream = SOUNDTRACK_STREAMS[_current_soundtrack]
	_soundtrack_player.play()


func _unhandled_input(event) -> void:
	if event.is_action_pressed("system_pause"):
		get_tree().paused = true
		_pause_container.visible = true
		_set_soundtrack_volume(PAUSE_VOLUME_MOD)
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


func _set_soundtrack_volume(volume: float) -> void:
	var position = _soundtrack_player.get_playback_position()
	_soundtrack_player.stop()
	_soundtrack_player.volume_db = volume
	_soundtrack_player.play(position)


func _level_energy_changed(_level, current_energy, total_energy):
	_gui.set_energy(current_energy, total_energy)


func _level_score_changed(_level, amount, total):
	_gui.set_score(total, amount)


func _level_health_changed(_level, amount, total):
	_gui.set_health(total, amount)
	if amount <= 0:
		_transition_player.play("fade_out")
		yield(_transition_player, "animation_finished")
		get_tree().change_scene("res://game_over_screen/game_over_screen.tscn")


func _on_QuitButton_pressed() -> void:
	_pause_container.visible = false
	get_tree().paused = false
	var _err = get_tree().change_scene("res://title_screen/title_screen.tscn")


func _on_ContinueButton_pressed():
	_pause_container.visible = false
	_set_soundtrack_volume(0.0)
	get_tree().paused = false


func _on_SoundtrackPlayer_finished() -> void:
	_current_soundtrack = (_current_soundtrack + 1) % SOUNDTRACK_STREAMS.size()
	_soundtrack_player.play(SOUNDTRACK_STREAMS[_current_soundtrack])
