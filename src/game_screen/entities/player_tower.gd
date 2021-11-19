extends Node2D

enum TowerState {
	INACTIVE,
	IDLE,
	ATTACKING,
	DEAD
}

export(float) var damage = 20
export(float) var attack_rate = 1

onready var _tower_container: Node2D = $"TowerContainer"
onready var _range_area: Area2D = $"RangeArea"
var _target: EnemyUnit = null
var _state = TowerState.INACTIVE

func _ready() -> void:
	pass


func _physics_process(_delta: float) -> void:
	match _state:
		TowerState.INACTIVE, TowerState.DEAD:
			return
		TowerState.IDLE:
			if _target != null:
				_move_to_state(TowerState.ATTACKING)
		TowerState.ATTACKING:
			# play animation?
			if _target != null:
				_tower_container.look_at(_target.global_position)


func _retarget():
	var bodies = _range_area.get_overlapping_bodies()
	if bodies.size() > 0:
		_target = bodies[0]
		_move_to_state(TowerState.ATTACKING)
	else:
		_target = null
		_move_to_state(TowerState.IDLE)

func _toggle_active():
	match _state:
		TowerState.INACTIVE:
			_move_to_state(TowerState.IDLE)
		_:
			_move_to_state(TowerState.INACTIVE)


func _can_move_to_state(state: int):
	match state:
		TowerState.IDLE:
			return _state == TowerState.ATTACKING \
				or _state == TowerState.INACTIVE
		TowerState.ATTACKING:
			return _state == TowerState.IDLE
		TowerState.INACTIVE:
			return _state == TowerState.IDLE \
				or _state == TowerState.ATTACKING
		TowerState.DEAD:
			return _state != TowerState.DEAD
		_:
			print("Unknown tower state %d", state)


func _move_to_state(state: int):
	if _can_move_to_state(state):
		_state = state


func _describe_state():
	return TowerState.keys()[_state]


func _on_RangeArea_body_entered(body: Node) -> void:
	if _target == null and body is EnemyUnit:
		_target = body
		_move_to_state(TowerState.ATTACKING)


func _on_RangeArea_body_exited(body: Node) -> void:
	if body == _target:
		_retarget()


func _on_ClickArea_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton \
		and event.button_index == BUTTON_LEFT \
		and event.pressed:
			_toggle_active()
