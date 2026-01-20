extends Node
@onready var player: CharacterBody3D = $Player

func _ready() -> void:
	get_window().grab_focus()
