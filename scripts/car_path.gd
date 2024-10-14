extends Path3D

@export var car : PackedScene

func _ready() -> void:
	var new_car = car.instantiate()
	add_child(new_car)
	await get_tree().create_timer(15).timeout
	var second_car = car.instantiate()
	add_child(second_car)
