extends Node2D
class_name Level

signal game_finished
signal sticker_unlocked  # Add this new signal

@export var starting_dictionary: WordDictionary
@export var objects_dictionary: WordDictionary

@export var initial_objects_number: int = 4
@export var max_spawned_objects = 3

@export var word_audio_delay: float = 0.5

var breakable_object_factory: BreakableObjectFactory
var letter_factory: LetterFactory
var current_dictionary: WordDictionary
var available_objects = {}

var available_letters_in_level: Dictionary[String, int] = {} # {"A", 3}

var level_started: bool = false

var spawned_objects: int = 0

func _ready():
	breakable_object_factory = get_node("BreakableObjectFactory")
	letter_factory = get_node("LetterFactory")
	
	load_dictionary(starting_dictionary)
	
	objects_dictionary.load_words()
	
	var starting_words: Array[BreakableObjectData] = _generate_valid_starting_words()
	
	for i in range(initial_objects_number):
		print("Starting Words:", starting_words[i].item_name)

	for i in range(initial_objects_number):
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
	

	get_node("WordChecker").check_formable_words_test()
	
	if UserData.is_first_playthrough:
		var onboarding = get_node("Onboarding")
		if onboarding:
			onboarding.visible = true
			await onboarding.visibility_changed
	
	await play_start_audio()
	await play_formable_words_audio()
	
	level_started = true

func play_start_audio() -> void:
	# Play initial audio
	var initial_audio_path = "res://assets/audio/dictat/frase-inicial.mp3"
	var initial_audio = load(initial_audio_path) as AudioStream
	
	if initial_audio:
		var audio_player = AudioStreamPlayer.new()
		audio_player.stream = initial_audio
		add_child(audio_player)
		audio_player.play()
		
		# Wait for initial audio to finish
		await audio_player.finished
		audio_player.queue_free()

func play_formable_words_audio() -> void:
	
	# Get formable words
	var formable_words: Array = get_node("WordChecker").check_formable_words_test()
	
	# Play audio for each formable word
	for word in formable_words:
		var word_data: BreakableObjectData = current_dictionary.get_object_by_word(word)
		
		if word_data and word_data.dictation_audio:
			var audio_player = AudioStreamPlayer.new()
			audio_player.stream = word_data.dictation_audio
			add_child(audio_player)
			audio_player.play()
			
			# Wait for this audio to finish before playing next
			await audio_player.finished
			audio_player.queue_free()

			# Add delay between words (adjust seconds as needed)
			await get_tree().create_timer(word_audio_delay).timeout
		else:
			push_warning("No dictation audio set for word: ", word)

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


func _on_breakable_object_factory_breakable_object_spawned(b_object: BreakableObject, is_new: bool) -> void:
	if !level_started:
		return
	
	if is_new:
		_update_available_letters(b_object.object_data)
	
	if (b_object.object_data.type == BreakableObjectData.Type.STICKER):
		var object_letter_number: int = b_object.name.length()
		UserData.new_gomets_earned += object_letter_number * 8 # Change the 8 with the correct multiplier
		if UserData.unlocked_stickers.has_word(b_object.object_data.item_name):
			print("Sticker '", b_object.object_data.item_name, "' already unlocked.")
		else:
			print("Sticker '", b_object.object_data.item_name, "' unlocked!")
			UserData.unlocked_stickers.add_object(b_object.object_data)
			b_object.object_data.is_new = true
			var StickerPopup = preload("res://scripts/ui/sticker_popup.gd")
			StickerPopup.create_and_show(b_object.object_data)
			sticker_unlocked.emit()  # Emit signal when sticker is unlocked

	
	print(available_letters_in_level)
	_check_game_completion()

func _update_available_letters(b_object_data: BreakableObjectData) -> void:
	var object_name: String = b_object_data.item_name
	
	for char in object_name:
		available_letters_in_level[char] = available_letters_in_level.get(char, 0) + 1

func _check_game_completion() -> void:
	
	var formable_words: Array = get_node("WordChecker").check_formable_words_test()
	
	if formable_words.is_empty():
		emit_signal("game_finished")

func _generate_valid_starting_words() -> Array[BreakableObjectData]:
	var max_attempts: int = 100  # Prevent infinite loop
	var attempts: int = 0
	
	while attempts < max_attempts:
		attempts += 1
		available_letters_in_level.clear()  # Reset letters for fresh attempt
		
		# Create a combined pool of objects from both dictionaries
		var combined_pool: Array[BreakableObjectData] = []
		combined_pool.append_array(objects_dictionary.get_all_objects().values())
		combined_pool.append_array(UserData.unlocked_stickers.get_all_objects().values())
		
		# Shuffle and select random objects from the combined pool
		combined_pool.shuffle()
		var candidate_words: Array[BreakableObjectData] = []
		for i in range(min(initial_objects_number, combined_pool.size())):
			candidate_words.append(combined_pool[i])
		
		# Simulate available letters from these words
		for word_data in candidate_words:
			_update_available_letters(word_data)
		
		# Check if these starting words can form other words
		var formable_words: Array = get_node("WordChecker").check_formable_words_test()
		if !formable_words.is_empty():
			print("Found valid starting words after ", attempts, " attempts")
			#available_letters_in_level.clear()
			return candidate_words
	
	# Fallback: return last attempt if we hit max attempts
	push_error("Could not find ideal starting words after ", max_attempts, " attempts. Using last set.")
	return objects_dictionary.get_random_objects(initial_objects_number)


func _on_speaker_button_pressed() -> void:
	play_formable_words_audio()
