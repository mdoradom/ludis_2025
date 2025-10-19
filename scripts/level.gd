extends Node2D

@export var starting_dictionary_path: String = "res://resources/animals_dictionary.tres"

var breakable_object_factory: BreakableObjectFactory
var letter_factory: LetterFactory
var current_dictionary: WordDictionary
var available_objects = {}

var available_letters_in_level: Dictionary[String, int] = {} # {"A", 3}

func _ready():
	breakable_object_factory = get_node("BreakableObjectFactory")
	letter_factory = get_node("LetterFactory")
	
	load_dictionary(starting_dictionary_path)
	
	var starting_words: Array = UserData.unlocked_stickers.get_all_words()
	print("Starting Words:", starting_words)

	for word in starting_words:
		if !available_objects.has(word):
			print("Warning: Starting object '", word, "' not found in dictionary")
			return
			
		var viewport_size = get_viewport_rect().size
		
		# Base spawn position in the center
		var spawn_pos = Vector2(viewport_size.x / 2, viewport_size.y / 2)
		
		# Random offset (adjust max_offset as needed)
		var max_offset = 250  # pixels
		spawn_pos.x += randf_range(-max_offset, max_offset)
		spawn_pos.y += randf_range(-max_offset, max_offset)
		
		breakable_object_factory.spawn_breakable_object_from_data(
			available_objects[word],
			spawn_pos
		)
		

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


func _on_breakable_object_factory_breakable_object_spawned(b_object: BreakableObject) -> void:
	var object_name: String = b_object.object_data.item_name
	
	for char in object_name:
		available_letters_in_level[char] = available_letters_in_level.get(char, 0) + 1
	
	print(available_letters_in_level)
	get_node("WordChecker").check_formable_words_test()
