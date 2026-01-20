extends CharacterBody3D
const BLOOD = preload("res://enemies/blood.tscn")
const SPEED = 1.0
@export var hitpoints: int = 5
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var is_dead: bool = false
@onready var model: Model = $Model

func _ready() -> void:
	connect_signals()

func connect_signals():
	model.animation_player.animation_finished.connect(_on_animation_finished)

func _physics_process(delta: float) -> void:
	if is_dead:
		return
	if not is_on_floor():
		velocity.y -= gravity * delta
		
	move_to_player()
	move_and_slide()
	
	if velocity.x > 0.1 or velocity.z > 0.1:
		play_walk_animation()
	
func take_damage(amount) -> void:
	if is_dead:
		return
	hitpoints -= amount
	if hitpoints <= 0:
		die()

func die() -> void:
	is_dead = true
	play_death_animation()

func move_to_player():
	var player_pos = PlayerManager.get_global_position()
	var flat_target = Vector3(player_pos.x, global_position.y, player_pos.z)
	var dir = (flat_target - global_position).normalized()
	
	velocity.x = dir.x * SPEED
	velocity.z = dir.z * SPEED
	
	look_at(flat_target, Vector3.UP)

func blood_splatter():
	var blood: GPUParticles3D = BLOOD.instantiate()
	var root = get_tree().root
	
	blood.position = position + Vector3(0, 1, 0)
	root.add_child(blood)
	blood.emitting = true
	blood.finished.connect(func(): blood.queue_free())
	
func _on_animation_finished(anim_name: String):
	match anim_name:
		"Armature|Death": queue_free()

func play_walk_animation():
	model.animation_player.play("Armature|Walk")
	
func play_death_animation():
	model.animation_player.stop()
	model.animation_player.play("Armature|Death")
	
func play_attack_animation():
	model.animation_player.play("Armature|Attack")
