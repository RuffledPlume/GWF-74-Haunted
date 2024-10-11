class_name Player extends CharacterBody3D

@export var _camera : Camera3D
@export var _base_speed : float = 20.0
@export var _run_mod : float = 1.75
@export var _jump_force : float = 7.0
@export var _ground_friction : float = 5.0
@export var _air_drag : float = 1.5

var _mouse_relative : Vector2
var _gravity : Vector3
var _gravity_strength : float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_gravity = ProjectSettings.get_setting("physics/3d/default_gravity_vector")
	_gravity *= ProjectSettings.get_setting("physics/3d/default_gravity")
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_mouse_relative = event.relative
		
func _process(delta: float) -> void:
	_do_camera_look(delta)
	
func _physics_process(delta: float) -> void:
	_do_locomotion(delta)
	
func _get_input() -> Vector2:
	var input : Vector2
	
	if Input.is_action_pressed("Movement_Left"):
		input.x = -1.0
	elif Input.is_action_pressed("Movement_Right"):
		input.x = 1.0
	
	if Input.is_action_pressed("Movement_Forward"):
		input.y = -1.0
	elif Input.is_action_pressed("Movement_Backwards"):
		input.y = 1.0
	
	return input
	
func _do_locomotion(delta: float) -> void:
	var input := _get_input()
	var input_3d := (global_transform.basis * Vector3(input.x, 0.0, input.y)).normalized()
	var is_grounded := is_on_floor()
	var is_running := Input.is_action_pressed("Movement_Run")
	
	var new_velocity := velocity
	new_velocity += _gravity * delta
	
	if is_grounded:
		var speed := _base_speed
		if is_running:
			speed *= _run_mod
		new_velocity += input_3d * (speed * delta)
		if Input.is_action_just_pressed("Movement_Jump"):
			if is_running:
				# Whilst running, add additional horizontal movement
				new_velocity += Vector3.UP * _jump_force
				new_velocity.x *= 2.0
				new_velocity.z *= 2.0
			else:
				# Whilst not running, jump a little bit higher
				new_velocity += Vector3.UP * (_jump_force + (_jump_force * 0.5))
		new_velocity -= velocity * (delta * _ground_friction)
	else:
		new_velocity += input_3d * (_base_speed * delta * 0.2) # Allow a little bit of agency whilst jumping
		new_velocity -= velocity * (delta * _air_drag)
	
	velocity = new_velocity 
	move_and_slide()
	
	
func _do_camera_look(delta: float) -> void:
	# Make sure the mouse is locked into the game, before moving the camera
	if !GameManagerInstance.is_mouse_locked():
		return
	
	var _look_motion := -_mouse_relative * (GameManagerInstance._camera_look_sens * delta)
	
	# Rotate Player
	rotate_y(_look_motion.x)
	
	# Rotate Camera
	_camera.rotate_x(_look_motion.y)
	_camera.rotation.x = clamp(_camera.rotation.x, -1.2, 1.2)
	
	_mouse_relative = Vector2.ZERO
