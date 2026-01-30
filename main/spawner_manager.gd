extends Node
@export var spawner: PackedScene
@export var path: PackedScene
var spawn_path_pairs: Dictionary = {}

func _ready() -> void:
	create_spawner_path_pair(spawner, path)

func _process(delta: float) -> void:
	for p: Path3D in spawn_path_pairs:
		p.path_follow_3d.progress_ratio = (
			p.path_follow_3d.progress_ratio + (delta / 100.0))
		print(p.path_follow_3d.progress_ratio)

func create_spawner_path_pair(s, p):
	var new_path: Path3D = p.instantiate()
	add_child(new_path)
	new_path.global_position = Vector3(-8.5, 4.5, 8)
	new_path.path_follow_3d.progress = randf()
	var new_spawner = s.instantiate()
	new_path.path_follow_3d.add_child(new_spawner)
	spawn_path_pairs[new_path] = new_spawner
