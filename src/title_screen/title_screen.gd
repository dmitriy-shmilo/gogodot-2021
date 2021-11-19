extends Control


onready var _quit_button = $VBoxContainer/QuitButton

func _ready():
	_quit_button.visible = not OS.has_feature("HTML5")


func _on_QuitButton_pressed():
	get_tree().quit()


func _on_CreditsButton_pressed():
	var err = get_tree().change_scene("res://credits_screen/credits_screen.tscn")
	ErrorHandler.handle(err)


func _on_TutorialButton_pressed():
	var err = get_tree().change_scene("res://tutorial_screen/tutorial_screen.tscn")
	ErrorHandler.handle(err)


func _on_SettingsButton_pressed():
	var err = get_tree().change_scene("res://settings_screen/settings_screen.tscn")
	ErrorHandler.handle(err)


func _on_NewGameButton_pressed():
	var err = get_tree().change_scene("res://game_screen/game_screen.tscn")
	ErrorHandler.handle(err)
