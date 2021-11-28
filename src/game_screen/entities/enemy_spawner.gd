extends Node2D
class_name EnemySpawner

const FRAME_SIZE = 32
const DEATHS_BEFORE_REPATH = 5
const DEATHS_BEFORE_UPGRADE = 15
const MAX_SPAWN_RATE = 5

signal core_damaged(source, damage)

var _map: TileMapMesh
var _core: PlayerCore
var _points: PoolVector2Array
var _enemy_scene = preload("res://game_screen/entities/enemies/enemy_unit.tscn")
var _current_deaths = 0
var _current_spawn_rate = 0.3

onready var _spawner_sprite = $"SpawnerSprite"
onready var _debug_line = $"Node/DebugLine"
onready var _spawn_timer = $"SpawnTimer"

func setup(map, core) -> void:
	_map = map
	_core = core
	_points = _map.find(global_position, _core.global_position)
	_debug_line.points = _points
	_spawner_sprite.region_rect.position.x = FRAME_SIZE * randi() % 2
	_spawn_timer.wait_time = 1 / _current_spawn_rate


func _spawn_next() -> void:
	var enemy = _enemy_scene.instance()
	enemy.global_position = global_position
	enemy.setup(_points)
	enemy.connect("unit_killed", self, "_enemy_unit_killed")
	enemy.connect("core_attacked", self, "_enemy_core_damaged")
	get_parent().add_child(enemy)


func _enemy_unit_killed(_unit, coord) -> void:
	_map.increase_cost(coord)
	_current_deaths += 1
	
	if _current_deaths % DEATHS_BEFORE_REPATH == 0:
		_points = _map.find(global_position, _core.global_position)
		_debug_line.points = _points
	
	if _current_deaths % DEATHS_BEFORE_UPGRADE == 0:
		_current_spawn_rate = clamp(_current_spawn_rate + 0.1, 0.0, MAX_SPAWN_RATE)
		_spawn_timer.wait_time = 1 / _current_spawn_rate


func _enemy_core_damaged(unit, damage):
	emit_signal("core_damaged", unit, damage)


func _on_SpawnTimer_timeout() -> void:
	_spawn_next()
