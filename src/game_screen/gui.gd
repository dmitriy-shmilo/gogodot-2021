extends Node
class_name Gui

onready var _energy_bar: ProgressBar = $"CanvasLayer/EnergyBar"


func set_energy(current, total):
	_energy_bar.max_value = total
	_energy_bar.value = current
