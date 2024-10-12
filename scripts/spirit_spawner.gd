class_name SpiritSpawner extends Node

@export var possible_paths : Array[Path3D]
@export var spirit_prefab : PackedScene

var _spawn_cooldown : float = 2.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_spawn_cooldown -= delta
	if _spawn_cooldown > 0.0:
		return
	_spawn_cooldown = 2.0
		
	var newSpirit := spirit_prefab.instantiate() as Spirit
	newSpirit.set_path(possible_paths.pick_random())
	get_parent().add_child(newSpirit)
