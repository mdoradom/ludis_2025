extends Control

const DEFAULT_SCALE: Vector2 = Vector2.ONE

@export var hovered_scale_multiplier: float = 1.25
@export var dragged_scale_multiplier: float = 1.5
@export var tween_duration: float = 0.15

# Expose transition and ease types to the inspector
@export_enum("Linear:0", "Sine:1", "Quad:2", "Cubic:3", "Quart:4", "Quint:5", "Expo:6", "Circ:7", "Elastic:8", "Back:9", "Bounce:10")
var transition_type: int = Tween.TRANS_SINE

var is_hovered: bool = false
var is_dragged: bool = false
var tween: Tween

func tween_scale(target: Vector2) -> void:
	if tween and tween.is_valid():
		tween.kill()
	tween = get_tree().create_tween()
	tween.tween_property(self, "scale", target, tween_duration).set_trans(transition_type).set_ease(Tween.EASE_OUT)

func _on_letter_mouse_entered() -> void:
	if not is_dragged:
		tween_scale(DEFAULT_SCALE * hovered_scale_multiplier)
	is_hovered = true

func _on_letter_mouse_exited() -> void:
	if not is_dragged:
		tween_scale(DEFAULT_SCALE)
	is_hovered = false

func _on_letter_letter_dragged(letter: Variant) -> void:
	tween_scale(DEFAULT_SCALE * dragged_scale_multiplier)
	is_dragged = true

func _on_letter_letter_released(letter: Variant) -> void:
	if is_hovered:
		tween_scale(DEFAULT_SCALE * hovered_scale_multiplier)
	else:
		tween_scale(DEFAULT_SCALE)
	is_dragged = false
