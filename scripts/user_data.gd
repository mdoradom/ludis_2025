extends Node

# Think if is the better container for that manner
var unlocked_stickers: WordDictionary

var total_gomets: int
var new_gomets_earned: int

# === DEBUG ===
#var debug_word_dictionary: WordDictionary = load("res://resources/animals_dictionary.tres")

func _ready() -> void:
	unlocked_stickers = WordDictionary.new()
	
	var timer: Timer = Timer.new()
	timer.wait_time = 1.0
	timer.autostart = true
	add_child(timer)  # importante: agregar el timer al árbol
	
	timer.connect("timeout", func():
		print(unlocked_stickers.objects)
	)
	
	# For debugging only
	
	#debug_word_dictionary.load_words()
	#
	#var breakable_objects_data: Dictionary[String, BreakableObjectData] = debug_word_dictionary.get_all_objects()
	#var values = breakable_objects_data.values()
	#for i in range(4):
		#unlocked_stickers.add_object(values[randi_range(0, values.size() - 1)])
	#
	#print("Unlocked Stickers:", unlocked_stickers.get_all_words())
