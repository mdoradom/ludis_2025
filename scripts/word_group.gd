class_name WordGroup
extends Node2D

@export var slot_spacing := 64.0   # distance between letters
@export var move_duration := 0.2   # seconds for snapping animation

var letters: Array[Letter] = []

# --- Letter Management ---

func add_letter(letter: Letter, slot_index: int):
	slot_index = clamp(slot_index, 0, letters.size())
	letters.insert(slot_index, letter)

	# Reparent under $Letters container
	if letter.get_parent() != $Letters:
		letter.reparent($Letters)

	update_letter_positions()

func remove_letter(letter: Letter):
	if letter in letters:
		letters.erase(letter)
		update_letter_positions()

	if letters.is_empty():
		queue_free()

func reorder_letter(letter: Letter, new_index: int):
	if letter in letters:
		letters.erase(letter)
		new_index = clamp(new_index, 0, letters.size())
		letters.insert(new_index, letter)
		update_letter_positions()

# --- Positioning with Tween ---

func update_letter_positions():
	for i in range(letters.size()):
		var target_pos = Vector2(i * slot_spacing, 0)
		var letter = letters[i]

		# Create a temporary SceneTreeTween and animate
		var tween = create_tween()
		tween.tween_property(letter, "position", target_pos, move_duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

# --- Slot helpers ---

func get_slot_position(index: int) -> Vector2:
	return global_position + Vector2(index * slot_spacing, 0)

func get_nearest_slot_index(pos: Vector2) -> int:
	var best_index = 0
	var min_dist_sq = INF

	for i in range(letters.size() + 1):
		var slot_pos = get_slot_position(i)
		var dist_sq = pos.distance_squared_to(slot_pos)
		if dist_sq < min_dist_sq:
			min_dist_sq = dist_sq
			best_index = i

	return best_index

# Optional: Merge another WordGroup into this one
func merge_group(other: WordGroup):
	for letter in other.letters.duplicate():
		other.remove_letter(letter)
		add_letter(letter, letters.size())
	other.queue_free()
