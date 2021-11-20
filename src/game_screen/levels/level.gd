extends Node2D
class_name Level

onready var _core: Node2D = $"PlayerCore"

func _ready() -> void:
	pass


func get_start_position() -> Vector2:
	return _core.global_position
