extends Node
class_name LetterFactory

var letter_scene = preload("res://scenes/letter.tscn")

func spawn_letters_from_object(object_data: BreakableObjectData, pos: Vector2):
	for letter_data in object_data.get_letters():
		var letter_instance = letter_scene.instantiate()
		
		var spawn_angle = randf_range(0, 2 * PI)
		var spawn_radius = randf_range(20, object_data.letter_spawn_radius)
		var spawn_pos = pos + Vector2(cos(spawn_angle), sin(spawn_angle)) * spawn_radius
		
		letter_instance.setup(letter_data, spawn_pos)
		
		add_child(letter_instance, true)
