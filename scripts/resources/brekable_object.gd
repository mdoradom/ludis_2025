class_name BreakableObject
extends Resource

@export var item_name: String = ""
@export var sprite_path: String = ""
@export var letters: Array[String] = []
@export var taps_to_break: int = 3

# Visual and audio feedback
@export var break_animation_name: String = "break"
@export var break_sound: AudioStream

# Physical properties
@export var letter_spawn_radius: float = 50.0
@export var letter_spawn_force: float = 100.0
@export var letter_spawn_rotation: float = PI/4

func _init(p_name: String = "", p_sprite_path: String = "", p_letters: Array = []):
	item_name = p_name
	sprite_path = p_sprite_path
	
	if p_letters.size() > 0:
		for letter in p_letters:
			letters.append(letter)
