class_name Spirit extends Node3D

@export var base_speed : float = 0.25

var _current_path : Path3D
var _path_length : float
var _path_alpha : float

func set_path(new_path : Path3D) -> void:
	_current_path = new_path
	_path_length = new_path.curve.get_baked_length()
	_path_alpha = 0.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if _current_path == null:
		queue_free()
		return
	
	var path_position = _current_path.curve.samplef(_path_alpha * _current_path.curve.point_count)
	global_position = _current_path.to_global(path_position)
	
	_path_alpha += base_speed * delta
	
	if _path_alpha >= 1.0:
		queue_free()
