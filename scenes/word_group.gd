class_name WordGroup extends Node2D

var letters: Array[Letter] = []
var slot_spacing := 64.0   # distance between letters

func add_letter(letter: Letter, slot_index: int):
	# Insert into array
	letters.insert(slot_index, letter)
	# Reparent into this group
	$Letters.add_child(letter)
	update_letter_positions()

func remove_letter(letter: Letter):
	letters.erase(letter)
	update_letter_positions()

func update_letter_positions():
	for i in range(letters.size()):
		var target_x = i * slot_spacing
		var pos = Vector2(target_x, 0)
		# Smooth transition instead of snapping instantly
		letters[i].position = letters[i].position.lerp(pos, 0.5)

func reorder_letter(letter: Letter, new_index: int):
	if letter in letters:
		letters.erase(letter)
		letters.insert(new_index, letter)
		update_letter_positions()
