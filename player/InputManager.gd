extends Node

const CONFIG_PATH = "user://keybinds.cfg"

var keybinds = {}

func _ready() -> void:
	add_to_group("can_save")
	load_keybinds()

func setup_defaults():
	keybinds = { "forward": [KEY_W],
				"left": [KEY_A],
				"back": [KEY_S],
				"right": [KEY_D],
				"jump": [KEY_SPACE],
				"primary_mouse": [MOUSE_BUTTON_LEFT],
				"secondary_mouse": [MOUSE_BUTTON_RIGHT],
				"interact": [KEY_E],
				"inventory": [KEY_TAB],
				"shift": [KEY_SHIFT],
				"control": [KEY_CTRL],
				"hotbar1": [KEY_1],
				"hotbar2": [KEY_2],
				"hotbar3": [KEY_3],
				"hotbar4": [KEY_4],
				"hotbar5": [KEY_5],
				"hotbar6": [KEY_6], 
				"switch_weapons" :[MOUSE_BUTTON_WHEEL_DOWN, MOUSE_BUTTON_WHEEL_LEFT]}

func is_action_pressed(action: String) -> bool:
	for key in keybinds.get(action, []):
		if Input.is_key_pressed(key):
			return true
	return false

func rebind_action(action: String, new_key: int):
	keybinds[action] = new_key

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
	var config = ConfigFile.new()
	var err = config.load(CONFIG_PATH)
	
	if err != OK:
		setup_defaults()
		save_keybinds()
		return
		
	keybinds = {}
	if config.has_section("keybinds"):
		for action in config.get_section_keys("keybinds"):
			var key_string = config.get_value("keybinds", action)
			var keys: Array[int] = []
			
			for key_str in key_string.split(",", false):
				if key_str.is_valid_int():
					keys.append(int(key_str))
			
			keybinds[action] = keys
