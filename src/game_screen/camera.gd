extends KinematicBody2D

export(float) var speed = 200
export(float) var friction = 0.1
export(float) var acceleration = 0.3

onready var _camera = $"Camera"

var _velocity: Vector2 = Vector2.ZERO
var _pan_dir: Vector2 = Vector2.ZERO

func _ready() -> void:
	pass


func _unhandled_input(event: InputEvent) -> void:

	if event is InputEventPanGesture:
		_pan_dir = event.get_delta() * 2
		return

	if event is InputEventMagnifyGesture:
		_camera.zoom.x *= event.get_factor()
		_camera.zoom.y = _camera.zoom.x
		return

	if event.is_action_pressed("zoom_in"):
		_camera.zoom.x -= 0.25
		_camera.zoom.y -= 0.25
		return

	if event.is_action_pressed("zoom_out"):
		_camera.zoom.x += 0.25
		_camera.zoom.y += 0.25
		return


func get_input():
	if _pan_dir != Vector2.ZERO:
		return _pan_dir

	var input = Vector2()
	if Input.is_action_pressed("right"):
		input.x += 1
	if Input.is_action_pressed("left"):
		input.x -= 1
	if Input.is_action_pressed("down"):
		input.y += 1
	if Input.is_action_pressed("up"):
		input.y -= 1

	return input.normalized()


func _physics_process(_delta) -> void:
	var direction = get_input()
	if direction.length() > 0:
		_velocity = lerp(_velocity, direction * speed, acceleration)
	else:
		_velocity = lerp(_velocity, Vector2.ZERO, friction)
	_velocity = move_and_slide(_velocity)
