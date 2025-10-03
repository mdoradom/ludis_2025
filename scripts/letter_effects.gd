extends Control

const DEFAULT_SCALE: Vector2 = Vector2.ONE

@export var hovered_scale_multiplier: float = 1.25
@export var dragged_scale_multiplier: float = 1.5

var is_hovered: bool = false
var is_dragged: bool = false

func _on_letter_mouse_entered() -> void:
	if not is_dragged: scale *= hovered_scale_multiplier
	is_hovered = true

func _on_letter_mouse_exited() -> void:
	if not is_dragged: scale = DEFAULT_SCALE
	is_hovered = false


func _on_letter_letter_dragged(letter: Variant) -> void:
	scale = DEFAULT_SCALE * dragged_scale_multiplier
	is_dragged = true


func _on_letter_letter_released(letter: Variant) -> void:
	scale = DEFAULT_SCALE * hovered_scale_multiplier
	is_dragged = false
