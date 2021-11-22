extends Node2D
class_name Level

signal energy_changed(level, amount, total)

export(float) var total_energy = 100
export(float) var current_energy = 100

onready var _core: Node2D = $"PlayerCore"
onready var _spawner: Node2D = $"EnemySpawner"
onready var _tilemap: TileMapMesh = $"Walls"

var _towers: Array

func _ready() -> void:
	_towers = get_tree().get_nodes_in_group("PlayerTower")


func setup() -> void:
	for tower in _towers:
		tower.connect("activity_changed", self, "_tower_activity_changed")

	emit_signal("energy_changed", self, current_energy, total_energy)
	_tilemap.setup()
	
	for spawner in get_tree().get_nodes_in_group("EnemySpawner"):
		spawner.setup(_tilemap, _core)


func teardown() -> void:
	for tower in _towers:
		tower.disconnect("activity_changed", self, "_tower_activity_changed")


func get_start_position() -> Vector2:
	return _core.global_position


func _tower_activity_changed(tower, is_active) -> void:
	if is_active:
		current_energy -= tower.energy
	else:
		current_energy += tower.energy

	emit_signal("energy_changed", self, current_energy, total_energy)


func _on_Timer_timeout() -> void:
	for spawner in get_tree().get_nodes_in_group("EnemySpawner"):
		spawner.spawn_next()
