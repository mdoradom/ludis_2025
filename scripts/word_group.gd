class_name WordGroup
extends Node2D

signal dragged(object)
signal released(object)
signal clicked(object)

@export var slot_spacing := 64.0
@export var move_duration := 0.2
@export var preview_color := Color(1, 1, 1, 0.3)
@export var preview_size := Vector2(50, 50)

var letters: Array[Letter] = []
var preview_index: int = -1

func _process(delta: float) -> void:
	# TEST: This code is improvised for testing the viability of using effects
	var test_effect = false
	if test_effect:
		var time = Engine.get_physics_frames() * delta
		for i in range(letters.size()):
			var l = letters[i]
			var base_pos = Vector2(i * slot_spacing, 0)
			
			var amplitude = 10.0
			var frequency = 2.0
			var phase = i * 0.5
			
			var y_offset = amplitude * sin(time * PI * frequency + phase)
			
			l.position = base_pos + Vector2(0, y_offset)

func _draw() -> void:
	if preview_index == -1:
		return
	
	var total_width = (letters.size() - 1) * slot_spacing
	var center_offset = -total_width / 2.0
	var preview_pos = Vector2(center_offset + preview_index * slot_spacing, 0)
	
	var rect = Rect2(preview_pos - preview_size / 2, preview_size)
	draw_rect(rect, preview_color, false, 2.0)

func add_letter(letter: Letter, slot_index: int):
	slot_index = clamp(slot_index, 0, letters.size())
	letters.insert(slot_index, letter)

	if letter.get_parent() != $Letters:
		letter.reparent($Letters)

	update_letter_positions()
	
	var word_string = get_string_from_letters_array()
	if check_completed_word(word_string):
		# TODO: Think if would be better to use a signal instead of using that function
		spawn_breakable_object_temporal(word_string, global_position)
		queue_free()

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

func update_letter_positions():
	var total_width = (letters.size() - 1) * slot_spacing
	var center_offset = -total_width / 2.0
	
	for i in range(letters.size()):
		var offset = 0
		if i >= preview_index and preview_index != -1:
			offset = slot_spacing

		var target_pos = Vector2(center_offset + i * slot_spacing + offset, 0)
		var letter = letters[i]

		var tween = create_tween()
		tween.tween_property(letter, "position", target_pos, move_duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func get_slot_position(index: int) -> Vector2:
	var total_width = (letters.size() - 1) * slot_spacing
	var center_offset = -total_width / 2.0
	return global_position + Vector2(center_offset + index * slot_spacing, 0)

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

# Optional: Merge another WordGroup into this one (we need this?)
func merge_group(other: WordGroup):
	for letter in other.letters.duplicate():
		other.remove_letter(letter)
		add_letter(letter, letters.size())
	other.queue_free()

func show_preview_at_index(index: int = -1) -> void:
	preview_index = index
	update_letter_positions()
	queue_redraw()

# TODO: Do that in a better way please :/
func spawn_breakable_object_temporal(word: String, pos: Vector2):
	var BOF: BreakableObjectFactory = get_tree().get_current_scene().breakable_object_factory
	BOF.spawn_breakable_object_from_string(word, pos)

func check_completed_word(word: String) -> bool:
	var word_string = word.to_upper()
	
	var level_dictionary: WordDictionary = get_tree().current_scene.current_dictionary
	
	return level_dictionary.has_word(word)
	
func get_string_from_letters_array() -> String:
	var s = ""
	for letter in letters:
		s += str(letter)
	
	return s
