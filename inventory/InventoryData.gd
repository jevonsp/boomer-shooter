extends Resource
class_name InventoryData
signal inventory_updated(inventory_data: InventoryData)
signal inventory_interact(inventory_data: InventoryData, index: int, button: int, shift_pressed: bool)
@export var slot_datas: Array[SlotData]

func _on_slot_clicked(index: int, button: int, shift_pressed: bool) -> void:
	inventory_interact.emit(self, index, button, shift_pressed)
	
func grab_slot_data(index: int) -> SlotData:
	var slot_data = slot_datas[index]
	if slot_data:
		slot_datas[index] = null
		inventory_updated.emit(self)
		return slot_data
	else:
		return null
		
func drop_slot_data(grabbed_slot_data: SlotData, index: int) -> SlotData:
	var slot_data = slot_datas[index]
	
	var return_slot_data: SlotData
	if slot_data and slot_data.can_fully_merge_with(grabbed_slot_data):
		slot_data.fully_merge_with(grabbed_slot_data)
	else:
		slot_datas[index] = grabbed_slot_data
		return_slot_data = slot_data
	inventory_updated.emit(self)
	return return_slot_data

func pick_up_slot_data(slot_data: SlotData) -> bool:
	var player = PlayerManager.player
	var item_data = slot_data.item_data
	if item_data is ItemDataWeapon:
		var weapon_inventory_data: InventoryDataWeapon = player.weapon_inventory_data
		for index in weapon_inventory_data.slot_datas.size():
			if not weapon_inventory_data.slot_datas[index]:
				weapon_inventory_data.slot_datas[index] = slot_data
				print(weapon_inventory_data.slot_datas[index].item_data.name)
				player.add_to_held(slot_data.item_data)
				player.add_to_equipped(slot_data.item_data, index)
				player.update_weapons()
				weapon_inventory_data.inventory_updated.emit(weapon_inventory_data)
				inventory_updated.emit(self)
				return true
	#TODO: Equipment Types and checking type vs eachother to put in right slot
	if item_data is ItemDataEquipment:
		var equip_inventory_data: InventoryDataEquip = player.equip_inventory_data
		for index in equip_inventory_data.slot_datas.size():
			if not equip_inventory_data.slot_datas[index]:
				equip_inventory_data.slot_datas[index] = slot_data
				inventory_updated.emit(self)
				return true
	
	for index in slot_datas.size():
		if slot_datas[index] and slot_datas[index].can_fully_merge_with(slot_data):
			slot_datas[index].fully_merge_with(slot_data)
			inventory_updated.emit(self)
			return true
	
	for index in slot_datas.size():
		if not slot_datas[index]:
			slot_datas[index] = slot_data
			inventory_updated.emit(self)
			return true
	return false

func use_slot_data(index) -> void:
	var slot_data = slot_datas[index]
	if not slot_data:
		return
		
	if slot_data.item_data is ItemDataConsumable:
		
		slot_data.quantity -= 1
		if slot_data.quantity <= 0:
			clear_slot_data(index)
			return
	
	PlayerManager.use_slot_data(slot_data)
	
	inventory_updated.emit(self)

func clear_slot_data(index) -> void:
	var item = slot_datas[index]
	var held_weapons: Dictionary = PlayerManager.player.held_weapons
	if item in held_weapons:
		var weapon = held_weapons[item]
		weapon.queue_free()
		held_weapons.erase(item)
	slot_datas[index] = null
	inventory_updated.emit(self)
	print("temp delete method")
