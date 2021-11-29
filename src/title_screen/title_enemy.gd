extends KinematicBody2D
class_name TitleEnemy


onready var _animated_sprite: AnimatedSprite = $"AnimatedSprite"

var _variant: EnemyUnitVariant = EnemyUnit.VARIANT_DISTRIBUTION[0]
var _velocity = Vector2.ZERO
var _distance_threshold = 5
var _target_point_index = 0
var _total_points = 0
var _points: PoolVector2Array = PoolVector2Array()


func _ready() -> void:
	_variant = EnemyUnit.VARIANT_DISTRIBUTION[randi() % EnemyUnit.VARIANT_DISTRIBUTION.size()]
	_animated_sprite.play("creep" + str(_variant.sprite_index))


func setup(points) -> void:
	_points = points
	_total_points = _points.size()


func _physics_process(_delta: float) -> void:
	if _total_points == 0:
		return
	
	if not _move_towards(_points[_target_point_index]):
		return
	
	_target_point_index = _target_point_index + 1
	if _target_point_index == _total_points:
		call_deferred("queue_free")


func _move_towards(target) -> bool:
	if position.distance_to(target) < _distance_threshold:
		return true

	_velocity = (target - position).normalized() * _variant.move_speed
	_velocity = move_and_slide(_velocity)
	look_at(target)
	return false
