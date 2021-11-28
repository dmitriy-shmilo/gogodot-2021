extends Node2D
class_name EnemySpawner

signal core_damaged(source, damage)

var _map: TileMapMesh
var _core: PlayerCore
var _points: PoolVector2Array
var _enemy_scene = preload("res://game_screen/entities/enemies/enemy_unit.tscn")

onready var _debug_line = $"Node/DebugLine"

func setup(map, core) -> void:
	_map = map
	_core = core
	_points = _map.find(global_position, _core.global_position)
	_debug_line.points = _points


func spawn_next() -> void:
	var enemy = _enemy_scene.instance()
	enemy.global_position = global_position
	enemy.setup(_points)
	enemy.connect("unit_killed", self, "_enemy_unit_killed")
	enemy.connect("core_attacked", self, "_enemy_core_damaged")
	get_parent().add_child(enemy)


func _enemy_unit_killed(_unit, coord) -> void:
	_map.increase_cost(coord)
	_points = _map.find(global_position, _core.global_position)
	_debug_line.points = _points


func _enemy_core_damaged(unit, damage):
	emit_signal("core_damaged", unit, damage)
