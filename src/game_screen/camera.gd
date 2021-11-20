extends KinematicBody2D

export(float) var speed = 200
export(float) var friction = 0.1
export(float) var acceleration = 0.3

var _velocity: Vector2 = Vector2.ZERO

func _ready() -> void:
	pass


func get_input():
	var input = Vector2()
	if Input.is_action_pressed("right"):
		input.x += 1
	if Input.is_action_pressed("left"):
		input.x -= 1
	if Input.is_action_pressed("down"):
		input.y += 1
	if Input.is_action_pressed("up"):
		input.y -= 1
	return input


func _physics_process(_delta) -> void:
	var direction = get_input()
	if direction.length() > 0:
		_velocity = lerp(_velocity, direction.normalized() * speed, acceleration)
	else:
		_velocity = lerp(_velocity, Vector2.ZERO, friction)
	_velocity = move_and_slide(_velocity)
