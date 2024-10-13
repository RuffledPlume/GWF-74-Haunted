extends Path3D

@export var car : PackedScene

func _ready() -> void:
	var new_car = car.instantiate()
	add_child(new_car)
