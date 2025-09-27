class_name Letter
extends Resource

@export var letter_value: String = ""

# Physics properties for when the letter is floating
@export var float_speed: float = 50.0
@export var float_amplitude: float = 20.0
@export var float_frequency: float = 2.0

# Optional sound effects
@export var pickup_sound: AudioStream
@export var drop_sound: AudioStream

func _init(p_letter: String = ""):
	letter_value = p_letter
