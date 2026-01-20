extends CanvasLayer
@onready var hit_marker: TextureRect = $Control/HitMarker
@onready var reload_label: Label = $Control/ReloadLabel

func show_hitmarker():
	hit_marker.visible = true
	await get_tree().create_timer(0.1).timeout
	hit_marker.visible = false
	
func show_reload(value: bool):
	reload_label.visible = value

func reset_labels():
	reload_label.visible = false
