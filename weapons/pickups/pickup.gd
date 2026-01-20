extends StaticBody3D

@export_enum("WEAPON", "ITEM") var type = "WEAPON"
@export var weapon_index: int = 1
@export_subgroup("Content")
@export var scene: PackedScene
@export var texture: Texture2D
@onready var player = PlayerManager.player
@onready var sprite_3d: Sprite3D = $Sprite3D

func _process(delta: float) -> void:
	sprite_3d.rotate_y(delta / 4.0)

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body == player:
		body.weapon_manager.replace_weapon(weapon_index, scene)
