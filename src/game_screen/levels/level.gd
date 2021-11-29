extends Node2D
class_name Level

signal energy_changed(level, amount, total)
signal score_changed(level, amount, total)
signal health_changed(level, amount, total)

export(float) var total_energy = 6
export(float) var current_energy = 6

onready var _core: PlayerCore = $"PlayerCore"
onready var _tilemap: TileMapMesh = $"Obstacles"
onready var _power_on_player: AudioStreamPlayer = $"PowerOnPlayer"
onready var _power_off_player: AudioStreamPlayer = $"PowerOffPlayer"
onready var _warning_player: AudioStreamPlayer = $"WarningPlayer"
onready var _generator_particles = [
	$"HQ/BrokenGenerator/CPUParticles2D",
	$"HQ/BrokenGenerator2/CPUParticles2D",
	$"HQ/BrokenGenerator3/CPUParticles2D",
]

var _towers: Array
var _score: float

func _ready() -> void:
	_towers = get_tree().get_nodes_in_group("PlayerTower")
	
	if Settings.particles:
		for p in _generator_particles:
			p.emitting = true
			p.visible = true


func _input(event: InputEvent) -> void:
	if event.is_action("shut_down"):
		var had_effect = false
		for tower in _towers:
			had_effect = had_effect or tower._state != PlayerTower.TowerState.INACTIVE
			tower.toggle_active(false)
			current_energy = total_energy
			emit_signal("energy_changed", self, current_energy, total_energy)

		if had_effect:
			_power_off_player.play()
		

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
			_power_on_player.play()
		else:
			emit_signal("energy_changed", self, -1, total_energy)
			_warning_player.play()
	else:
		current_energy += tower.variant.energy_cost
		tower.toggle_active(false)
		emit_signal("energy_changed", self, current_energy, total_energy)
		_power_off_player.play()


func _spawner_core_damaged(_unit, damage):
	_core.current_hitpoints -= damage
	emit_signal("health_changed", self, _core.current_hitpoints, _core.total_hitpoints)


func _on_ScoreTimer_timeout() -> void:
	var delta = floor(_core.current_hitpoints / 10.0)
	_score += delta
	emit_signal("score_changed", self, delta, _score)
