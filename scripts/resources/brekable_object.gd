class_name BreakableObject
extends Resource

@export var item_name: String = ""
@export var sprite: Texture2D
@export var letters: Array[String] = []
@export var taps_to_break: int = 3

# Visual and audio feedback
@export var break_animation_name: String = "break"
@export var break_sound: AudioStream

# Physical properties
@export var letter_spawn_radius: float = 50.0
@export var letter_spawn_force: float = 100.0
@export var letter_spawn_rotation: float = PI/4

func _init(p_name: String = "", p_sprite: Texture2D = null, p_letters: Array = []):
	item_name = p_name
	sprite = p_sprite
	
	if p_letters.size() > 0:
		for letter in p_letters:
			letters.append(letter)
