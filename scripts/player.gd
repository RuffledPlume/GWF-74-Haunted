class_name Player extends CharacterBody3D

@export var _camera : Camera3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _process(delta: float) -> void:
	_do_locomotion(delta)
	_do_camera_look(delta)
	
func _do_locomotion(delta: float) -> void:
	pass
	
func _do_camera_look(delta: float) -> void:
	pass
