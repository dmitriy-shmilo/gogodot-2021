class_name KeyBindingButton
extends Button

export (String) var action = ""

func _ready():
	refresh_label()


func refresh_label():
	var actions = InputMap.get_action_list(action)
	if actions.size() > 0:
		text = actions[0].as_text()
	else:
		text = tr("ui_key_none")
