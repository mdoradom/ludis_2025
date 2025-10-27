class_name BreakableObject
extends RigidBody2D

@onready var default_icon = preload("res://icon.svg")
@onready var sprite_material: ShaderMaterial = $Sprite2D.material

signal dragged(object)
signal released(object)
signal clicked(object)

signal broken(object_data, position)

@export var object_data: BreakableObjectData
var tap_count: int = 0
var tap_timer: Timer

func _ready():
	if !object_data.sprite:
		object_data.sprite = default_icon
	
	$Sprite2D.texture = object_data.sprite
	
	# Set up timer for tap detection
	tap_timer = Timer.new()
	tap_timer.wait_time = 0.5  # Time window for taps
	tap_timer.one_shot = true
	tap_timer.connect("timeout", Callable(self, "_on_tap_timer_timeout"))
	add_child(tap_timer)
	
	# Connect input events
	input_pickable = true
	connect("input_event", Callable(self, "_on_input_event"))

func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		tap_count += 1
		print("Tap count: ", tap_count)
		
		if tap_count == 1:
			tap_timer.start()
		
		if tap_count >= object_data.taps_to_break:
			_break_object()

func _on_tap_timer_timeout():
	tap_count = 0
	
func _break_object():
	$CollisionShape2D.disabled = true

	var tween = create_tween()

	tween.tween_property(self, "modulate:a", 0.0, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	if object_data.break_sound:
		AudioManager.play_sound_effect(object_data.break_sound, -5.0, randf_range(0.9, 1.1))

	emit_signal("broken", object_data, global_position)

	var timer = Timer.new()
	timer.wait_time = 0.2
	timer.one_shot = true
	timer.connect("timeout", Callable(self, "queue_free"))
	add_child(timer)
	timer.start()

func _on_mouse_entered() -> void:
	# Create a new tween
	var tween = create_tween()
	# Animate the 'outline_amount' property from its current value to 1.0 over 0.2 seconds
	tween.tween_property(sprite_material, "shader_parameter/outline_amount", 1.0, 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func _on_mouse_exited() -> void:
	var tween = create_tween()
	# Animate 'outline_amount' back to 0.0
	tween.tween_property(sprite_material, "shader_parameter/outline_amount", 0.0, 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)


func _on_dragged(object: Variant) -> void:
	var tween = create_tween()
	# Animate 'shadow_amount' to 1.0
	tween.tween_property(sprite_material, "shader_parameter/shadow_amount", 1.0, 0.2).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)


func _on_released(object: Variant) -> void:
	var tween = create_tween()
	# Animate 'shadow_amount' back to 0.0
	tween.tween_property(sprite_material, "shader_parameter/shadow_amount", 0.0, 0.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
