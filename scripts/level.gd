extends Node2D

@export var starting_dictionary: WordDictionary
@export var objects_dictionary: WordDictionary

@export var initial_objects_number: int = 4

var breakable_object_factory: BreakableObjectFactory
var letter_factory: LetterFactory
var current_dictionary: WordDictionary
var available_objects = {}

var available_letters_in_level: Dictionary[String, int] = {} # {"A", 3}

var level_started: bool = false

func _ready():
	breakable_object_factory = get_node("BreakableObjectFactory")
	letter_factory = get_node("LetterFactory")
	
	load_dictionary(starting_dictionary)
	
	objects_dictionary.load_words()
	
	var starting_words: Array[BreakableObjectData] = _generate_valid_starting_words()
	
	for i in range(initial_objects_number):
		print("Starting Words:", starting_words[i].item_name)

	for i in range(initial_objects_number):
		#if !available_objects.has(word):
			#print("Warning: Starting object '", word, "' not found in dictionary")
			#return
			
		var viewport_size = get_viewport_rect().size
		
		# Base spawn position in the center
		var spawn_pos = Vector2(viewport_size.x / 2, viewport_size.y / 2)
		
		# Random offset (adjust max_offset as needed)
		var max_offset = 250  # pixels
		spawn_pos.x += randf_range(-max_offset, max_offset)
		spawn_pos.y += randf_range(-max_offset, max_offset)
		
		breakable_object_factory.spawn_breakable_object_from_data(
			starting_words[i],
			spawn_pos
		)
	
	# REMOVE
	get_node("WordChecker").check_formable_words_test()
	
	level_started = true

func load_dictionary(dictionary: WordDictionary):
	current_dictionary = dictionary
	
	current_dictionary.load_words()
	
	if not current_dictionary:
		print("Error: Could not load dictionary")
		return
	
	available_objects = current_dictionary.get_all_objects()
	
	print("Loaded dictionary: ", current_dictionary.level_name)
	print("Available words: ", current_dictionary.get_all_words())

func _on_object_broken(object_data: BreakableObjectData, pos: Vector2):
	letter_factory.spawn_letters_from_object(object_data, pos)


func _on_breakable_object_factory_breakable_object_spawned(b_object: BreakableObject) -> void:
	
	#_update_available_letters(b_object.object_data)
	UserData.unlocked_stickers.add_object(b_object.object_data)
	
	print(available_letters_in_level)
	_check_game_completion()

func _update_available_letters(b_object_data: BreakableObjectData) -> void:
	var object_name: String = b_object_data.item_name
	
	for char in object_name:
		available_letters_in_level[char] = available_letters_in_level.get(char, 0) + 1

func _check_game_completion() -> void:
	if !level_started:
		return
	
	var game_finished: bool = get_node("WordChecker").check_formable_words_test()
	
	if game_finished:
		SceneManager.load_scene(SceneManager.SCENE_LEVEL.MAIN_MENU)

func _generate_valid_starting_words() -> Array[BreakableObjectData]:
	var max_attempts: int = 100  # Prevent infinite loop
	var attempts: int = 0
	
	while attempts < max_attempts:
		attempts += 1
		available_letters_in_level.clear()  # Reset letters for fresh attempt
		
		var candidate_words: Array[BreakableObjectData] = objects_dictionary.get_random_objects(initial_objects_number)
		
		# Simulate available letters from these words
		for word_data in candidate_words:
			_update_available_letters(word_data)
		
		# Check if these starting words can form other words
		if !get_node("WordChecker").check_formable_words_test():
			print("Found valid starting words after ", attempts, " attempts")
			#available_letters_in_level.clear()
			return candidate_words
	
	# Fallback: return last attempt if we hit max attempts
	push_warning("Could not find ideal starting words after ", max_attempts, " attempts. Using last set.")
	return objects_dictionary.get_random_objects(initial_objects_number)
