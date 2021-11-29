extends Node
class_name Gui

onready var _energy_bar: ProgressBar = $"CanvasLayer/EnergyBar"
onready var _health_bar: ProgressBar = $"CanvasLayer/HealthBar"
onready var _score_label: Label = $"CanvasLayer/ScoreLabel"
onready var _animation_player: AnimationPlayer = $"AnimationPlayer"

func set_energy(current, total) -> void:
	_energy_bar.max_value = total
	_energy_bar.value = current


func set_score(total, amount = 0) -> void:
	# TODO: float amount up
	_score_label.text = "x" + str(total)


func set_health(total, current):
	_health_bar.max_value = total
	_health_bar.value = current


func shake_energy_bar() -> void:
	if not _animation_player.is_playing():
		_animation_player.play("energy_bar_shake")


func foo():
	var target = _energy_bar.rect_position
	target.x += 50
	#_tween.interpolate_property(_energy_bar, "rect_position", _energy_bar.rect_position, target, 0.5, Tween.TRANS_BOUNCE, Tween.EASE_IN)
	#_tween.interpolate_property(_energy_bar, "rect_position", target, _energy_bar.rect_position, 0.5, Tween.TRANS_BOUNCE, Tween.EASE_IN, 0.5)
	#_tween.interpolate_method(self, "_tween_region_rect", _energy_bar.rect_position, target, 1.5, Tween.TRANS_EXPO, Tween.EASE_OUT, 0)
	#_tween.start()

func _tween_region_rect(pos):
	_energy_bar.rect_position = pos
