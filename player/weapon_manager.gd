extends Marker3D

const PISTOL = preload("res://weapons/base_weapon.tscn")

func create_weapons():
	var pistol = PISTOL.instantiate()
	pistol.is_enabled = true
	add_child(pistol)
