extends KinematicBody2D
class_name EnemyUnit

enum EnemyState {
	STATE_IDLE,
	STATE_MOVING,
	STATE_AGGRAVATED,
	STATE_ATTACKING,
	STATE_DEAD
}
onready var line: Line2D = $"../Line2D"

export(float) var move_speed = 100
export(float) var max_hitpoints = 100
export(float) var current_hitpoints = max_hitpoints

var _velocity = Vector2.ZERO
var _distance_threshold = 5
var _target_point_index = 0
var _total_points = 0
var _points: PoolVector2Array = PoolVector2Array()
var _state = EnemyState.STATE_IDLE

func _ready() -> void:
	_points = line.points
	_total_points = _points.size()
	

func _physics_process(delta: float) -> void:
	if _total_points == 0:
		return

	var target = _points[_target_point_index]
	
	if position.distance_to(target) < _distance_threshold:
		_target_point_index = (_target_point_index + 1) % _total_points
	
	_velocity = (target - position).normalized() * move_speed
	_velocity = move_and_slide(_velocity)
