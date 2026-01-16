extends InventoryData
class_name InventoryDataEquip

func drop_slot_data(grabbed_slot_data: SlotData, index: int) -> SlotData:
	if not grabbed_slot_data.item_data is Equipment:
		return grabbed_slot_data
	return super.drop_slot_data(grabbed_slot_data, index)
