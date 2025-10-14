class_name WordDictionary
extends Resource

@export var level_name: String = ""
@export var objects: Array[BreakableObjectData] = []
# For our use case is better to use a dict but needs testing
#@export var objects_dict: Dictionary[String, BreakableObjectData] = {}

func add_object(breakable_object: BreakableObjectData):
	objects.append(breakable_object)

func get_object_by_word(word: String) -> BreakableObjectData:
	for obj in objects:
		if obj.item_name == word:
			return obj
	return null

func get_available_objects() -> Dictionary:
	var result = {}
	for obj in objects:
		result[obj.item_name] = obj
	return result

func is_valid_word(word: String) -> bool:
	return get_object_by_word(word) != null

func get_all_words() -> Array[String]:
	var words: Array[String] = []
	for obj in objects:
		words.append(obj.item_name)
	return words
