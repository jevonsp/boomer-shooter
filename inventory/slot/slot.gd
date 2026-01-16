extends PanelContainer
signal slot_clicked(index: int, button: int, shift_pressed: bool)
@onready var texture_rect: TextureRect = $MarginContainer/TextureRect
@onready var quantity_label: Label = $QuantityLabel
var current_slot_data: SlotData

func _ready() -> void:
	set_slot_data(current_slot_data)
	
func set_slot_data(slot_data: SlotData):
	current_slot_data = slot_data
	
	if slot_data == null:
		texture_rect.texture = null
		return
		
	var item_data = slot_data.item_data
	texture_rect.texture = item_data.texture
	tooltip_text = "%s\n%s" % [item_data.name, item_data.description]
	if slot_data.quantity > 1:
		quantity_label.text = "x%s" % [slot_data.quantity]
		quantity_label.show()
	else:
		quantity_label.hide()

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton \
			and (event.button_index == MOUSE_BUTTON_LEFT \
			or event.button_index == MOUSE_BUTTON_RIGHT) \
			and event.is_pressed():
		var shift_pressed = InputManager.is_action_pressed("shift")
		slot_clicked.emit(get_index(), event.button_index, shift_pressed)
