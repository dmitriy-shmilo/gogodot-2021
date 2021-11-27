class_name KeyBindingButton
extends Button

export (String) var action = ""

func _ready() -> void:
	refresh_label()


func refresh_label() -> void:
	var events = InputMap.get_action_list(action)
	var event = null

	for e in events:
		if e is InputEventKey:
			text = e.as_text()
			event = e
			break
	
	if event == null:
		text = tr("ui_key_none")
