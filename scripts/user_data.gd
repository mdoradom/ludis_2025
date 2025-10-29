extends Node

# Think if is the better container for that manner
var unlocked_stickers: WordDictionary

var total_gomets: int
var new_gomets_earned: int
var is_first_playthrough: bool = true  # Add this new variable

# === DEBUG ===
#var debug_word_dictionary: WordDictionary = load("res://resources/animals_dictionary.tres")

func _ready() -> void:
	unlocked_stickers = WordDictionary.new()
	
	load_game()
	
	# For debugging only
	var timer: Timer = Timer.new()
	timer.wait_time = 1.0
	timer.autostart = true
	add_child(timer)  # importante: agregar el timer al árbol
	
	timer.connect("timeout", func():
		#print(unlocked_stickers.objects)
		save_game()
	)
	
	#debug_word_dictionary.load_words()
	#
	#var breakable_objects_data: Dictionary[String, BreakableObjectData] = debug_word_dictionary.get_all_objects()
	#var values = breakable_objects_data.values()
	#for i in range(4):
		#unlocked_stickers.add_object(values[randi_range(0, values.size() - 1)])
	#
	#print("Unlocked Stickers:", unlocked_stickers.get_all_words())

func _exit_tree() -> void:
	save_game()

func save_game():
	var config = ConfigFile.new()
	
	config.set_value("userdata", "unlocked_stickers", unlocked_stickers)
	config.set_value("userdata", "total_gomets", total_gomets)
	config.set_value("userdata", "is_first_playthrough", is_first_playthrough)
	
	config.save("user://userdata.ini")

func load_game():
	var config = ConfigFile.new()
	
	var err = config.load("user://userdata.ini")
	
	if err != OK:
		return
	
	unlocked_stickers = config.get_value("userdata", "unlocked_stickers")
	total_gomets = config.get_value("userdata", "total_gomets")
	is_first_playthrough = config.get_value("userdata", "is_first_playthrough", true)
