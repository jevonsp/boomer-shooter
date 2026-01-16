extends MeshInstance3D
const RAY_LENGTH = 1000.0
const BULLET = preload("res://weapons/bullet.tscn")
var is_enabled: bool = true
@onready var point: Node3D = $Point
func _input(event):
	if not is_enabled:
		return
	if event is InputEventMouseButton and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED and event.is_pressed():
		match event.button_index:
			2: 
				fire()
				
func fire():
	if not is_enabled:
		return
	var bullet:CharacterBody3D = BULLET.instantiate()
	bullet.position = point.global_position
	bullet.transform.basis = point.global_transform.basis
	var root = get_tree().root
	root.add_child(bullet)
