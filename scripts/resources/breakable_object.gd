class_name BreakableObject
extends Resource

@export var item_name: String = ""
@export var sprite: Texture2D
@export var taps_to_break: int = 3
@export var break_sound: AudioStream

# Physical properties
@export var letter_spawn_radius: float = 50.0
@export var letter_spawn_force: float = 100.0
@export var letter_spawn_rotation: float = PI/4

func _init(p_name: String = "", p_sprite: Texture2D = null):
	item_name = p_name
	sprite = p_sprite

func get_letters() -> Array[String]:
	var result: Array[String] = []
	for i in range(item_name.length()):
		var letter_char = item_name[i]
		if letter_char != " ":
			result.append(letter_char)
	return result
