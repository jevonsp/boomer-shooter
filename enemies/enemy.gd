extends Node3D

var hitpoints: int = 5

func take_damage(amount) -> void:
	print("hit=%s" % [amount])
	hitpoints -= amount
	if hitpoints <= 0:
		die()

func die() -> void:
	queue_free()
