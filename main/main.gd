extends Node
@onready var player: CharacterBody3D = $Player
@onready var enemy: Node3D = $Enemy

func _ready() -> void:
	get_window().grab_focus()
