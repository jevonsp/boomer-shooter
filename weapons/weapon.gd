extends Node3D
class_name Weapon
@export var BULLET: PackedScene
@export var is_automatic: bool = false
@export var shot_time: float = .3
var is_enabled: bool = true
var timer: float = 0.0
@onready var point: Node3D = $Point

func _process(delta: float) -> void:
	if is_automatic and \
			Input.mouse_mode == Input.MOUSE_MODE_CAPTURED and \
			Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		timer += delta
		if timer >= shot_time:
			fire()
			timer = 0.0

func _input(event):
	if not is_enabled:
		return
	if is_automatic:
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
