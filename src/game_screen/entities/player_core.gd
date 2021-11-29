extends Node2D
class_name PlayerCore

const FRAME_SIZE = 150
const TOTAL_FRAMES = 4

export(float) var total_hitpoints = 100

var current_hitpoints = total_hitpoints setget set_hitpoints

onready var _core_sprite: Sprite = $"CoreSprite"

func set_hitpoints(value: float) -> void:
	value = clamp(value, 0, total_hitpoints)
	var frame = TOTAL_FRAMES - floor(value * TOTAL_FRAMES / total_hitpoints) - 1
	_core_sprite.region_rect.position.x = FRAME_SIZE * frame
	current_hitpoints = value
	
