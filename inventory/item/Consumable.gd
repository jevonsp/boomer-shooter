extends ItemData
class_name Consumable
@export var heal_value: int = 1
func use(target) -> void:
	if heal_value != 0:
		target.heal(heal_value)
