extends Control
signal force_close
var grabbed_slot_data: SlotData
var external_inventory_owner
@onready var player_inventory: PanelContainer = $PlayerInventory
@onready var equip_inventory: PanelContainer = $EquipInventory
@onready var weapon_inventory: PanelContainer = $WeaponInventory
@onready var external_inventory: PanelContainer = $ExternalInventory
@onready var grabbed_slot: PanelContainer = $GrabbedSlot

func _ready() -> void:
	hide()
	external_inventory.hide()
	grabbed_slot.hide()

func _physics_process(_delta: float) -> void:
	if grabbed_slot.visible:
		grabbed_slot.global_position = get_global_mouse_position() + Vector2(5, 5)
	if external_inventory_owner \
			and external_inventory_owner.global_position.distance_to(PlayerManager.get_global_position()) > 4:
		force_close.emit()

func set_player_inventory(inventory_data: InventoryData) -> void:
	inventory_data.inventory_interact.connect(on_inventory_interact)
	player_inventory.set_inventory_data(inventory_data)
	
func set_equip_inventory(inventory_data: InventoryDataEquip) -> void:
	inventory_data.inventory_interact.connect(on_inventory_interact)
	equip_inventory.set_inventory_data(inventory_data)
	
func set_weapon_inventory(inventory_data: InventoryDataWeapon) -> void:
	inventory_data.inventory_interact.connect(on_inventory_interact)
	weapon_inventory.set_inventory_data(inventory_data)
	
func set_external_inventory(_external_inventory_owner) -> void:
	external_inventory_owner = _external_inventory_owner
	var inventory_data = external_inventory_owner.inventory_data
	inventory_data.inventory_interact.connect(on_inventory_interact)
	external_inventory.set_inventory_data(inventory_data)
	external_inventory.show()
	
func clear_external_inventory() -> void:
	if external_inventory_owner:
		var inventory_data = external_inventory_owner.inventory_data
		
		inventory_data.inventory_interact.disconnect(on_inventory_interact)
		external_inventory.clear_inventory_data(inventory_data)
		
		external_inventory.hide()
		external_inventory_owner = null

func on_inventory_interact(
	inventory_data: InventoryData, index: int, button: int, shift_pressed: bool
	) -> void:
	print("invent got interact")
	match [grabbed_slot_data, button]:
		[null, MOUSE_BUTTON_LEFT]:
			if shift_pressed:
				inventory_data.clear_slot_data(index)
				return
			grabbed_slot_data = inventory_data.grab_slot_data(index)
		[_, MOUSE_BUTTON_LEFT]:
			grabbed_slot_data = inventory_data.drop_slot_data(grabbed_slot_data, index)
		[null, MOUSE_BUTTON_RIGHT]:
			inventory_data.use_slot_data(index)
	update_grabbed_slot()

func update_grabbed_slot() -> void:
	if grabbed_slot_data:
		grabbed_slot.show()
		grabbed_slot.set_slot_data(grabbed_slot_data)
	else:
		grabbed_slot.set_slot_data(null)
		grabbed_slot.hide()
