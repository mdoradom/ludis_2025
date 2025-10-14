class_name LetterManager
extends Node2D

signal word_formed(word, letters)

var letter_scene = preload("res://scenes/letter.tscn")
var active_letters = []
var current_word = []
var valid_words_dictionary = {}
var available_objects = {}

func spawn_letters_from_object(object_data: BreakableObjectData, pos: Vector2):
	for letter_data in object_data.get_letters():
		var letter_instance = letter_scene.instantiate()
		
		var spawn_angle = randf_range(0, 2 * PI)
		var spawn_radius = randf_range(20, object_data.letter_spawn_radius)
		var spawn_pos = pos + Vector2(cos(spawn_angle), sin(spawn_angle)) * spawn_radius
		
		letter_instance.spawn(letter_data, spawn_pos)
		letter_instance.connect("letter_dragged", Callable(self, "_on_letter_dragged"))
		letter_instance.connect("letter_released", Callable(self, "_on_letter_released"))
		
		add_child(letter_instance)
		active_letters.append(letter_instance)

func _on_letter_dragged(letter):
	letter.z_index = 10

func _check_current_word():
	if current_word.size() == 0:
		return
	
	var word = ""
	var letter_objects = []
	
	for letter in current_word:
		word += letter.value
		letter_objects.append(letter)
	
	if available_objects.has(word):
		emit_signal("word_formed", word, letter_objects)

func clear_letters():
	for letter in active_letters:
		letter.queue_free()
	active_letters.clear()
	current_word.clear()

func clear_specific_letters(letters_to_remove: Array):
	for letter in letters_to_remove:
		if active_letters.has(letter):
			active_letters.erase(letter)
			letter.queue_free()
	
	current_word.clear()

func add_valid_word(word: String, sprite_path: String):
	valid_words_dictionary[word] = sprite_path

func set_available_objects(objects_dict: Dictionary):
	available_objects = objects_dict
