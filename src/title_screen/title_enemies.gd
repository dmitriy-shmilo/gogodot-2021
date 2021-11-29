extends Node2D


onready var _enemy_path = $"EnemyPath"
var _enemy_scene = preload("res://title_screen/title_enemy.tscn")


func _on_Timer_timeout() -> void:
	var enemy = _enemy_scene.instance()
	enemy.global_position = _enemy_path.points[0]
	enemy.setup(_enemy_path.points)
	add_child(enemy)
