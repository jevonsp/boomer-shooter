extends Node3D

@export var monster: PackedScene
@export var spawn_time: float = 1.0
var timer: float = 0.0
@onready var manager: Node = get_parent().get_parent().get_parent()
func _ready() -> void:
	spawn(monster)

func _process(delta: float) -> void:
	timer += delta
	if timer >= spawn_time:
		if monster:
			spawn(monster)
		timer = 0.0

func spawn(m: PackedScene):
	var new_monster: Node3D = m.instantiate()
	manager.add_child(new_monster)
	new_monster.global_position = global_position
