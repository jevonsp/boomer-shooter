extends Node3D
class_name BaseWeapon
const BULLET_TRACER = preload("res://weapons/bullet_tracer.tscn")
@export var BULLET: PackedScene
@export var damage: int = 1
@export var clip_size: int = 6
@export var reload_time: float = 1.0
@export var is_automatic: bool = false
@export var shot_time: float = .3
@export var bullet_size: float = 0.1
var is_enabled: bool = false
var has_ammo: bool = true:
	set(value):
		has_ammo = value
		if value == false:
			reload_label.visible = true
		else:
			reload_label.visible = false
var timer: float = 0.0
var was_firing: bool = false
var camera: Camera3D
var line_mesh: MeshInstance3D
var immediate_mesh: ImmediateMesh
var hitmarker_visible: bool = false:
	set(value):
		hitmarker_visible = value
		if value == true:
			hit_marker.visible = true
			await get_tree().create_timer(0.1).timeout
			hitmarker_visible = false
			hit_marker.visible = false
var current_ammo_count: int
var is_reloading: bool = false
@onready var player: CharacterBody3D = PlayerManager.player
@onready var muzzle: Marker3D = $Marker3D
@onready var muzzle_flash: GPUParticles3D = $Marker3D/MuzzleFlash
@onready var hit_marker: TextureRect = $CanvasLayer/Control/HitMarker
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var reload_label: Label = $CanvasLayer/Control/ReloadLabel
func _ready() -> void:
	line_mesh = MeshInstance3D.new()
	immediate_mesh = ImmediateMesh.new()
	line_mesh.mesh = immediate_mesh
	add_child(line_mesh)
	print(PlayerManager.player)
	camera = PlayerManager.player.camera
	
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
	current_ammo_count = clip_size
				
func fire():
	if not is_enabled:
		return
	if not has_ammo:
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
			var enemy_area_3d = collision.collider
			var enemy = enemy_area_3d.get_parent()
			var amount = damage
			enemy.take_damage(amount)
			hitmarker_visible = true
		else:
			print(collision.collider.name)
		to = collision.position
	else:
		to = camera.global_position - camera.global_transform.basis.z * 100
	make_bullet_trail(from, to)
	activate_muzzle_flash()
	play_shoot_animation()
	
	current_ammo_count -= 1
	
	if current_ammo_count <= 0:
		has_ammo = false
	
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

func play_shoot_animation():
	if animation_player.is_playing():
		animation_player.play("RESET")
	animation_player.play("Shoot")
	
func reload():
	print("reload called")
	play_reload_animation()
	is_reloading = true
	current_ammo_count = clip_size
	
func play_reload_animation():
	if is_reloading:
		return
	animation_player.play("Reload")
	
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	print("animation finished	")
	match anim_name:
		"Reload":
			is_reloading = false
			has_ammo = true
