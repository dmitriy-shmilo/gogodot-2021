extends Node


export(float) var total_energy = 100
export(float) var available_energy = 100

onready var _energy_bar: ProgressBar = $"CanvasLayer/EnergyBar"

func _ready() -> void:
	pass
