extends Control

const MESSAGES = [
	"message_brief1",
	"message_brief2",
	"message_brief3",
	"message_brief4",
	"message_brief5",
	"message_brief6",
	"message_brief7"
]

onready var _illustrations = [
	$"Illustrations/Illustration0",
	$"Illustrations/Illustration1",
	$"Illustrations/Illustration2",
	$"Illustrations/Illustration3",
	$"Illustrations/Illustration4",
	$"Illustrations/Illustration5",
	$"Illustrations/Illustration6",
]
onready var _generator_particles = [
	$"Illustrations/Illustration4/BrokenGenerator/CPUParticles2D",
	$"Illustrations/Illustration4/BrokenGenerator2/CPUParticles2D",
	$"Illustrations/Illustration4/BrokenGenerator3/CPUParticles2D"
]
onready var _dialog_text_label: RichTextLabel = $"DialogPanel/DialogTextLabel"
var _current_message_index = -1

func _ready() -> void:
	_advance_dialog()
	if Settings.particles:
		for p in _generator_particles:
			p.emitting = true
			p.visible = true


func _start_game() -> void:
	get_tree().change_scene("res://game_screen/game_screen.tscn")


func _advance_dialog() -> void:
	
	for i in _illustrations:
		i.visible = false

	_current_message_index += 1
	
	if _current_message_index >= MESSAGES.size():
		_start_game()
		return

	if _illustrations[_current_message_index] != null:
		_illustrations[_current_message_index].visible = true

	_dialog_text_label.bbcode_text = tr(MESSAGES[_current_message_index])


func _on_DialogTextLabel_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		_advance_dialog()


func _on_SkipButton_pressed() -> void:
	_start_game()
