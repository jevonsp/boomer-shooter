extends Marker3D
const PISTOL = preload("res://weapons/weapons/M1911.tscn")
const RIFLE = preload("res://weapons/weapons/M4A1.tscn")
const SMG = preload("res://weapons/weapons/MP5.tscn")
@onready var canvas_layer: CanvasLayer = $"../../CanvasLayer"

var current_gun_equipped: BaseWeapon
var primary_weapon: BaseWeapon
var secondary_weapon: BaseWeapon

func setup_weapons():
	primary_weapon = create_weapon(SMG)
	secondary_weapon = create_weapon(PISTOL)
	connect_weapon(primary_weapon)
	connect_weapon(secondary_weapon)
	secondary_weapon.is_enabled = false
	current_gun_equipped = primary_weapon

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

func switch_weapons():
	current_gun_equipped.is_enabled = false
	
	if current_gun_equipped == primary_weapon:
		current_gun_equipped = secondary_weapon
	else:
		current_gun_equipped = primary_weapon
		
	current_gun_equipped.is_enabled = true
	print("current=%s" % [current_gun_equipped.name])

func switch_weapon_to(index: int):
	current_gun_equipped.is_enabled = false
	match index:
		1: current_gun_equipped = primary_weapon
		2: current_gun_equipped = secondary_weapon
	current_gun_equipped.is_enabled = true
	print("current=%s" % [current_gun_equipped.name])

func replace_weapon(weapon_index: int, scene):
	current_gun_equipped.is_enabled = false
	match weapon_index:
		1:
			remove(primary_weapon)
			primary_weapon = create_weapon(scene)
			connect_weapon(primary_weapon)
			current_gun_equipped = primary_weapon
		2:
			remove(secondary_weapon)
			secondary_weapon = create_weapon(scene)
			connect_weapon(secondary_weapon)
			current_gun_equipped = secondary_weapon
			
	current_gun_equipped.is_enabled = true
			
func remove(weapon: BaseWeapon):
	weapon.queue_free()
