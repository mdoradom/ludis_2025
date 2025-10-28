class_name WordDictionary
extends Resource

@export var level_name: String = ""
# Only to make easier to add objects to the dictionary
@export var objects_array: Array[BreakableObjectData] = []
# For our use case is better to use a dict but needs testing
var objects: Dictionary[String, BreakableObjectData] = {}

func load_words():
	for object in objects_array:
		objects[object.item_name] = object
	
	objects_array.clear()

func add_object(breakable_object: BreakableObjectData):
	objects[breakable_object.item_name] = breakable_object

func get_object_by_word(word: String) -> BreakableObjectData:
	return objects.get(word, null)

func get_all_objects() -> Dictionary:
	return objects

func has_word(word: String) -> bool:
	return get_object_by_word(word) != null

func get_all_words() -> Array[String]:
	var words: Array[String] = []
	for key in objects.keys():
		words.append(key)
	
	return words

func get_random_words(number: int) -> Array[String]:
	var result: Array = []
	if objects.is_empty():
		return result
	
	var keys := objects.keys()
	keys.shuffle()  # Randomize order
	
	for i in range(min(number, keys.size())):
		result.append(keys[i])
	
	return result

func get_random_objects(number: int) -> Array[BreakableObjectData]:
	var result: Array[BreakableObjectData] = []
	if objects.is_empty():
		return result
	
	var values := objects.values()
	values.shuffle()  # Randomize order
	
	for i in range(min(number, values.size())):
		result.append(values[i])
	
	return result

func difference(word_dict: WordDictionary) -> Array[String]:
	return objects.keys().filter(func(w): return not word_dict.has_word(w))

func get_new() -> Array[BreakableObjectData]:
	var new_objects: Array[BreakableObjectData] = []
	for key: BreakableObjectData in objects.keys():
		if key.is_new:
			new_objects.append(key)
	
	return new_objects

func get_size() -> int:
	return objects.size()
