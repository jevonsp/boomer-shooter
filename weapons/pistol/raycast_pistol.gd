extends Weapon
var camera: Camera3D
var line_mesh: MeshInstance3D
var immediate_mesh: ImmediateMesh
@onready var marker_3d: Marker3D = $Marker3D

func _ready() -> void:
	line_mesh = MeshInstance3D.new()
	immediate_mesh = ImmediateMesh.new()
	line_mesh.mesh = immediate_mesh
	add_child(line_mesh)
	camera = PlayerManager.player.camera

func fire():
	if not is_enabled:
		return
	var space = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(
				camera.global_position,
				camera.global_position - camera.global_transform.basis.z * 100
	)
	query.collision_mask = (1 << 0) | (1 << 3)
	query.collide_with_areas = true
	var collision = space.intersect_ray(query)
	var from = marker_3d.global_position
	var to
	if collision:
		if collision.collider.is_in_group("enemy"):
			print("hit enemy")
		else:
			print(collision.collider.name)
		to = collision.position
	else:
		to = camera.global_position - camera.global_transform.basis.z * 100
