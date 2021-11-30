extends Control


const KeyBindingButtonScene = preload("res://settings_screen/keybinding_button.tscn")
const KeyBindingLabelScene = preload("res://settings_screen/keybinding_label.tscn")

onready var _tab_container = $"VBoxContainer/PanelContainer/TabContainer"
onready var _keybindings_grid = $"VBoxContainer/PanelContainer/TabContainer/KeyBindings/GridContainer"
onready var _keybinding_popup = $"KeyBindingPopup"
onready var _master_volume_slider = $"VBoxContainer/PanelContainer/TabContainer/SoundSettings/Container/MasterVolume/VolumeSlider"
onready var _sfx_volume_slider = $"VBoxContainer/PanelContainer/TabContainer/SoundSettings/Container/SfxVolume/VolumeSlider"
onready var _music_volume_slider = $"VBoxContainer/PanelContainer/TabContainer/SoundSettings/Container/MusicVolume/VolumeSlider"
onready var _fullscreen_checkbox: CheckBox = $"VBoxContainer/PanelContainer/TabContainer/Video/Container/FullscreenCheckbox"
onready var _particles_checkbox: CheckBox = $"VBoxContainer/PanelContainer/TabContainer/Video/Container/ParticlesCheckbox"

var _current_binding_button: KeyBindingButton = null

func _ready() -> void:
	_prepare_tabs()
	_prepare_keybindings()
	_prepare_volume()
	_prepare_video()


func _prepare_tabs() -> void:
	_tab_container.set_tab_title(0, tr("ui_sound_settings"))
	_tab_container.set_tab_title(1, tr("ui_video_settings"))
	_tab_container.set_tab_title(2, tr("ui_key_bindings"))


func _prepare_volume() -> void:
	_master_volume_slider.value = Settings.master_volume
	_sfx_volume_slider.value = Settings.sfx_volume
	_music_volume_slider.value = Settings.music_volume


func _prepare_video() -> void:
	_fullscreen_checkbox.pressed = Settings.fullscreen
	_particles_checkbox.pressed = Settings.particles


func _prepare_keybindings() -> void:
	var actions = ["up", "down", "left", "right", "zoom_in", "zoom_out", "system_pause", "shut_down"]
	for action in actions:
		var label = KeyBindingLabelScene.instance()
		label.text = tr("key_" + action)
		var button = KeyBindingButtonScene.instance()
		button.action = action
		button.connect("pressed", \
			self, \
			"_on_KeyBindingButton_keybind_requested",
			[button])
		_keybindings_grid.add_child(label)
		_keybindings_grid.add_child(button)


func _on_MasterVolumeSlider_value_changed(value) -> void:
	Settings.master_volume = value


func _on_MusicVolumeSlider_value_changed(value) -> void:
	Settings.music_volume = value


func _on_SfxVolumeSlider_value_changed(value) -> void:
	Settings.sfx_volume = value


func _on_BackButton_pressed() -> void:
	Settings.save_settings()
	var _err = get_tree().change_scene("res://title_screen/title_screen.tscn")


func _on_KeyBindingButton_keybind_requested(sender: KeyBindingButton) -> void:
	_current_binding_button = sender
	_keybinding_popup.action = sender.action
	_keybinding_popup.popup_centered()


func _on_KeybindingCancelButton_pressed() -> void:
	_keybinding_popup.hide()
	_current_binding_button = null


func _on_KeyBindingPopup_action_remapped(action, event) -> void:
	var events = InputMap.get_action_list(action)
	
	for i in range(events.size()):
		if events[i] is InputEventKey:
			InputMap.action_erase_event(action, events[i])
			break
	
	if event != null:
		InputMap.action_add_event(action, event)

	_current_binding_button.refresh_label()
	_keybinding_popup.hide()


func _on_FullscreenCheckbox_toggled(button_pressed: bool) -> void:
	Settings.fullscreen = button_pressed


func _on_ParticlesCheckbox_toggled(button_pressed: bool) -> void:
	Settings.particles = button_pressed


func _on_ParticlesLabel_gui_input(event: InputEvent) -> void:
	if event is InputEventMouse and event.is_pressed():
		_particles_checkbox.pressed = !_particles_checkbox.pressed


func _on_FullscreenLabel_gui_input(event: InputEvent) -> void:
	if event is InputEventMouse and event.is_pressed():
		_fullscreen_checkbox.pressed = !_fullscreen_checkbox.pressed
