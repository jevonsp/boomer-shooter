extends Node
@onready var player: CharacterBody3D = $Player
@onready var inventory_interface: Control = $UI/InventoryInterface

func _ready() -> void:
	get_window().grab_focus()
	connect_signals()
	prepare_inventories()

func connect_signals():
	player.toggle_inventory.connect(_on_inventory_toggled)
	
	for node in get_tree().get_nodes_in_group("external_inventory"):
		node.toggle_inventory.connect(_on_inventory_toggled)
	
func prepare_inventories():
	inventory_interface.hide()
	inventory_interface.grabbed_slot.hide()
	inventory_interface.external_inventory.hide()
	inventory_interface.set_player_inventory(player.inventory_data)

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
