class_name GameManager extends Node

 # TODO Make Settings page!
var _camera_look_sens : float = 0.75

# Internal Game Values
var _is_locked : bool

func is_mouse_locked() -> bool:
	return _is_locked && Input.mouse_mode == Input.MOUSE_MODE_CAPTURED

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_is_locked = true
	print("Input Mode is set to Captured")

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if !_is_locked:
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
				_is_locked = true
				print("Locking Mouse into game")
				
	if event is InputEventKey:
		if event.keycode == KEY_ESCAPE:
			if _is_locked:
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
				_is_locked = false
				print("Unlocking Mouse from game")
				

func _notification(what: int) -> void:
	if what == MainLoop.NOTIFICATION_APPLICATION_FOCUS_OUT:
		if _is_locked:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			_is_locked = false
			print("Unlocking Mouse from game")
