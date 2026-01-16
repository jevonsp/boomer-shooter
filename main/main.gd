extends Node
@onready var player: CharacterBody3D = $Player
@onready var inventory_interface: Control = $CanvasLayer/InventoryInterface

func _ready() -> void:
	get_window().grab_focus()
	connect_signals()

func connect_signals():
	player.toggle_inventory.connect(_on_inventory_toggled)

func _on_inventory_toggled():
	inventory_interface.visible = !inventory_interface.visible
	if inventory_interface.visible:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
