extends Node2D

var breakable_object_scene = preload("res://scenes/object.tscn")
var letter_manager: LetterManager
var available_objects = {}

func _ready():
	# Create letter manager
	letter_manager = LetterManager.new()
	add_child(letter_manager)
	letter_manager.connect("word_formed", Callable(self, "_on_word_formed"))
	
	# Create all available objects
	create_available_objects()
	
	# Pass dictionary to letter manager
	letter_manager.set_available_objects(available_objects)
	
	# Create initial object
	spawn_object(available_objects["GODOT"])

func create_available_objects():
	# Create GODOT object
	create_godot_object()
	
	# Create GOD object
	var god_letters = [Letter.new("G"), Letter.new("O"), Letter.new("D")]
	var god_object = BreakableObject.new("GOD", "res://icon.svg", god_letters)
	god_object.taps_to_break = 3
	available_objects["GOD"] = god_object
	
	# Create DOT object
	var dot_letters = [Letter.new("D"), Letter.new("O"), Letter.new("T")]
	var dot_object = BreakableObject.new("DOT", "res://icon.svg", dot_letters)
	dot_object.taps_to_break = 3
	available_objects["DOT"] = dot_object
	
	# Add more objects as needed

func create_godot_object():
	# Create letter objects
	var g_letter = Letter.new("G")
	var o_letter = Letter.new("O")
	var d_letter = Letter.new("D")
	var o2_letter = Letter.new("O")
	var t_letter = Letter.new("T")
	
	# Create breakable object
	var godot_object = BreakableObject.new("GODOT", "res://icon.svg", [g_letter, o_letter, d_letter, o2_letter, t_letter])
	godot_object.taps_to_break = 3
	
	# Store in available objects
	available_objects["GODOT"] = godot_object

func spawn_object(object_data: BreakableObject, pos: Vector2 = Vector2.ZERO):
	var object = breakable_object_scene.instantiate()
   
	
	# Set position (default to center if not specified)
	if pos == Vector2.ZERO:
		var viewport_size = get_viewport_rect().size
		pos = Vector2(viewport_size.x / 2, viewport_size.y / 2)
	object.position = pos
	
	# Set object data and connect signal
	object.object_data = object_data
	object.connect("broken", Callable(self, "_on_object_broken"))
	
	add_child(object)
	return object

func _on_object_broken(object_data: BreakableObject, pos: Vector2):
	# Spawn letters when object breaks
	letter_manager.spawn_letters_from_object(object_data, pos)

func _on_word_formed(word: String, letters: Array):
	print("Word formed: ", word)
	
	# Only clear the specific letters that were used in the word
	letter_manager.clear_specific_letters(letters)
	
	# Spawn new object (already in available_objects dictionary)
	spawn_object(available_objects[word])
