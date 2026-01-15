extends MeshInstance3D

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED and event.is_pressed():
		print(event)
