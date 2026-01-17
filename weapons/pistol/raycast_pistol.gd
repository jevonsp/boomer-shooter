extends Weapon
const BULLET_TRACER = preload("res://weapons/bullet_tracer.tscn")
var camera: Camera3D
var line_mesh: MeshInstance3D
var immediate_mesh: ImmediateMesh
@onready var player: CharacterBody3D = PlayerManager.player
@onready var muzzle: Marker3D = $Marker3D
@onready var muzzle_flash: GPUParticles3D = $Marker3D/MuzzleFlash
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
	var from = muzzle.global_position
	var to
	if collision:
		if collision.collider.is_in_group("enemy"):
			print("hit enemy")
		else:
			print(collision.collider.name)
		to = collision.position
	else:
		to = camera.global_position - camera.global_transform.basis.z * 100
	make_bullet_trail(from, to)
	activate_muzzle_flash()
	
func activate_muzzle_flash():
	muzzle_flash.emitting = true
	
func make_bullet_trail(from: Vector3, to: Vector3):
	var bullet_dir = (to - muzzle.global_position).normalized()
	var start_pos = from + bullet_dir*0.25
	if (from - to).length() > 0.5:
		var bullet_tracer: Node3D = BULLET_TRACER.instantiate()
		player.add_sibling(bullet_tracer)
		bullet_tracer.global_position = start_pos
		bullet_tracer.rotation = muzzle.global_rotation
		bullet_tracer.target_pos = to
		
