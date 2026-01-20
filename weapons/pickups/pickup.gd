extends StaticBody3D

@export_enum("WEAPON", "ITEM") var type = "WEAPON"
@export var weapon_index: int = 1
@export_subgroup("Content")
@export var scene: PackedScene
@export var texture: Texture2D
@onready var player = PlayerManager.player

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body == player:
		body.weapon_manager.replace_weapon(weapon_index, scene)
