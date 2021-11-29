extends Node2D
class_name Level

signal energy_changed(level, amount, total)
signal score_changed(level, amount, total)
signal health_changed(level, amount, total)

export(float) var total_energy = 5
export(float) var current_energy = 5

onready var _core: PlayerCore = $"PlayerCore"
onready var _tilemap: TileMapMesh = $"Obstacles"

var _towers: Array
var _score: float

func _ready() -> void:
	_towers = get_tree().get_nodes_in_group("PlayerTower")


func setup() -> void:
	for tower in _towers:
		tower.connect("activation_requested", self, "_tower_activation_requested")

	emit_signal("energy_changed", self, current_energy, total_energy)
	emit_signal("health_changed", self, _core.current_hitpoints, _core.total_hitpoints)
	_tilemap.setup()
	
	for spawner in get_tree().get_nodes_in_group("EnemySpawner"):
		spawner.setup(_tilemap, _core)
		spawner.connect("core_damaged", self, "_spawner_core_damaged")


func teardown() -> void:
	for tower in _towers:
		tower.disconnect("activity_changed", self, "_tower_activity_changed")


func get_start_position() -> Vector2:
	return _core.global_position


func _tower_activation_requested(tower, active) -> void:
	if active:
		if current_energy >= tower.variant.energy_cost:
			current_energy -= tower.variant.energy_cost
			tower.toggle_active(true)
			emit_signal("energy_changed", self, current_energy, total_energy)
		else:
			emit_signal("energy_changed", self, -1, total_energy)
	else:
		current_energy += tower.variant.energy_cost
		tower.toggle_active(false)
		emit_signal("energy_changed", self, current_energy, total_energy)


func _spawner_core_damaged(_unit, damage):
	_core.current_hitpoints -= damage
	emit_signal("health_changed", self, _core.current_hitpoints, _core.total_hitpoints)


func _on_ScoreTimer_timeout() -> void:
	var delta = floor(_core.current_hitpoints / 10.0)
	_score += delta
	emit_signal("score_changed", self, delta, _score)
