class_name Letter extends RigidBody2D

signal letter_dragged(letter)
signal letter_released(letter)
signal letter_clicked(letter)

@export var input_controller: Node
@export var WGM: LetterWordGroupManager
@export var text_label: Label

func setup(letter_char: String, start_pos: Vector2):
	name = letter_char
	text_label.text = letter_char
	input_controller.setup(start_pos)

func _to_string() -> String:
	return text_label.text
