extends PanelContainer
signal hotbar_used(index: int)
const SLOT = preload("res://inventory/slot/slot.tscn")
@onready var hotbar: HBoxContainer = $MarginContainer/HBoxContainer

func _unhandled_key_input(event: InputEvent) -> void:
	if not event.is_pressed():
		return
		
	for i in range(4):
		if InputManager.is_action_pressed("hotbar%d" % (i + 1)):
			hotbar_used.emit(i + 4)

func set_inventory_data(inventory_data: InventoryData) -> void:
	inventory_data.inventory_updated.connect(populate_hotbar)
	populate_hotbar(inventory_data)
	hotbar_used.connect(inventory_data.use_slot_data)

func populate_hotbar(inventory_data: InventoryData) -> void:
	for child in hotbar.get_children():
		child.queue_free()
		
	for slot_data in inventory_data.slot_datas.slice(4, 8):
		var slot = SLOT.instantiate()
		hotbar.add_child(slot)
		
		if slot_data:
			slot.set_slot_data(slot_data)
