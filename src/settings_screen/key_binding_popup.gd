extends PopupPanel

signal action_remapped(action, event)

export(String) var action = null


func _unhandled_key_input(event):
	
	if not visible \
		or event.is_action("ui_cancel") \
		or not event is InputEventKey or event.pressed \
		or event.shift or event.alt or event.control \
		or event.meta or event.meta:
		return
	
	emit_signal("action_remapped", action, event)


func _on_ClearButton_pressed():
	emit_signal("action_remapped", action, null)
