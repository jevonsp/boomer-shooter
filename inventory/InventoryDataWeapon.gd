extends InventoryData
class_name InventoryDataWeapon

func drop_slot_data(grabbed_slot_data: SlotData, index: int) -> SlotData:
	if not grabbed_slot_data.item_data is Weapon:
		return grabbed_slot_data
	var weapon = grabbed_slot_data.item_data
	PlayerManager.player.add_to_equipped(weapon, index)
	PlayerManager.player.update_weapons()
	return super.drop_slot_data(grabbed_slot_data, index)

func grab_slot_data(index: int) -> SlotData:
	PlayerManager.player.remove_from_equipped(index)
	PlayerManager.player.update_weapons()
	return super.grab_slot_data(index)
