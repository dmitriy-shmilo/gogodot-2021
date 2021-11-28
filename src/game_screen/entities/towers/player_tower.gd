extends Node2D
class_name PlayerTower

const SHOT_STREAMS = [
	preload("res://assets/shot0.ogg"),
	preload("res://assets/shot1.ogg")
]

enum TowerState {
	INACTIVE,
	IDLE,
	ATTACKING,
	DEAD
}

signal activation_requested(source, active)

export(Resource) var variant = preload("res://game_screen/entities/towers/tower_variant0.tres")
export(Color) var range_color = Color.cornflower

onready var _tower_container: Node2D = $"TowerContainer"
onready var _range_area: Area2D = $"RangeArea"
onready var _range_shape: CollisionShape2D = $"RangeArea/RangeShape"
onready var _attack_timer: Timer = $"AttackTimer"
onready var _base_sprite: Sprite = $"BaseSprite"
onready var _tower_sprite: Sprite = $"TowerContainer/TowerSprite"
onready var _power_indicator: AnimatedSprite = $"PowerIndicator"
onready var _shot_animation: AnimatedSprite = $"TowerContainer/ShotAnimation"
onready var _shot_player: AudioStreamPlayer2D = $"ShotPlayer"

var _target: EnemyUnit = null
var _bullet_loaded = true
var _state = TowerState.INACTIVE
var _is_hovered_over = false

func _ready() -> void:
	var sprite_index = variant.sprite_index
	_base_sprite.region_rect.position.y = sprite_index * 64
	_tower_sprite.region_rect.position.y = sprite_index * 64
	_shot_animation.animation = "shot" + str(sprite_index)
	# TODO: for some reason animation has to 
	# play at least once before it's displayed
	_shot_animation.play()
	_shot_player.stream = SHOT_STREAMS[sprite_index]
	_attack_timer.wait_time = 1.0 / variant.attack_rate
	(_range_shape.shape as CircleShape2D).radius = variant.attack_range
	toggle_active(false)


func _draw() -> void:
	if _is_hovered_over:
		draw_circle(Vector2.ZERO, variant.attack_range, range_color)


func _physics_process(delta: float) -> void:
	match _state:
		TowerState.INACTIVE, TowerState.DEAD:
			return
		TowerState.IDLE:
			# TODO: get rid of is_instance_valid call
			if _target != null \
				and is_instance_valid(_target) \
				and _target.is_threat():
				_move_to_state(TowerState.ATTACKING)
			else:
				_target = null
		TowerState.ATTACKING:

			if _target == null or not _target.is_threat():
				_retarget()
			else:
				_tower_container.look_at(_target.global_position)
				
				if not _bullet_loaded:
					# wait for reload
					return

				_bullet_loaded = false
				_shot_animation.visible = true
				_shot_animation.play()
				if not _shot_player.playing:
					_shot_player.play()
				_target.receive_damage(self, variant.damage)
				_attack_timer.start()


func toggle_active(active: bool) -> void:
	if active:
		_tower_sprite.modulate = Color.white
		_base_sprite.modulate = Color.white
		_move_to_state(TowerState.IDLE)
		_power_indicator.visible = false
		return

	_power_indicator.visible = true
	_tower_sprite.modulate = Color(0.3, 0.3, 0.3)
	_base_sprite.modulate = Color(0.3, 0.3, 0.3)
	_move_to_state(TowerState.INACTIVE)


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
		TowerState.ATTACKING:
			if _attack_timer.is_stopped():
				_attack_timer.start()
		TowerState.INACTIVE, TowerState.DEAD:
			_range_shape.call_deferred("set_disabled", true)
		TowerState.IDLE:
			_range_shape.call_deferred("set_disabled", false)


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
			emit_signal("activation_requested", self, _state == TowerState.INACTIVE)


func _on_ClickArea_mouse_entered() -> void:
	_is_hovered_over = true
	update()


func _on_ClickArea_mouse_exited() -> void:
	_is_hovered_over = false
	update()


func _on_AttackTimer_timeout() -> void:
	_bullet_loaded = true


func _on_ShotAnimation_animation_finished() -> void:
	if not _bullet_loaded or _state != TowerState.ATTACKING:
		_shot_animation.stop()
		_shot_animation.frame = 0
		_shot_animation.visible = false


func _on_ShotPlayer_finished() -> void:
	pass
