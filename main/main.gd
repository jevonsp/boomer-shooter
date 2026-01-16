extends Node
@onready var player: CharacterBody3D = $Player
@onready var inventory_interface: Control = $UI/InventoryInterface
@onready var hotbar_inventory: PanelContainer = $UI/HotbarInventory
@onready var equip_inventory: PanelContainer = $UI/InventoryInterface/EquipInventory
@onready var weapon_inventory: PanelContainer = $UI/InventoryInterface/WeaponInventory

func _ready() -> void:
	get_window().grab_focus()
	connect_signals()
	prepare_inventories()
	create_weapons()

func connect_signals():
	player.toggle_inventory.connect(_on_inventory_toggled)
	inventory_interface.force_close.connect(_on_inventory_toggled)
	for node in get_tree().get_nodes_in_group("external_inventory"):
		node.toggle_inventory.connect(_on_inventory_toggled)
		
func prepare_inventories():
	inventory_interface.set_player_inventory(player.inventory_data)
	inventory_interface.set_equip_inventory(player.equip_inventory_data)
	inventory_interface.set_weapon_inventory(player.weapon_inventory_data)
	hotbar_inventory.set_inventory_data(player.inventory_data)

func create_weapons():
	for slot: SlotData in player.inventory_data.slot_datas:
		if slot:
			if slot.item_data is Weapon:
				var weapon: Weapon = slot.item_data
				player.add_to_held(weapon)

func _on_inventory_toggled(external_inventory_owner = null):
	inventory_interface.visible = !inventory_interface.visible
	if inventory_interface.visible:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	if external_inventory_owner and inventory_interface.visible:
		inventory_interface.set_external_inventory(external_inventory_owner)
	else:
		inventory_interface.clear_external_inventory()
