extends Node

const MAX_VOLUME_DB = 2.0
const MIN_VOLUME_DB = -40.0
const MAX_VOLUME = 100.0
const DEFAULT_VOLUME = 75.0
const MIN_VOLUME = 0.0
const SETTINGS_FILE = "user://settings.json"

var master_volume: float = DEFAULT_VOLUME setget set_master_volume
var sfx_volume:float = DEFAULT_VOLUME setget set_sfx_volume
var music_volume:float = DEFAULT_VOLUME setget set_music_volume
var speech_volume:float = DEFAULT_VOLUME setget set_speech_volume

var _master_bus_idx = -1
var _sfx_bus_idx = -1
var _music_bus_idx = -1
var _speech_bus_idx = -1

func _ready() -> void:
	_master_bus_idx = AudioServer.get_bus_index("Master")
	_music_bus_idx = AudioServer.get_bus_index("Music")
	_sfx_bus_idx = AudioServer.get_bus_index("Sfx")
	_speech_bus_idx = AudioServer.get_bus_index("Speech")


func set_master_volume(value: float) -> void:
	master_volume = clamp(value, MIN_VOLUME, MAX_VOLUME)
	_set_volume(_master_bus_idx, value)


func set_sfx_volume(value: float) -> void:
	sfx_volume = clamp(value, MIN_VOLUME, MAX_VOLUME)
	_set_volume(_sfx_bus_idx, value)


func set_music_volume(value: float) -> void:
	music_volume = clamp(value, MIN_VOLUME, MAX_VOLUME)
	_set_volume(_music_bus_idx, value)


func set_speech_volume(value: float) -> void:
	speech_volume = clamp(value, MIN_VOLUME, MAX_VOLUME)
	_set_volume(_speech_bus_idx, value)


func save_settings() -> void:
	var file = File.new()
	var err = file.open(SETTINGS_FILE, File.WRITE)
	ErrorHandler.handle(err)
	file.store_string(to_json(_get_data()))
	file.close()


func load_settings() -> void:
	var file := File.new()
	
	if not file.file_exists(SETTINGS_FILE):
		save_settings()
		return

	var open_err = file.open(SETTINGS_FILE, File.READ)
	ErrorHandler.handle(open_err)

	var data := JSON.parse(file.get_as_text())
	
	if data.error != OK:
		# TODO: log or report an error?
		ErrorHandler.handle(data.error)
		save_settings()
		return
	
	# TODO: validate or keep track of versions?
	_set_from_data(data.result)


func _set_volume(bus_idx: int, volume: float) -> void:
	if volume > MIN_VOLUME:
		AudioServer.set_bus_mute(bus_idx, false)
		AudioServer.set_bus_volume_db(bus_idx, \
			lerp(MIN_VOLUME_DB, MAX_VOLUME_DB, volume / MAX_VOLUME))
		return
	AudioServer.set_bus_mute(bus_idx, true)


func _get_data() -> Dictionary:
	var action_map = {}
	var actions = InputMap.get_actions()
	for action in actions:
		if action.begins_with("ui_") or action.begins_with("system_"):
			continue;
		var list = InputMap.get_action_list(action)
		if list.size() == 0:
			action_map[action] = null
			continue
		
		if list[0] is InputEventKey:
			action_map[action] = (list[0] as InputEventKey).scancode
		

	return {
		"sound" : {
			"master_volume" : master_volume,
			"sfx_volume" : sfx_volume,
			"music_volume" : music_volume,
			"speech_volume" : speech_volume
		},
		"actions" : action_map
	}


func _set_from_data(data: Dictionary) -> void:
	master_volume = data["sound"].get("master_volume", DEFAULT_VOLUME)
	sfx_volume = data["sound"].get("sfx_volume", DEFAULT_VOLUME)
	music_volume = data["sound"].get("music_volume", DEFAULT_VOLUME)
	speech_volume = data["sound"].get("speech_volume", DEFAULT_VOLUME)
	
	var actions = InputMap.get_actions()
	for action in actions:
		if action.begins_with("ui_") \
			or action.begins_with("system_") \
			or not data["actions"].has(action):
			continue;
		
		
		InputMap.action_erase_events(action)
		
		var scancode = data["actions"][action]
		if scancode == null:
			continue
		
		var event = InputEventKey.new();
		event.scancode = scancode
		InputMap.action_add_event(action, event)
