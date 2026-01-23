extends Node
const CONFIG_PATH = "user://keybinds.cfg"
var keybinds = {}
var _previous_state = {}

func _ready() -> void:
	add_to_group("can_save")
	load_keybinds()

func _process(_delta: float) -> void:
	# Update previous state each frame
	for action in keybinds.keys():
		_previous_state[action] = is_action_pressed(action)

func get_default_keybinds():
	return { "forward": [KEY_W],
				"left": [KEY_A],
				"back": [KEY_S],
				"right": [KEY_D],
				"jump": [KEY_SPACE],
				"reload": [KEY_R],
				"primary_mouse": [MOUSE_BUTTON_LEFT],
				"secondary_mouse": [MOUSE_BUTTON_RIGHT],
				"interact": [KEY_E],
				"inventory": [KEY_TAB],
				"shift": [KEY_SHIFT],
				"control": [KEY_CTRL],
				"switch_weapons" :[MOUSE_BUTTON_WHEEL_DOWN, MOUSE_BUTTON_WHEEL_LEFT],
				"primary_weapon": [KEY_1],
				"secondary_weapon": [KEY_2]}

func is_action_pressed(action: String) -> bool:
	for key in keybinds.get(action, []):
		if key >= MOUSE_BUTTON_LEFT and key <= MOUSE_BUTTON_WHEEL_RIGHT:
			if Input.is_mouse_button_pressed(key):
				return true
		else:
			if Input.is_key_pressed(key):
				return true
	return false

func is_action_just_pressed(action: String) -> bool:
	var currently_pressed = is_action_pressed(action)
	var was_pressed = _previous_state.get(action, false)
	return currently_pressed and not was_pressed

func rebind_action(action: String, new_key: int):
	keybinds[action] = [new_key]
	save_keybinds()

func save_keybinds():
	var config = ConfigFile.new()
	for action in keybinds.keys():
		var key_strings: Array[String] = []
		for key in keybinds[action]:
			key_strings.append(str(key))

		config.set_value("keybinds", action, ",".join(key_strings))

	var err = config.save(CONFIG_PATH)
	if err != OK:
		push_error("Failed to save keybinds: %s" % error_string(err))

func load_keybinds():
	var defaults = get_default_keybinds()
	keybinds = defaults.duplicate()

	var config = ConfigFile.new()
	var err = config.load(CONFIG_PATH)

	if err != OK:
		save_keybinds()
		return

	if not config.has_section("keybinds"):
		save_keybinds()
		return

	var needs_save: bool = false

	for action in defaults.keys():
		if config.has_section_key("keybinds", action):
			var key_string: String = config.get_value("keybinds", action)
			var keys: Array[int] = []

			for key_str in key_string.split(",", false):
				if key_str.is_valid_int():
					keys.append(int(key_str))

			if not keys.is_empty():
				keybinds[action] = keys

		else:
			needs_save = true

	if needs_save:
		save_keybinds()
