class_name BreakableObjectData
extends Resource

@export var item_name: String = ""
@export var sprite: Texture2D
@export var taps_to_break: int = 2
@export var break_sound: AudioStream
@export var dictation_audio: AudioStream  # Audio for dictation/pronunciation of this object

# Physical properties
@export var letter_spawn_radius: float = 50.0
@export var letter_spawn_force: float = 100.0
@export var letter_spawn_rotation: float = PI/4

enum Type {
	NONE,
	STICKER,
	OBJECT
}

@export var type: Type

var is_new: bool = false
var album_position: Vector2

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
