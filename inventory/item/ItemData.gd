extends Resource
class_name ItemData

@export var name: String = ""
@export_multiline var description: String = ""
@export var texture: Texture2D
@export var can_stack: bool = false

func use(_target) -> void:
	pass
