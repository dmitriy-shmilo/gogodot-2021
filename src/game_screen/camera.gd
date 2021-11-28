extends KinematicBody2D

const HALF_RES_X = 640 / 2
const HALF_RES_Y = 360 / 2

export(float) var speed = 400
export(float) var friction = 0.15
export(float) var acceleration = 0.5

onready var _camera = $"Camera"

var _velocity: Vector2 = Vector2.ZERO
var _pan_dir: Vector2 = Vector2.ZERO

func _unhandled_input(event: InputEvent) -> void:

	if event is InputEventPanGesture:
		_pan_dir = event.get_delta() * 2
		return

	if event is InputEventMagnifyGesture:
		_zoom(_camera.zoom.x * event.get_factor())
		return

	if event.is_action_pressed("zoom_in"):
		_zoom(_camera.zoom.x - 0.25)
		return

	if event.is_action_pressed("zoom_out"):
		_zoom(_camera.zoom.x + 0.25)
		return


func get_input():
	
		
	if _pan_dir != Vector2.ZERO:
		return _pan_dir
	
	var mt_x = HALF_RES_X * 0.98 * _camera.zoom.x
	var mt_y = HALF_RES_Y * 0.98 * _camera.zoom.y
	var input = Vector2()
	var mouse_pos = get_local_mouse_position()

	if mouse_pos.x > mt_x or Input.is_action_pressed("right"):
		input.x += 1
	if mouse_pos.x < -mt_x or Input.is_action_pressed("left"):
		input.x -= 1
	if mouse_pos.y > mt_y or Input.is_action_pressed("down"):
		input.y += 1
	if mouse_pos.y < -mt_y or Input.is_action_pressed("up"):
		input.y -= 1

	input = input.normalized()
	
	if Input.is_key_pressed(KEY_SHIFT):
		input *= 1.5
	
	return input


func _physics_process(_delta) -> void:
	var direction = get_input()
	if direction.length() > 0:
		_velocity = lerp(_velocity, direction * speed, acceleration)
	else:
		_velocity = lerp(_velocity, Vector2.ZERO, friction)
	_velocity = move_and_slide(_velocity)


func _zoom(level: float) -> void:
	level = clamp(level, 0.5, 3.0)
	_camera.zoom.x = level
	_camera.zoom.y = level
