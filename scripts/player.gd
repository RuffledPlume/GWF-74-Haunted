class_name Player extends CharacterBody3D

@export var _camera : Camera3D
@export var _base_speed : float = 20.0
@export var _run_mod : float = 1.75
@export var _jump_force : float = 7.0
@export var _ground_friction : float = 5.0
@export var _air_drag : float = 1.5
@export var _min_step_height := 0.15
@export var _max_step_height := 0.3

var _mouse_relative : Vector2
var _gravity : Vector3
var _gravity_strength : float
var _surface_point : Vector3
var _surface_normal : Vector3

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
	if is_on_floor():
		_do_surface_normalization()
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
	
func debug_draw_raycast(params: PhysicsRayQueryParameters3D, result: Dictionary) -> void:
	if result.is_empty():
		DebugDraw3D.draw_line(params.from, params.to, Color.RED)
	else:
		DebugDraw3D.draw_line(params.from, result.position, Color.GREEN)
	
func _do_surface_normalization() -> void:
	var height_offset := 0.5
	
	var ray_count := 8
	var hit_count := 0
	
	var ray_orgin = global_position + Vector3.UP * height_offset
	var ray_target = global_position + Vector3.DOWN * (height_offset * 1.25)
	
	var space_state = get_world_3d().direct_space_state
	var ray_params := PhysicsRayQueryParameters3D.create(ray_orgin, ray_target)
	var result := space_state.intersect_ray(ray_params)
	
	var forward := global_basis.z
	
	var closest_hit_point : Vector3
	var closest_hit_normal : Vector3
	var closest_hit_dot : float = 1.0
	
	if !result.is_empty():
		hit_count += 1
		_surface_point += result.position
		_surface_normal += result.normal
				
	for i in ray_count:
		var frac := float(i) / float(ray_count)
		var offset := Vector3(cos(frac * PI * 2.0), 0.0, sin(frac * PI * 2.0)) * 0.5
		
		ray_params = PhysicsRayQueryParameters3D.create(ray_orgin + offset, ray_target + offset)
		result = space_state.intersect_ray(ray_params)
		
		debug_draw_raycast(ray_params, result)
		if !result.is_empty():
			hit_count += 1
			_surface_point += result.position
			_surface_normal += result.normal
			
			var offset_dot := offset.normalized().dot(forward)
			if offset_dot < closest_hit_dot:
				closest_hit_dot = offset_dot
				closest_hit_point = result.position
				closest_hit_normal = result.normal
			
			
	if hit_count > 0:
		_surface_point /= float(hit_count)
		_surface_normal = (_surface_normal / float(hit_count)).normalized()
		
		if closest_hit_dot < -0.95 && closest_hit_normal.dot(Vector3.UP) > 0.9:
			var height_diff := closest_hit_point.y - global_position.y
			if height_diff > _min_step_height && height_diff < _max_step_height:
				if _get_input().y < 0.0:
					global_position.y = closest_hit_point.y
	else:
		_surface_point = global_position
		_surface_normal = Vector3.UP
	
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
		input_3d = input_3d.slide(_surface_normal)
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
