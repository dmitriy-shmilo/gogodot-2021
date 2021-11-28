extends Node
class_name Gui

onready var _energy_bar: ProgressBar = $"CanvasLayer/EnergyBar"
onready var _health_bar: ProgressBar = $"CanvasLayer/HealthBar"
onready var _score_label: Label = $"CanvasLayer/ScoreLabel"

func set_energy(current, total):
	_energy_bar.max_value = total
	_energy_bar.value = current


func set_score(total, amount = 0):
	# TODO: float amount up
	_score_label.text = "x" + str(total)


func set_health(current, total):
	_health_bar.max_value = total
	_health_bar.value = current
