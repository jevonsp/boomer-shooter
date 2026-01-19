extends Marker3D
const PISTOL = preload("res://weapons/M1911.tscn")
@onready var canvas_layer: CanvasLayer = $"../../CanvasLayer"

var current_gun_equipped: BaseWeapon
var primary_weapon: BaseWeapon
var secondary_weapon: BaseWeapon

func setup_weapons():
	current_gun_equipped = create_weapon(PISTOL)
	connect_weapon(current_gun_equipped)

func create_weapon(scene) -> Node3D:
	var weapon = scene.instantiate()
	weapon.is_enabled = true
	add_child(weapon)
	return weapon

func connect_weapon(weapon: BaseWeapon):
	if not weapon.show_hitmarker.is_connected(canvas_layer.show_hitmarker):
		weapon.show_hitmarker.connect(canvas_layer.show_hitmarker)
	if not weapon.show_reload.is_connected(canvas_layer.show_reload):
		weapon.show_reload.connect(canvas_layer.show_reload)
