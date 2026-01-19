extends CharacterBody3D
const BLOOD = preload("res://enemies/blood.tscn")
const SPEED = 1.0
var hitpoints: int = 1000
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		print(gravity)
		velocity.y -= gravity * delta
		
	move_to_player()
	move_and_slide()
	
func take_damage(amount) -> void:
	print("hit=%s" % [amount])
	hitpoints -= amount
	if hitpoints <= 0:
		die()

func die() -> void:
	queue_free()

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
	
	print("blood pos=%s" % blood.position)
	blood.emitting = true
	
	blood.finished.connect(func(): blood.queue_free())
	
