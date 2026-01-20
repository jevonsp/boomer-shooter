extends Marker3D
signal reset_labels
const PISTOL = preload("res://weapons/weapons/M1911.tscn")
const RIFLE = preload("res://weapons/weapons/M4A1.tscn")
const SMG = preload("res://weapons/weapons/MP5.tscn")
@onready var canvas_layer: CanvasLayer = $"../../CanvasLayer"
var current_gun_equipped: BaseWeapon:
	set(value):
		current_gun_equipped = value
		current_gun_equipped.update_ammo.emit(
			current_gun_equipped.current_ammo_count,
			current_gun_equipped.max_ammo_count)
var primary_weapon: BaseWeapon
var secondary_weapon: BaseWeapon

func _ready() -> void:
	connect_signals()
	
func connect_signals():
	reset_labels.connect(canvas_layer.reset_labels)

func setup_weapons():
	primary_weapon = create_weapon(SMG)
	secondary_weapon = create_weapon(PISTOL)
	secondary_weapon.is_enabled = false
	current_gun_equipped = primary_weapon

func create_weapon(scene) -> Node3D:
	var weapon = scene.instantiate()
	weapon.is_enabled = true
	connect_weapon(weapon)
	add_child(weapon)
	return weapon

func connect_weapon(weapon: BaseWeapon):
	if not weapon.show_hitmarker.is_connected(canvas_layer.show_hitmarker):
		weapon.show_hitmarker.connect(canvas_layer.show_hitmarker)
	if not weapon.show_reload.is_connected(canvas_layer.show_reload):
		weapon.show_reload.connect(canvas_layer.show_reload)
	if not weapon.update_ammo.is_connected(canvas_layer.update_ammo):
		weapon.update_ammo.connect(canvas_layer.update_ammo)

func switch_weapons():
	if current_gun_equipped == primary_weapon:
		switch_weapon_to(2)
	else:
		switch_weapon_to(1)

func switch_weapon_to(index: int):
	reset_labels.emit()
	current_gun_equipped.is_enabled = false
	match index:
		1: current_gun_equipped = primary_weapon
		2: current_gun_equipped = secondary_weapon
	current_gun_equipped.is_enabled = true
	print("current=%s" % [current_gun_equipped.name])
	if not current_gun_equipped.has_ammo:
		current_gun_equipped.show_reload.emit(true)

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
