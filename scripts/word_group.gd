class_name WordGroup
extends Node2D

@export var slot_spacing := 64.0   # distance between letters
@export var move_duration := 0.2   # seconds for snapping animation

var letters: Array[Letter] = []

var preview_index: int = -1

func _process(delta: float) -> void:
	
	print("Preview Index:", preview_index)
	#if preview_index != -1:
		#update_letter_positions()
		
	# TEST: This code is improvised for testing the viability of using effects
	var test_effect = false
	if test_effect:
		var time = Engine.get_physics_frames() * delta  # Or accumulate your own time counter
		for i in range(letters.size()):
			var l = letters[i]
			# Base position: where the letter should sit in the group
			var base_pos = Vector2(i * slot_spacing, 0)
			
			# Sinusoidal offset
			var amplitude = 10.0      # pixels
			var frequency = 2.0       # oscillations per second
			var phase = i * 0.5       # phase shift per letter for wave effect
			
			var y_offset = amplitude * sin(time * PI * frequency + phase)
			
			l.position = base_pos + Vector2(0, y_offset)


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

func update_letter_positions():
	for i in range(letters.size()):
		var offset = 0
		if i >= preview_index:
			offset = slot_spacing
		
		var target_pos = Vector2(i * slot_spacing + offset, 0)
		var letter = letters[i]

		# Create a temporary SceneTreeTween and animate
		var tween = create_tween()
		tween.tween_property(letter, "position", target_pos, move_duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

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

# Optional: Merge another WordGroup into this one (we need this?)
func merge_group(other: WordGroup):
	for letter in other.letters.duplicate():
		other.remove_letter(letter)
		add_letter(letter, letters.size())
	other.queue_free()

func show_preview_at_index(index: int = -1) -> void:
	preview_index = index
	update_letter_positions()
