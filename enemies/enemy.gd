extends CharacterBody3D
const BLOOD = preload("res://enemies/blood.tscn")
@export var speed = 1.0
@export var hitpoints: int = 5
@export var damage: int = 1
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var is_dead: bool = false
var is_attacking: bool = false
@onready var model: Model = $Model
@onready var attack_hitbox: Area3D = $AttackHitbox

func _ready() -> void:
	connect_signals()

func prepare_hitboxes():
	attack_hitbox.monitoring = false

func connect_signals():
	model.animation_player.animation_finished.connect(_on_animation_finished)

func _physics_process(delta: float) -> void:
	if is_dead:
		return

	if not is_on_floor():
		velocity.y -= gravity * delta

	if not is_attacking:
		move_to_player()
		move_and_slide()

		if velocity.x > 0.1 or velocity.z > 0.1:
			if model.animation_player.current_animation != "Armature|Walk":
				play_walk_animation()

	attack()

func move_to_player():
	var player_pos = PlayerManager.get_global_position()
	var flat_target = Vector3(player_pos.x, global_position.y, player_pos.z)
	var dir = (flat_target - global_position).normalized()

	velocity.x = dir.x * speed
	velocity.z = dir.z * speed

	look_at(flat_target, Vector3.UP)

func take_damage(amount) -> void:
	if is_dead:
		return
	hitpoints -= amount
	if hitpoints <= 0:
		die()

func die() -> void:
	is_dead = true
	play_death_animation()

func attack() -> void:
	if is_dead or is_attacking:
		return

	var player_pos = PlayerManager.get_global_position()
	var dist = player_pos.distance_to(global_position)
	if dist <= 1.5:
		is_attacking = true
		play_attack_animation()

func blood_splatter():
	var blood: GPUParticles3D = BLOOD.instantiate()
	var root = get_tree().root

	blood.position = position + Vector3(0, 1, 0)
	root.add_child(blood)
	blood.emitting = true
	blood.finished.connect(func(): blood.queue_free())

func play_walk_animation():
	model.animation_player.play("Armature|Walk")

func play_death_animation():
	model.animation_player.stop()
	model.animation_player.play("Armature|Death")

func play_attack_animation():
	if model.animation_player.current_animation == "Armature|Attack":
		return
	model.animation_player.stop()
	model.animation_player.play("Armature|Attack")
	attack_hitbox.monitoring = true
	if not model.animation_player.animation_finished.is_connected(_on_animation_finished):
		model.animation_player.animation_finished.connect(_on_animation_finished)

func _on_animation_finished(anim_name: String):
	match anim_name:
		"Armature|Death": queue_free()
		"Armature|Attack":
			is_attacking = false
			attack_hitbox.monitoring = false

func _on_attack_hitbox_body_entered(body: Node3D) -> void:
	if body == PlayerManager.player:
		body.take_damage(damage)
