class_name LetterManager
extends Node2D

signal word_formed(word, letters)

var letter_scene = preload("res://scenes/letter.tscn")
var active_letters = []
var word_area: Area2D
var word_area_rect: Rect2
var current_word = []
var valid_words_dictionary = {}
var available_objects = {}

func _ready():
	_setup_word_area()


# Sets up the word area where players can drop letters to form words.
func _setup_word_area():
	word_area = Area2D.new()
	var collision = CollisionShape2D.new()
	var rect_shape = RectangleShape2D.new()
	
	var viewport_size = get_viewport_rect().size
	var area_height = 100
	
	rect_shape.size = Vector2(viewport_size.x, area_height)
	collision.shape = rect_shape
	word_area.add_child(collision)
	
	word_area.position = Vector2(viewport_size.x / 2, viewport_size.y - area_height / 2)
	word_area_rect = Rect2(0, viewport_size.y - area_height, viewport_size.x, area_height)
	
	var bg = ColorRect.new()
	bg.color = Color(0.2, 0.2, 0.2, 0.3)
	bg.size = Vector2(viewport_size.x, area_height)
	bg.position = Vector2(-viewport_size.x / 2, -area_height / 2)
	word_area.add_child(bg)
	
	var label = Label.new()
	label.text = "Drop letters here to form words"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.position = Vector2(-viewport_size.x / 2, -50)
	label.size = Vector2(viewport_size.x, 40)
	word_area.add_child(label)
	
	add_child(word_area)

func spawn_letters_from_object(object_data: BreakableObject, pos: Vector2):
	for letter_data in object_data.letters:
		var letter_instance = letter_scene.instantiate()
		
		var spawn_angle = randf_range(0, 2 * PI)
		var spawn_radius = randf_range(20, object_data.letter_spawn_radius)
		var spawn_pos = pos + Vector2(cos(spawn_angle), sin(spawn_angle)) * spawn_radius
		
		letter_instance.spawn(letter_data, spawn_pos)
		letter_instance.connect("letter_dragged", Callable(self, "_on_letter_dragged"))
		letter_instance.connect("letter_released", Callable(self, "_on_letter_released"))
		
		add_child(letter_instance)
		active_letters.append(letter_instance)

func _on_letter_dragged(letter):
	letter.z_index = 10

func _on_letter_released(letter):
	letter.z_index = 0
	
	if word_area_rect.has_point(letter.global_position):
		if not current_word.has(letter):
			current_word.append(letter)
			letter.is_in_word_area = true
			
			_arrange_word_letters()
			
			_check_current_word()
	else:
		if current_word.has(letter):
			current_word.erase(letter)
			letter.is_in_word_area = false
			
			letter.linear_velocity = letter.float_direction * letter.float_speed
			letter.is_floating = true
			
			_arrange_word_letters()

func _arrange_word_letters():
	var viewport_size = get_viewport_rect().size
	var letter_count = current_word.size()
	
	if letter_count == 0:
		return
	
	var total_width = letter_count * 50
	var start_x = (viewport_size.x - total_width) / 2 + 25
	var y_pos = viewport_size.y - 50
	
	for i in range(letter_count):
		var letter = current_word[i]
		var target_pos = Vector2(start_x + i * 50, y_pos)
		
		var tween = create_tween()
		tween.tween_property(letter, "global_position", target_pos, 0.2)

func _check_current_word():
	if current_word.size() == 0:
		return
	
	var word = ""
	var letter_objects = []
	
	for letter in current_word:
		word += letter.value
		letter_objects.append(letter)
	
	if available_objects.has(word):
		emit_signal("word_formed", word, letter_objects)

func clear_letters():
	for letter in active_letters:
		letter.queue_free()
	active_letters.clear()
	current_word.clear()

func clear_specific_letters(letters_to_remove: Array):
	for letter in letters_to_remove:
		if active_letters.has(letter):
			active_letters.erase(letter)
			letter.queue_free()
	
	current_word.clear()

func add_valid_word(word: String, sprite_path: String):
	valid_words_dictionary[word] = sprite_path

func set_available_objects(objects_dict: Dictionary):
	available_objects = objects_dict
