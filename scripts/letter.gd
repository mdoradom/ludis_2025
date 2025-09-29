extends RigidBody2D

signal letter_dragged(letter)
signal letter_released(letter)
signal letter_clicked(letter)

@export var float_amplitude: float = 6.0
@export var float_frequency: float = 2.5
@export var float_speed: float = 100.0

var value: String = ""
var is_floating: bool = false
var is_dragging: bool = false
var is_in_word_area: bool = false
var initial_position: Vector2
var target_position: Vector2
var drag_offset: Vector2
var time_passed: float = 0
var float_direction: Vector2

func _ready():
	gravity_scale = 0.0
	input_pickable = true
	connect("input_event", Callable(self, "_on_input_event"))
	connect("mouse_entered", Callable(self, "_on_mouse_entered"))
	connect("mouse_exited", Callable(self, "_on_mouse_exited"))

func setup(letter_char: String, start_pos: Vector2):
	value = letter_char
	global_position = start_pos
	initial_position = global_position
	
	$Label.text = value
	float_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	
	linear_velocity = float_direction * float_speed
	is_floating = true

func _process(delta):
	time_passed += delta
	if is_dragging:
		sleeping = true
		global_position = get_global_mouse_position() + drag_offset
	else:
		if sleeping:
			sleeping = false

func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			is_floating = false
			is_dragging = true
			drag_offset = global_position - get_global_mouse_position()
			emit_signal("letter_dragged", self)
			Input.set_default_cursor_shape(Input.CURSOR_DRAG)
		else:
			is_dragging = false
			sleeping = false
			linear_velocity = float_direction * float_speed
			emit_signal("letter_released", self)
			Input.set_default_cursor_shape(Input.CURSOR_ARROW)

func _on_mouse_entered():
	if not is_dragging:
		scale = Vector2(1.1, 1.1)

func _on_mouse_exited():
	if not is_dragging:
		scale = Vector2(1.0, 1.0)

func stop_floating():
	is_floating = false
	linear_velocity = Vector2.ZERO
