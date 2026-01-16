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
