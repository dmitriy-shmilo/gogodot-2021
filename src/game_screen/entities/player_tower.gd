extends Node2D
class_name PlayerTower

enum TowerState {
	INACTIVE,
	IDLE,
	ATTACKING,
	DEAD
}

signal activity_changed(source, is_active)

export(float) var damage = 40
export(float) var attack_rate = 1
export(float) var energy = 20

onready var _tower_container: Node2D = $"TowerContainer"
onready var _range_area: Area2D = $"RangeArea"
onready var _range_shape: CollisionShape2D = $"RangeArea/RangeShape"

var _target: EnemyUnit = null
var _state = TowerState.INACTIVE

func _ready() -> void:
	pass


func _physics_process(delta: float) -> void:
	match _state:
		TowerState.INACTIVE, TowerState.DEAD:
			return
		TowerState.IDLE:
			if _target != null and _target.is_threat():
				_move_to_state(TowerState.ATTACKING)
			else:
				_target = null
		TowerState.ATTACKING:
			# play animation?
			if _target == null or not _target.is_threat():
				_retarget()
			else:
				_tower_container.look_at(_target.global_position)
				_target.receive_damage(self, damage * delta)


func _retarget() -> void:
	match _state:
		TowerState.DEAD, TowerState.INACTIVE:
			return

	var bodies = _range_area.get_overlapping_bodies()
	var new_target = null
	for body in bodies:
		if _can_target(body):
			new_target = body
			break

	_attack(new_target)


func _can_target(body: Node) -> bool:
	return body is EnemyUnit and body.is_threat()


func _attack(enemy: EnemyUnit) -> void:
	_target = enemy
	_move_to_state(TowerState.IDLE if enemy == null else TowerState.ATTACKING)

func _toggle_active() -> void:
	match _state:
		TowerState.INACTIVE:
			_move_to_state(TowerState.IDLE)
		_:
			_move_to_state(TowerState.INACTIVE)


func _can_move_to_state(state: int) -> bool:
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
			return false


func _move_to_state(state: int) -> void:
	var old_state = _state
	if not _can_move_to_state(state):
		return
	
	_state = state
	
	match state:
		TowerState.INACTIVE, TowerState.DEAD:
			_range_shape.call_deferred("set_disabled", true)
			emit_signal("activity_changed", self, false)
		TowerState.IDLE:
			_range_shape.call_deferred("set_disabled", false)
			if old_state == TowerState.INACTIVE:
				emit_signal("activity_changed", self, true)


func _describe_state() -> String:
	return TowerState.keys()[_state]


func _on_RangeArea_body_entered(body: Node) -> void:
	if _target == null and _can_target(body):
		_attack(body)


func _on_RangeArea_body_exited(body: Node) -> void:
	if body == _target:
		_retarget()


func _on_ClickArea_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton \
		and event.button_index == BUTTON_LEFT \
		and event.pressed:
			_toggle_active()
