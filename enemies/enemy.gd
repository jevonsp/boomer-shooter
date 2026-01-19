extends Node3D
const SPEED = 2.0
var hitpoints: int = 5

func _process(delta: float) -> void:
	move_to_player(delta)
	
func take_damage(amount) -> void:
	print("hit=%s" % [amount])
	hitpoints -= amount
	if hitpoints <= 0:
		die()

func die() -> void:
	queue_free()

func move_to_player(delta: float):
	var player_pos = PlayerManager.get_global_position()
	var dir = (player_pos - global_position).normalized()
	var movement = dir * SPEED * delta
	global_position += movement
	look_at(player_pos, Vector3.UP)
