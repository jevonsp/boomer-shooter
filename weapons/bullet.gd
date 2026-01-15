extends CharacterBody3D
const SPEED = 50
var direction: Vector3
var timer: float = 0.0
func _process(delta: float) -> void:
	timer += delta
	position += transform.basis * Vector3(-SPEED, 0, 0) * delta
	if timer >= 20:
		queue_free()
