extends PathFollow3D

@export var speed : float = 5.0

func _process(delta: float) -> void:
	progress += delta * speed
