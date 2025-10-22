extends Control

@export var title_breakable_object_data: BreakableObjectData
@export var title_spawn_point: Marker2D

@onready var letter_scene = preload("res://scenes/letter.tscn")

func _ready() -> void:
	spawn_title()

func _on_play_button_pressed() -> void:
	SceneManager.load_scene(SceneManager.SCENE_LEVEL.GAME)
	
func _on_book_button_pressed() -> void:
	SceneManager.load_scene(SceneManager.SCENE_LEVEL.STICKER_BOOK)

func _on_options_button_pressed() -> void:
	SceneManager.load_scene(SceneManager.SCENE_LEVEL.OPTIONS)
	pass
	
func spawn_title():
	
	var title_node: Control = Control.new()
	title_node.name = "TitleNode"
	add_child(title_node)
	
	# This is the center and peak/valley of the arc
	var center_pos = title_spawn_point.global_position
	var offset = 80.0
	
	# The radius of the circle. A larger radius creates a flatter curve.
	var arc_radius = 600.0 
	
	# Set to true for a "u" shape (valley), false for an "n" shape (hill)
	var u_shape = false

	var letters = title_breakable_object_data.get_letters()
	var num_letters = letters.size()
	
	if num_letters == 0:
		return

	var center_index = (num_letters - 1) / 2.0
	
	var idx = 0
	for letter_data in letters:
		var letter_instance: Letter = letter_scene.instantiate()
		letter_instance.lock_rotation = false
		
		var relative_index = idx - center_index
		
		# --- X Position (Centering) ---
		var letter_offset_x = relative_index * offset
		var spawn_x = center_pos.x + letter_offset_x
		
		# --- Y Position (Circular Arc) ---
		var letter_offset_x_squared = letter_offset_x * letter_offset_x
		var radius_squared = arc_radius * arc_radius
		
		var sqrt_val = sqrt(max(0.0, radius_squared - letter_offset_x_squared))
		
		# This is the vertical distance from the center letter (peak/valley)
		var y_offset = arc_radius - sqrt_val
		
		var spawn_y = 0.0
		if u_shape:
			spawn_y = center_pos.y - y_offset
		else:
			spawn_y = center_pos.y + y_offset

		var spawn_pos = Vector2(spawn_x, spawn_y)
		
		var asin_ratio = clamp(letter_offset_x / arc_radius, -1.0, 1.0)
		var rotation_in_radians = asin(asin_ratio)
		
		if u_shape:
			rotation_in_radians = -rotation_in_radians
		
		letter_instance.setup(letter_data, spawn_pos, false)
		letter_instance.rotation = rotation_in_radians
		title_node.add_child(letter_instance, true)
		
		idx += 1
