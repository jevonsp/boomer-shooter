extends Resource
class_name SlotData
const MAX_STACK_SIZE: int = 16
@export var item_data: ItemData
@export_range(1, MAX_STACK_SIZE) var quantity: int = 1:
	set(value):
		quantity = value
		if quantity > 1 and not item_data.can_stack:
			push_error("ERROR: %s cannot stack, setting to 1" % [item_data.name])
			quantity = 1

func can_fully_merge_with(other_slot_data: SlotData) -> bool:
	return item_data == other_slot_data.item_data \
			and item_data.can_stack \
			and quantity + other_slot_data.quantity < MAX_STACK_SIZE
			
func fully_merge_with(other_slot_data: SlotData) -> void:
	quantity += other_slot_data.quantity
