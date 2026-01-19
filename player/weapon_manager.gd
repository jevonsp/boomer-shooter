extends Marker3D

const PISTOL = preload("res://weapons/base_weapon.tscn")

var current_gun_equipped: BaseWeapon

func setup_weapons():
	current_gun_equipped = create_pistol()

func create_pistol():
	var pistol = PISTOL.instantiate()
	pistol.is_enabled = true
	add_child(pistol)
	return pistol
