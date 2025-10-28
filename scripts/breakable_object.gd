class_name BreakableObject
extends RigidBody2D

@onready var default_icon = preload("res://icon.svg")
@onready var sprite_material: ShaderMaterial = $Sprite2D.material

@export var name_popup_scene: PackedScene
var name_popup_instance: Control

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
	
	# Setup name popup
	_setup_name_popup()
	
	# Set up timer for tap detection
	tap_timer = Timer.new()
	tap_timer.wait_time = 0.5  # Time window for taps
	tap_timer.one_shot = true
	tap_timer.connect("timeout", Callable(self, "_on_tap_timer_timeout"))
	add_child(tap_timer)
	
	# Connect input events
	input_pickable = true
	connect("input_event", Callable(self, "_on_input_event"))

func _setup_name_popup():
	if !name_popup_scene:
		return
	
	# Instance the popup scene
	name_popup_instance = name_popup_scene.instantiate()
	add_child(name_popup_instance)
	
	# Set the name text
	if name_popup_instance.has_method("set_text"):
		name_popup_instance.set_text(object_data.item_name if object_data else "")
	elif name_popup_instance.has_node("Panel/Label"):
		name_popup_instance.get_node("Panel/Label").text = object_data.item_name if object_data else ""
	elif name_popup_instance.has_node("Label"):
		name_popup_instance.get_node("Label").text = object_data.item_name if object_data else ""
	
	# Position above sprite
	var sprite_size = $Sprite2D.texture.get_size() if $Sprite2D.texture else Vector2(64, 64)
	name_popup_instance.position = Vector2(0, -sprite_size.y / 2 - 40)
	name_popup_instance.modulate.a = 0.0
	name_popup_instance.z_index = 10

func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		AudioManager.play_sfx(AudioManager.SFX.TAP_SOUND)

		tap_count += 1
		print("Tap count: ", tap_count)
		
		if tap_count == 1:
			tap_timer.start()
		
		if tap_count >= object_data.taps_to_break:
			_break_object()

func _on_tap_timer_timeout():
	tap_count = 0
	
func _break_object():
	AudioManager.play_sfx(AudioManager.SFX.BREAK_SOUND)

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
	if !name_popup_instance:
		return
	
	# Animate outline
	var outline_tween = create_tween()
	outline_tween.tween_property(sprite_material, "shader_parameter/outline_amount", 1.0, 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	# Show name popup
	var popup_tween = create_tween()
	popup_tween.tween_property(name_popup_instance, "modulate:a", 1.0, 0.15).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	popup_tween.tween_property(name_popup_instance, "position:y", name_popup_instance.position.y - 5, 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _on_mouse_exited() -> void:
	if !name_popup_instance:
		return
	
	# Animate outline
	var outline_tween = create_tween()
	outline_tween.tween_property(sprite_material, "shader_parameter/outline_amount", 0.0, 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	
	# Hide name popup
	var popup_tween = create_tween()
	popup_tween.tween_property(name_popup_instance, "modulate:a", 0.0, 0.15).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	popup_tween.tween_property(name_popup_instance, "position:y", name_popup_instance.position.y + 5, 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)

func _on_dragged(object: Variant) -> void:
	var tween = create_tween()
	tween.tween_property(sprite_material, "shader_parameter/shadow_amount", 1.0, 0.2).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)

func _on_released(object: Variant) -> void:
	var tween = create_tween()
	tween.tween_property(sprite_material, "shader_parameter/shadow_amount", 0.0, 0.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
