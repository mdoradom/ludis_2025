class_name Letter extends RigidBody2D

signal dragged(object)
signal released(object)
signal clicked(object)

@export var input_controller: Node
@export var WGM: LetterWordGroupManager
@export var text_label: Label

func setup(letter_char: String, start_pos: Vector2, randomness: bool = true, random_radius: float = 10.0):
	name = letter_char
	text_label.text = letter_char
	input_controller.setup_letter(start_pos, randomness, random_radius)

func _to_string() -> String:
	return text_label.text
