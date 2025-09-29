class_name WordDictionary
extends Resource

@export var valid_words: Array[Dictionary] = []

func add_word(word: String, sprite_path: String):
	valid_words.append({
		"word": word,
		"sprite": sprite_path
	})

func is_valid_word(word: String) -> bool:
	for entry in valid_words:
		if entry.word == word:
			return true
	return false

func get_sprite_for_word(word: String) -> String:
	for entry in valid_words:
		if entry.word == word:
			return entry.sprite
	return ""
