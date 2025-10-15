extends Node2D

@export var starting_dictionary_path: String = "res://resources/animals_dictionary.tres"
@export var starting_object_word: String = "GODOT"

var breakable_object_factory: BreakableObjectFactory
var letter_factory: LetterFactory
var current_dictionary: WordDictionary
var available_objects = {}

func _ready():
	breakable_object_factory = get_node("BreakableObjectFactory")
	letter_factory = get_node("LetterFactory")
	
	load_dictionary(starting_dictionary_path)
	
	if available_objects.has(starting_object_word):
		var viewport_size = get_viewport_rect().size
		var spawn_pos = Vector2(viewport_size.x / 2, viewport_size.y / 2)
		breakable_object_factory.spawn_breakable_object_from_data(
									available_objects[starting_object_word],
									spawn_pos)
	else:
		print("Warning: Starting object '", starting_object_word, "' not found in dictionary")

func load_dictionary(dictionary_path: String):
	current_dictionary = load(dictionary_path) as WordDictionary
	
	current_dictionary.load_words()
	
	if not current_dictionary:
		print("Error: Could not load dictionary from ", dictionary_path)
		return
	
	available_objects = current_dictionary.get_all_objects()
	
	print("Loaded dictionary: ", current_dictionary.level_name)
	print("Available words: ", current_dictionary.get_all_words())

func _on_object_broken(object_data: BreakableObjectData, pos: Vector2):
	letter_factory.spawn_letters_from_object(object_data, pos)
