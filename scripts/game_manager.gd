extends Node2D

var breakable_object_scene = preload("res://scenes/object.tscn")
var letter_manager: LetterManager
var available_objects = {}

func _ready():
	letter_manager = LetterManager.new()
	add_child(letter_manager)
	letter_manager.connect("word_formed", Callable(self, "_on_word_formed"))
	
	create_available_objects()
	
	letter_manager.set_available_objects(available_objects)
	
	spawn_object(available_objects["GODOT"])

func create_available_objects():
	create_godot_object()
	
	var god_letters = ["G", "O", "D"]
	var god_object = BreakableObject.new("GOD", "res://icon.svg", god_letters)
	god_object.taps_to_break = 3
	available_objects["GOD"] = god_object
	
	var dot_letters = ["D", "O", "T"]
	var dot_object = BreakableObject.new("DOT", "res://icon.svg", dot_letters)
	dot_object.taps_to_break = 3
	available_objects["DOT"] = dot_object
	

func create_godot_object():
	var g_letter = "G"
	var o_letter = "O"
	var d_letter = "D"
	var o2_letter = "O"
	var t_letter = "T"
	
	var godot_object = BreakableObject.new("GODOT", "res://icon.svg", [g_letter, o_letter, d_letter, o2_letter, t_letter])
	godot_object.taps_to_break = 3
	
	available_objects["GODOT"] = godot_object

func spawn_object(object_data: BreakableObject, pos: Vector2 = Vector2.ZERO):
	var object = breakable_object_scene.instantiate()
   
	
	if pos == Vector2.ZERO:
		var viewport_size = get_viewport_rect().size
		pos = Vector2(viewport_size.x / 2, viewport_size.y / 2)
	object.position = pos
	
	object.object_data = object_data
	object.connect("broken", Callable(self, "_on_object_broken"))
	
	add_child(object)
	return object

func _on_object_broken(object_data: BreakableObject, pos: Vector2):
	letter_manager.spawn_letters_from_object(object_data, pos)

func _on_word_formed(word: String, letters: Array):
	print("Word formed: ", word)
	
	letter_manager.clear_specific_letters(letters)
	
	spawn_object(available_objects[word])
