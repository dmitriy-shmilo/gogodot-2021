extends ProgressBar
class_name SmoothProgressBar


export(float) var smooth_value_duration = 0.25
var _tween: Tween

func _ready() -> void:
	_tween = Tween.new()
	add_child(_tween)


func set_value(target: float) -> void:
	_tween.stop_all()
	_tween.interpolate_property(self, "value", value, \
	 target, smooth_value_duration, \
	Tween.TRANS_BOUNCE, Tween.EASE_OUT)
	_tween.start()
