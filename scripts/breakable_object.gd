class_name BreakableObject
extends Area2D

@onready var default_icon = preload("res://icon.svg")

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
	# Play break animation or sound if available
	if object_data.break_sound:
		var audio_player = AudioStreamPlayer.new()
		audio_player.stream = object_data.break_sound
		audio_player.autoplay = true
		audio_player.connect("finished", Callable(audio_player, "queue_free"))
		get_parent().add_child(audio_player)
	
	# Emit signal with object data
	emit_signal("broken", object_data, global_position)
	
	# Hide sprite (optional: could animate breaking instead)
	$Sprite2D.visible = false
	
	# Queue for deletion after small delay (gives time for animation)
	var timer = Timer.new()
	timer.wait_time = 0.2
	timer.one_shot = true
	timer.connect("timeout", Callable(self, "queue_free"))
	add_child(timer)
	timer.start()
