extends CharacterBody3D
const SPEED = 30
var direction: Vector3
var timer: float = 0.0
var size: float = .1:
	set(value):
		mesh_instance_3d.mesh.radius = value
		mesh_instance_3d.mesh.height = value * 2
var damage: int = 1
@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D
func _process(delta: float) -> void:
	timer += delta
	position += transform.basis * Vector3(-SPEED, 0, 0) * delta
	if timer >= 20:
		queue_free()
