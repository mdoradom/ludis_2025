extends Node2D

var breakable_object_scene = preload("res://scenes/breakable_object.tscn")
var letter_manager: LetterManager
var current_dictionary: WordDictionary
var available_objects = {}

@export var starting_dictionary_path: String = "res://resources/level_1_dictionary.tres"
@export var starting_object_word: String = "GODOT"

func _ready():
	letter_manager = LetterManager.new()
	add_child(letter_manager)
	letter_manager.connect("word_formed", Callable(self, "_on_word_formed"))
	
	load_dictionary(starting_dictionary_path)
	
	if available_objects.has(starting_object_word):
		spawn_object(available_objects[starting_object_word])
	else:
		print("Warning: Starting object '", starting_object_word, "' not found in dictionary")

func load_dictionary(dictionary_path: String):
	current_dictionary = load(dictionary_path) as WordDictionary
	
	if not current_dictionary:
		print("Error: Could not load dictionary from ", dictionary_path)
		return
	
	available_objects = current_dictionary.get_available_objects()
	letter_manager.set_available_objects(available_objects)
	
	print("Loaded dictionary: ", current_dictionary.level_name)
	print("Available words: ", current_dictionary.get_all_words())

func change_level(new_dictionary_path: String, starting_word: String = ""):
	letter_manager.clear_letters()
	
	load_dictionary(new_dictionary_path)
	
	var start_word = starting_word if starting_word != "" else starting_object_word
	if available_objects.has(start_word):
		spawn_object(available_objects[start_word])

func spawn_object(object_data: BreakableObjectData, pos: Vector2 = Vector2.ZERO):
	var object = breakable_object_scene.instantiate()
	
	if pos == Vector2.ZERO:
		var viewport_size = get_viewport_rect().size
		pos = Vector2(viewport_size.x / 2, viewport_size.y / 2)
	object.position = pos
	
	object.object_data = object_data
	object.connect("broken", Callable(self, "_on_object_broken"))
	
	add_child(object)
	return object

func spawn_breakable_object(word: String, pos: Vector2 = Vector2.ZERO):
	if available_objects.has(word):
		spawn_object(available_objects[word], pos)

func _on_object_broken(object_data: BreakableObjectData, pos: Vector2):
	letter_manager.spawn_letters_from_object(object_data, pos)

func _on_word_formed(word: String, letters: Array):
	print("Word formed: ", word)
	
	letter_manager.clear_specific_letters(letters)
	
	if available_objects.has(word):
		spawn_object(available_objects[word])
	else:
		print("Error: Word '", word, "' not found in available objects")
