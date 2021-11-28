extends ColorRect


onready var _message: RichTextLabel = $"Container/Message"
onready var _transition_player: AnimationPlayer = $"TransitionPlayer"

func _ready() -> void:
	_transition_player.play("fade_in")

	var text = "";
	
	if UserSaveData.highest_score > UserSaveData.current_score:
		text = tr("ui_highscore")
		text = text.replace("{0}", str(UserSaveData.current_score)) \
			.replace("{1}", str(UserSaveData.highest_score))
	else:
		text = tr("ui_highscore_achieved")
		text = text.replace("{0}", str(UserSaveData.current_score)) \
			.replace("{1}", str(UserSaveData.highest_score))
		UserSaveData.highest_score = UserSaveData.current_score
		UserSaveData.save_data()
	
	_message.bbcode_text = text

	
func _on_QuitButton_pressed():
	_transition_player.play("fade_out")
	yield(_transition_player, "animation_finished")
	get_tree().change_scene("res://title_screen/title_screen.tscn")


func _on_RetryButton_pressed():
	_transition_player.play("fade_out")
	yield(_transition_player, "animation_finished")
	get_tree().change_scene("res://game_screen/game_screen.tscn")
