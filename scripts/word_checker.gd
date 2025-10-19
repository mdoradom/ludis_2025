extends Node

# Converts a word to a frequency dictionary of letters (Unicode safe)
func word_to_freq_dict(word: String) -> Dictionary:
	var freq := {}
	for char in word.to_lower():
		var code = char.unicode_at(0)
		if not freq.has(code):
			freq[code] = 0
		freq[code] += 1
	return freq

# Converts available letters dictionary to frequency dictionary (Unicode safe)
func letters_dict_to_freq(letters_dict: Dictionary) -> Dictionary:
	var freq := {}
	for char in letters_dict.keys():
		var code = char.to_lower().unicode_at(0)
		freq[code] = letters_dict[char]
	return freq

# Checks if a word (given as frequency dictionary) can be formed
func can_form_word(word_freq: Dictionary, available_freq: Dictionary) -> bool:
	for code in word_freq.keys():
		if word_freq[code] > available_freq.get(code, 0):
			return false
	return true

# Returns all words from word_list that can be formed with available_letters
func get_formable_words(word_list: Array, available_letters: Dictionary) -> Array:
	var available_freq = letters_dict_to_freq(available_letters)
	var formable := []

	for word in word_list:
		var word_freq = word_to_freq_dict(word)
		if can_form_word(word_freq, available_freq):
			formable.append(word)

	return formable

# ----------------------------
# Example test
func check_formable_words_test():
	var available_letters = get_parent().available_letters_in_level
	var word_list = get_parent().current_dictionary.difference(UserData.unlocked_stickers)
	var result = get_formable_words(word_list, available_letters)
	print("Formable words:", result)  # Example output: ["cab", "abc", "bad", "cad"]
