extends Label


onready var _parent = $".."
var _is_str = false

func _ready() -> void:
	if not "_state" in _parent:
		_parent = null
	_is_str = _parent.has_method("_describe_state")


func _physics_process(_delta: float) -> void:
	if _parent != null:
		if _is_str:
			text = _parent._describe_state()
		else:
			text = str(_parent._state)
