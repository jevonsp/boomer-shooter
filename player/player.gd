extends CharacterBody3D
signal toggle_inventory
const SPEED = 5.0
const JUMP_VELOCITY = 4.5
@export var inventory_data: InventoryData
@export var equip_inventory_data: InventoryDataEquip
@export var weapon_inventory_data: InventoryDataWeapon
var held_weapons: Dictionary[ItemDataWeapon, Node3D]
var equipped_weapons: Dictionary[int, ItemDataWeapon]
var equipped_weapon_index: int = 0
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var health: int
var max_health: int = 5
@onready var camera: Camera3D = $Camera3D
@onready var interact_ray: RayCast3D = $Camera3D/InteractRay
@onready var marker_3d: Marker3D = $Camera3D/Marker3D
func _ready() -> void:
	health = max_health
	PlayerManager.player = self
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
		
	if InputManager.is_action_pressed("inventory"):
		toggle_inventory.emit()
	if InputManager.is_action_pressed("interact"):
		interact()
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			MOUSE_BUTTON_WHEEL_DOWN, MOUSE_BUTTON_WHEEL_UP:
				switch_weapons()
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * .005)
		camera.rotate_x(-event.relative.y * .005)
		camera.rotation.x = clamp(camera.rotation.x, -PI/4, PI/4)
		
func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta
	var jump = InputManager.is_action_pressed("jump")
	
	if jump and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	var input_dir := Vector2.ZERO
	
	if InputManager.is_action_pressed("forward"):
		input_dir.y -= 1
	if InputManager.is_action_pressed("back"):
		input_dir.y += 1
	if InputManager.is_action_pressed("left"):
		input_dir.x -= 1
	if InputManager.is_action_pressed("right"):
		input_dir.x += 1
	
	if input_dir.length() >0:
		input_dir = input_dir.normalized()
	
	var camera_basis = camera.global_transform.basis
	var camera_forward = camera_basis.z  # Forward is negative Z
	var camera_right = camera_basis.x     # Right is positive X
	camera_forward.y = 0
	camera_right.y = 0
	camera_forward = camera_forward.normalized()
	camera_right = camera_right.normalized()
	
	var direction = Vector3.ZERO
	direction += camera_forward * input_dir.y  # Forward/back
	direction += camera_right * input_dir.x    # Left/right

	if direction.length() > 0:
		direction = direction.normalized()

	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

func interact() -> void:
	if interact_ray.is_colliding():
		interact_ray.get_collider().player_interact()

func heal(amount) -> void:
	print("healing for %s" % [amount])
	health = min(health + amount, max_health)
	print("health now %s" % [health])

func add_to_held(weapon: ItemDataWeapon):
	var model = weapon.MODEL.instantiate()
	model.is_enabled = false
	model.hide()
	marker_3d.add_child(model)
	held_weapons[weapon] = model
	print(held_weapons)

func remove_from_held(weapon: ItemDataWeapon):
	var model = held_weapons[weapon]
	held_weapons.erase(weapon)
	model.queue_free()
	
func add_to_equipped(weapon: ItemDataWeapon, index: int):
	equipped_weapons[index] = weapon
	
func remove_from_equipped(index: int):
	var weapon = equipped_weapons[index]
	var model = held_weapons[weapon]
	model.hide()
	model.is_enabled = false
	equipped_weapons[index] = null
	
func update_weapons():
	var item = equipped_weapons.get(equipped_weapon_index)
	if item:
		var weapon = held_weapons[item]
		weapon.show()
		weapon.is_enabled = true

func switch_weapons():
	print("switch")
	var item = equipped_weapons.get(equipped_weapon_index)
	if item:
		var weapon = held_weapons[item]
		weapon.hide()
		weapon.is_enabled = false
	equipped_weapon_index = (equipped_weapon_index + 1) % 2
	update_weapons()
