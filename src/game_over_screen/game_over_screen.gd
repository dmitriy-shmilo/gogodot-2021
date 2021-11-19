extends VBoxContainer



func _on_QuitButton_pressed():
	get_tree().change_scene("res://title_screen/title_screen.tscn")


func _on_RetryButton_pressed():
	get_tree().change_scene("res://game_screen/game_screen.tscn")
