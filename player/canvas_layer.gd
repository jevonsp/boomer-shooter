extends CanvasLayer
@onready var hit_marker: TextureRect = $Control/HitMarker
@onready var reload_label: Label = $Control/ReloadLabel
@onready var ammo_quantity_label: Label = $Control/AmmoHBox/QuantityLabel
@onready var health_quantity_label: Label = $Control/HealthHBox/QuantityLabel

func show_hitmarker():
	hit_marker.visible = true
	await get_tree().create_timer(0.1).timeout
	hit_marker.visible = false
	
func show_reload(value: bool):
	reload_label.visible = value

func reset_labels():
	reload_label.visible = false

func update_ammo(current_ammo: int, max_ammo: int):
	ammo_quantity_label.text = "%s/%s" % [current_ammo, max_ammo]

func update_health(current_health: int, max_health: int):
	var percent_float = current_health / float(max_health)
	var percent = int(percent_float * 100)
	health_quantity_label.text = "%s%%" % [percent]
