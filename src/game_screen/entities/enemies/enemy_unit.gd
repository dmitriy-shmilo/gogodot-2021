extends KinematicBody2D
class_name EnemyUnit

const VARIANT_DISTRIBUTION = [
	
	# easy worms
	preload("res://game_screen/entities/enemies/enemy_variant0.tres"),
	preload("res://game_screen/entities/enemies/enemy_variant0.tres"),
	preload("res://game_screen/entities/enemies/enemy_variant0.tres"),
	preload("res://game_screen/entities/enemies/enemy_variant0.tres"),
	preload("res://game_screen/entities/enemies/enemy_variant0.tres"),

	# spiders
	preload("res://game_screen/entities/enemies/enemy_variant1.tres"),
	
	# easy roaches
	preload("res://game_screen/entities/enemies/enemy_variant2.tres"),
	preload("res://game_screen/entities/enemies/enemy_variant2.tres"),
	preload("res://game_screen/entities/enemies/enemy_variant2.tres"),
	preload("res://game_screen/entities/enemies/enemy_variant2.tres"),
	preload("res://game_screen/entities/enemies/enemy_variant2.tres"),
	preload("res://game_screen/entities/enemies/enemy_variant2.tres"),
	
	# stickbugs
	preload("res://game_screen/entities/enemies/enemy_variant3.tres"),
	preload("res://game_screen/entities/enemies/enemy_variant3.tres"),
	preload("res://game_screen/entities/enemies/enemy_variant3.tres"),
	
	# stinkbugs
	preload("res://game_screen/entities/enemies/enemy_variant4.tres"),
]

enum EnemyState {
	IDLE,
	MOVING,
	AGGRAVATED,
	ATTACKING,
	DEAD
}

signal unit_killed(source, coord)

onready var _enemy_shape: CollisionShape2D = $"EnemyShape"
onready var _animated_sprite: AnimatedSprite = $"AnimatedSprite"

var _variant: EnemyUnitVariant = VARIANT_DISTRIBUTION[0]
var _velocity = Vector2.ZERO
var _distance_threshold = 5
var _target_point_index = 0
var _total_points = 0
var _points: PoolVector2Array = PoolVector2Array()
var _state = EnemyState.IDLE
var _current_threat = null
var _current_hitpoints = 1

func _ready() -> void:
	_variant = VARIANT_DISTRIBUTION[randi() % VARIANT_DISTRIBUTION.size()]
	_animated_sprite.play("creep" + str(_variant.sprite_index))
	_current_hitpoints = _variant.max_hitpoints

func is_threat() -> bool:
	return _state != EnemyState.DEAD


# source should be PlayerTower, but then it causes cyclic dependency
func receive_damage(source: Node, amount: float) -> void:
	_current_hitpoints -= amount
	if _current_hitpoints <= 0:
		_move_to_state(EnemyState.DEAD)


func setup(points) -> void:
	_points = points
	_total_points = _points.size()


func _physics_process(_delta: float) -> void:
	match _state:
		EnemyState.MOVING:
			_waypoint_move()
		EnemyState.AGGRAVATED:
			_threat_move()
		EnemyState.IDLE:
			_move_to_state(EnemyState.MOVING)


func _threat_move() -> void:
	if _move_towards(_current_threat.global_position):
		_move_to_state(EnemyState.ATTACKING)


func _waypoint_move() -> void:
	if _total_points == 0:
		return
	
	if not _move_towards(_points[_target_point_index]):
		return
	
	_target_point_index = _target_point_index + 1
	if  _target_point_index == _total_points - 1:
		_move_to_state(EnemyState.DEAD)


func _move_towards(target) -> bool:
	if position.distance_to(target) < _distance_threshold:
		return true

	_velocity = (target - position).normalized() * _variant.move_speed
	_velocity = move_and_slide(_velocity)
	look_at(target)
	return false


func _can_move_to_state(state: int) -> bool:
	match state:
		EnemyState.IDLE:
			return false
		EnemyState.MOVING:
			return _state == EnemyState.AGGRAVATED \
				or _state == EnemyState.ATTACKING \
				or _state == EnemyState.IDLE
		EnemyState.AGGRAVATED:
			return false
		EnemyState.ATTACKING:
			return _state == EnemyState.MOVING \
				or _state == EnemyState.AGGRAVATED \
				or _state == EnemyState.IDLE
		EnemyState.DEAD:
			return _state != EnemyState.DEAD
		_:
			printerr("Unknown state %d", state)
			return false


func _move_to_state(state: int) -> void:
	if _can_move_to_state(state):
		_state = state

	match state:
		EnemyState.DEAD:
			_enemy_shape.call_deferred("set_disabled", true)
			call_deferred("queue_free")
			emit_signal("unit_killed", self, _points[_target_point_index])
		_:
			_enemy_shape.call_deferred("set_disabled", false)


func _describe_state() -> String:
	return EnemyState.keys()[_state]