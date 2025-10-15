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
