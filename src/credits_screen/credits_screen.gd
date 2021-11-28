extends VBoxContainer

onready var _credits_text: RichTextLabel = $"CreditsText"

func _ready() -> void:
	_credits_text.bbcode_text = tr("ui_credits_text")


func _on_CreditsText_meta_clicked(meta):
	OS.shell_open(meta)


func _on_BackButton_pressed():
	get_tree().change_scene("res://title_screen/title_screen.tscn")
