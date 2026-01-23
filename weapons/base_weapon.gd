extends Node3D
class_name BaseWeapon

signal show_hitmarker
signal show_reload(value: bool)
signal update_ammo(current_ammo: int, max_ammo: int)

const BULLET_TRACER = preload("res://weapons/weapon_assets/bullet_tracer.tscn")

@export var BULLET: PackedScene
@export var damage: int = 1
@export var max_ammo_count: int = 6
@export var reload_time: float = 1.0
@export var is_automatic: bool = false
@export var is_burst: bool = false
@export var burst_amount: int = 3
@export var shot_time: float = .1
@export var piercing_factor: int = 0
@export var bullet_size: float = 0.1
@export var ammo_consumption_per_shot: int = 1

var is_enabled: bool = false:
	set(value):
		is_enabled = value
		visible = is_enabled

var has_ammo: bool = true
var timer: float = 0.0
var was_firing: bool = false
var is_firing_burst: bool = false
var camera: Camera3D
var line_mesh: MeshInstance3D
var immediate_mesh: ImmediateMesh
var current_ammo_count: int
var is_reloading: bool = false


@onready var player: CharacterBody3D = PlayerManager.player
@onready var muzzle: Marker3D = $Marker3D
@onready var muzzle_flash: GPUParticles3D = $Marker3D/MuzzleFlash
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	line_mesh = MeshInstance3D.new()
	immediate_mesh = ImmediateMesh.new()
	line_mesh.mesh = immediate_mesh
	add_child(line_mesh)
	camera = PlayerManager.player.camera
	if not animation_player.animation_finished.is_connected(_on_animation_player_animation_finished):
		animation_player.animation_finished.connect(_on_animation_player_animation_finished)
	set_stats()

func _process(delta: float) -> void:
	var is_firing = is_automatic and \
		Input.mouse_mode == Input.MOUSE_MODE_CAPTURED and \
		Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT)

	if is_firing:
		if not was_firing:
			fire()
			timer = 0.0
		timer += delta
		if timer >= shot_time:
			fire()
			timer = 0.0

	was_firing = is_firing

func _input(event):
	if not is_enabled:
		return
	if is_automatic:
		return
	if event is InputEventMouseButton and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED and event.is_pressed():
		match event.button_index:
			2:
				fire()

func set_stats():
	current_ammo_count = max_ammo_count
	update_ammo.emit(current_ammo_count, max_ammo_count)

func fire():
	if not is_enabled:
		return
	if not has_ammo:
		return
	if is_reloading:
		return
	if is_firing_burst:
		return

	var from = PlayerManager.player.camera.global_position
	var to = camera.global_position - camera.global_transform.basis.z * 100

	var hit_positions = perform_piercing_raycast(from, to, piercing_factor)

	if is_burst:
		is_firing_burst = true
		consume_ammo()

		for i in range(burst_amount):
			if is_reloading:
				break

			if hit_positions.size() > 0:
				make_bullet_trail(muzzle.global_position, hit_positions[-1])
			else:
				make_bullet_trail(muzzle.global_position, to)

			activate_muzzle_flash()
			play_shoot_animation()

			if i < burst_amount - 1:
				await get_tree().create_timer(shot_time / 2.0).timeout

		is_firing_burst = false
	else:
		consume_ammo()

		make_bullet_trail(muzzle.global_position,
			hit_positions[-1] if hit_positions.size() > 0 else to)
		activate_muzzle_flash()
		play_shoot_animation()

func perform_piercing_raycast(from: Vector3, to: Vector3, max_pierces: int) -> Array[Vector3]:
	var space = get_world_3d().direct_space_state
	var ray_direction = (to - from).normalized()
	var remaining_range = (to - from).length()
	var current_from = from
	var hit_positions: Array[Vector3] = []
	var hit_bodies: Array[RID] = []

	for i in range(max_pierces + 1):
		var query = PhysicsRayQueryParameters3D.create(
			current_from,
			current_from + ray_direction * remaining_range
		)
		query.collision_mask = (1 << 0) | (1 << 3)
		query.collide_with_areas = true

		for body_rid in hit_bodies:
			query.exclude.append(body_rid)

		var collision = space.intersect_ray(query)
		if not collision:
			break

		var hit_distance = (collision.position - current_from).length()
		remaining_range -= hit_distance
		if remaining_range <= 0:
			break

		hit_positions.append(collision.position)
		hit_bodies.append(collision.collider.get_rid())

		if collision.collider.is_in_group("enemy"):
			var shape_owner = collision.collider.shape_find_owner(collision.shape)
			var shape_node = collision.collider.shape_owner_get_owner(shape_owner)

			var actual_damage = damage
			if shape_node.name == "Head":
				actual_damage *= 2

			var enemy = collision.collider.get_parent()

			enemy.take_damage(actual_damage)
			show_hitmarker.emit()
			enemy.blood_splatter()

		current_from = collision.position + ray_direction * 0.01

	return hit_positions

func consume_ammo():
	var consumption
	if is_burst:
		consumption = ammo_consumption_per_shot * burst_amount
	else:
		consumption = ammo_consumption_per_shot
	current_ammo_count -= consumption

	if current_ammo_count < 0:
		current_ammo_count = 0

	update_ammo.emit(current_ammo_count, max_ammo_count)

	if current_ammo_count <= 0:
		has_ammo = false
		show_reload.emit(true)

func activate_muzzle_flash():
	muzzle_flash.emitting = true

func make_bullet_trail(from: Vector3, to: Vector3):
	var bullet_dir = (to - muzzle.global_position).normalized()
	var start_pos = from + bullet_dir * 0.25
	if (from - to).length() > 0.5:
		var bullet_tracer: Node3D = BULLET_TRACER.instantiate()
		player.add_sibling(bullet_tracer)
		bullet_tracer.global_position = start_pos
		bullet_tracer.rotation = muzzle.global_rotation
		bullet_tracer.target_pos = to

func play_shoot_animation():
	if animation_player.is_playing():
		animation_player.play("RESET")
	animation_player.play("Shoot")

func reload():
	if is_reloading or is_firing_burst:
		return
	play_reload_animation()

func play_reload_animation():
	if is_reloading:
		return
	is_reloading = true
	animation_player.stop()
	animation_player.play("Reload")
	var default_length = animation_player.current_animation_length
	var speed_scale = default_length / reload_time
	animation_player.speed_scale = speed_scale

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		"Reload":
			is_reloading = false
			has_ammo = true
			current_ammo_count = max_ammo_count
			show_reload.emit(false)
			update_ammo.emit(current_ammo_count, max_ammo_count)
	animation_player.speed_scale = 1.0
